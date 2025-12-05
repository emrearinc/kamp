// lib/screens/camp_detail_screen.dart
import 'package:flutter/material.dart';

import '../data/models.dart';

class CampDetailScreen extends StatefulWidget {
  final Camp camp;
  final ValueChanged<Camp> onUpdated;

  const CampDetailScreen({
    super.key,
    required this.camp,
    required this.onUpdated,
  });

  @override
  State<CampDetailScreen> createState() => _CampDetailScreenState();
}

class _CampDetailScreenState extends State<CampDetailScreen> {
  static const String _defaultCategory = '🎒 Diğer';
  late Camp _camp;

  @override
  void initState() {
    super.initState();
    _camp = widget.camp.copyWith(
      categories: _buildCategoryList(
        widget.camp.items,
        extra: widget.camp.categories,
      ),
    );
  }

  List<String> _buildCategoryList(List<ChecklistItem> items,
      {List<String> extra = const []}) {
    final categories = {
      ...items.map((e) => e.category),
      ...extra,
    }.toList()
      ..sort();
    if (!categories.contains(_defaultCategory)) {
      categories.add(_defaultCategory);
      categories.sort();
    }
    return categories;
  }

  void _updateCamp(Camp updated) {
    setState(() {
      _camp = updated.copyWith(
        categories: _buildCategoryList(
          updated.items,
          extra: updated.categories,
        ),
      );
    });
    widget.onUpdated(_camp);
  }

  void _toggleItem(ChecklistItem item, bool? value) {
    final updatedItem = item.copyWith(isChecked: value ?? false);
    _updateCamp(
      _camp.copyWith(
        items: _camp.items
            .map((e) => e.id == item.id ? updatedItem : e)
            .toList(),
      ),
    );
  }

  Future<void> _openItemEditor({ChecklistItem? item}) async {
    final labelController = TextEditingController(text: item?.label ?? '');
    final categoryController =
        TextEditingController(text: item?.category ?? _defaultCategory);
    final quantityController =
        TextEditingController(text: (item?.quantity ?? 1).toString());
    var selectedUnit = item?.unit ?? QuantityUnit.piece;

    final categories = [..._camp.categories]..sort();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: Text(item == null ? 'Yeni madde ekle' : 'Maddeyi düzenle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        labelText: 'Madde adı',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Miktar',
                              helperText: 'Varsayılan olarak 1 ad',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        DropdownButton<QuantityUnit>(
                          value: selectedUnit,
                          onChanged: (value) {
                            if (value != null) {
                              setStateDialog(() => selectedUnit = value);
                            }
                          },
                          items: QuantityUnit.values
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit.label),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        helperText:
                            'Yeni bir kategori yazabilir veya aşağıdan seçebilirsin',
                      ),
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: categories
                              .map(
                                (c) => ChoiceChip(
                                  label: Text(c),
                                  selected: categoryController.text == c,
                                  onSelected: (_) => categoryController.text = c,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (labelController.text.trim().isEmpty ||
                        categoryController.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(item == null ? 'Ekle' : 'Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) return;

    final label = labelController.text.trim();
    final category = categoryController.text.trim();
    final parsedQuantity =
        double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 1;
    final quantity = parsedQuantity > 0 ? parsedQuantity : 1;

    if (item == null) {
      final maxOrder = _camp.items.isEmpty
          ? 0
          : _camp.items
          .map((e) => e.sortOrder)
          .reduce((a, b) => a > b ? a : b);

      final newItem = ChecklistItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        category: category,
        label: label,
        quantity: quantity,
        unit: selectedUnit,
        isChecked: false,
        sortOrder: maxOrder + 1,
      );

      _updateCamp(
        _camp.copyWith(
          items: [..._camp.items, newItem],
        ),
      );
    } else {
      final updatedItem = item.copyWith(
        label: label,
        category: category,
        quantity: quantity,
        unit: selectedUnit,
      );

      _updateCamp(
        _camp.copyWith(
          items: _camp.items
              .map((e) => e.id == item.id ? updatedItem : e)
              .toList(),
        ),
      );
    }
  }

  void _deleteItem(ChecklistItem item) {
    _updateCamp(
      _camp.copyWith(
        items: _camp.items.where((e) => e.id != item.id).toList(),
      ),
    );
  }

  String _formatQuantity(ChecklistItem item) {
    final formattedQuantity = item.quantity % 1 == 0
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(1);
    return '$formattedQuantity ${item.unit.shortLabel}';
  }

  Future<void> _addOrEditParticipant({String? existing}) async {
    final controller = TextEditingController(text: existing ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(existing == null ? 'Katılımcı ekle' : 'Katılımcıyı düzenle'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Ad soyad',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (saved != true) return;

    final name = controller.text.trim();

    if (existing == null) {
      _updateCamp(
        _camp.copyWith(participants: [..._camp.participants, name]),
      );
    } else {
      _updateCamp(
        _camp.copyWith(
          participants:
              _camp.participants.map((p) => p == existing ? name : p).toList(),
        ),
      );
    }
  }

  void _removeParticipant(String name) {
    _updateCamp(
      _camp.copyWith(
        participants: _camp.participants.where((p) => p != name).toList(),
      ),
    );
  }

  void _editNote() async {
    final controller = TextEditingController(text: _camp.note);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Notlar'),
          content: TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Bu kampla ilgili notlarını yaz...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _updateCamp(_camp.copyWith(note: controller.text.trim()));
    }
  }

  Future<void> _manageCategories() async {
    final newCategoryController = TextEditingController();
    var categories = [..._camp.categories]..sort();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            Future<void> renameCategory(String category) async {
              final controller = TextEditingController(text: category);
              final renamed = await showDialog<bool>(
                context: context,
                builder: (renameCtx) {
                  return AlertDialog(
                    title: const Text('Kategori adını düzenle'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Yeni ad'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(renameCtx).pop(false),
                        child: const Text('İptal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          if (controller.text.trim().isEmpty) return;
                          Navigator.of(renameCtx).pop(true);
                        },
                        child: const Text('Kaydet'),
                      ),
                    ],
                  );
                },
              );

              if (renamed != true) return;

              final newName = controller.text.trim();
              if (newName.isEmpty || newName == category) return;

              final updatedItems = _camp.items
                  .map(
                    (item) => item.category == category
                        ? item.copyWith(category: newName)
                        : item,
                  )
                  .toList();

              final updatedCategories = {
                ...categories.where((c) => c != category),
                newName,
              }.toList()
                ..sort();

              categories = updatedCategories;
              _updateCamp(
                _camp.copyWith(
                  items: updatedItems,
                  categories: updatedCategories,
                ),
              );
              setStateDialog(() {});
            }

            void deleteCategory(String category) {
              if (category == _defaultCategory) return;

              final updatedItems = _camp.items
                  .map(
                    (item) => item.category == category
                        ? item.copyWith(category: _defaultCategory)
                        : item,
                  )
                  .toList();

              categories = _buildCategoryList(
                updatedItems,
                extra: categories.where((c) => c != category).toList(),
              );

              _updateCamp(
                _camp.copyWith(
                  items: updatedItems,
                  categories: categories,
                ),
              );
              setStateDialog(() {});
            }

            void addCategory() {
              final newCategory = newCategoryController.text.trim();
              if (newCategory.isEmpty || categories.contains(newCategory)) return;

              categories = [...categories, newCategory]..sort();
              _updateCamp(_camp.copyWith(categories: categories));
              newCategoryController.clear();
              setStateDialog(() {});
            }

            return AlertDialog(
              title: const Text('Kategorileri yönet'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: newCategoryController,
                      decoration: InputDecoration(
                        labelText: 'Yeni kategori',
                        suffixIcon: IconButton(
                          onPressed: addCategory,
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (categories.isEmpty)
                      const Text('Henüz kategori yok')
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, index) {
                          final category = categories[index];
                          return ListTile(
                            title: Text(category),
                            trailing: Wrap(
                              spacing: 4,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => renameCategory(category),
                                  tooltip: 'Düzenle',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => deleteCategory(category),
                                  tooltip: 'Sil',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Kapat'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = _camp.items.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final grouped = <String, List<ChecklistItem>>{};
    for (final item in sortedItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final gradient = LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary.withOpacity(0.12),
        Colors.white,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_camp.title),
        actions: [
          IconButton(
            onPressed: _manageCategories,
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Kategorileri yönet',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  _buildParticipantsCard(),
                  ...grouped.entries.map((entry) {
                    final category = entry.key;
                    final items = entry.value;
                    final doneCount =
                        items.where((e) => e.isChecked).length;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          childrenPadding: const EdgeInsets.only(bottom: 8),
                          title: Text(category),
                          subtitle: Text('$doneCount / ${items.length} tamamlandı'),
                          trailing: const Icon(Icons.expand_more),
                          children: items.map((item) {
                            return Dismissible(
                              key: ValueKey(item.id),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .error
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _deleteItem(item),
                              child: CheckboxListTile(
                                value: item.isChecked,
                                onChanged: (val) => _toggleItem(item, val),
                                title: Text(item.label),
                                subtitle: Text('Miktar: ${_formatQuantity(item)}'),
                                secondary: IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _openItemEditor(item: item),
                                  tooltip: 'Düzenle',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openItemEditor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildParticipantsCard() {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group_outlined),
                const SizedBox(width: 8),
                Text(
                  'Katılımcılar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _addOrEditParticipant(),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_camp.participants.isEmpty)
              Text(
                'Henüz katılımcı eklenmedi',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _camp.participants
                    .map(
                      (name) => InputChip(
                        label: Text(name),
                        onDeleted: () => _removeParticipant(name),
                        onPressed: () =>
                            _addOrEditParticipant(existing: name),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final completed = _camp.items.where((e) => e.isChecked).length;
    final total = _camp.items.length;

    // Ham progress double olsun
    final double rawProgress =
    total == 0 ? 0.0 : completed / total.toDouble();

    // clamp num döndürür, o yüzden num olarak tut
    final num clamped = rawProgress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_camp.date.day}.${_camp.date.month}.${_camp.date.year}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoPill(
                icon: Icons.place_outlined,
                label: _camp.location.isEmpty
                    ? 'Konum belirtilmemiş'
                    : _camp.location,
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.note_outlined,
                label: _camp.note.isEmpty
                    ? 'Not eklenmedi'
                    : 'Not kaydedildi',
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.group_outlined,
                label: '${_camp.participants.length} katılımcı',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tamamlanma durumu'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          // BURASI ÖNEMLİ: num → double
                          value: clamped.toDouble(),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$completed / $total madde',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _editNote,
                    icon: const Icon(Icons.edit_note_outlined),
                    tooltip: 'Not ekle/düzenle',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
