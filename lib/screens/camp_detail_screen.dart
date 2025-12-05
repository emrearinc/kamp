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
  late Camp _camp;

  @override
  void initState() {
    super.initState();
    _camp = widget.camp;
  }

  void _toggleItem(ChecklistItem item, bool? value) {
    final updatedItem = item.copyWith(isChecked: value ?? false);
    setState(() {
      _camp = _camp.copyWith(
        items: _camp.items
            .map((e) => e.id == item.id ? updatedItem : e)
            .toList(),
      );
    });
    widget.onUpdated(_camp);
  }

  void _addItem() async {
    final labelController = TextEditingController();
    String category = '🎒 Diğer';

    final categories = _camp.items
        .map((e) => e.category)
        .toSet()
        .toList()
      ..sort();

    if (categories.isEmpty) {
      categories.add(category);
    } else {
      category = categories.first;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Yeni madde ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Madde adı',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  category = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.trim().isEmpty) return;
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final maxOrder = _camp.items.isEmpty
          ? 0
          : _camp.items
          .map((e) => e.sortOrder)
          .reduce((a, b) => a > b ? a : b);

      final newItem = ChecklistItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        category: category,
        label: labelController.text.trim(),
        isChecked: false,
        sortOrder: maxOrder + 1,
      );

      setState(() {
        _camp = _camp.copyWith(
          items: [..._camp.items, newItem],
        );
      });
      widget.onUpdated(_camp);
    }
  }

  void _deleteItem(ChecklistItem item) {
    setState(() {
      _camp = _camp.copyWith(
        items: _camp.items.where((e) => e.id != item.id).toList(),
      );
    });
    widget.onUpdated(_camp);
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
      setState(() {
        _camp = _camp.copyWith(note: controller.text.trim());
      });
      widget.onUpdated(_camp);
    }
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
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: grouped.entries.map((entry) {
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
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    final progress = _camp.items.isEmpty
        ? 0.0
        : (_camp.items.where((e) => e.isChecked).length /
                _camp.items.length.toDouble())
            .clamp(0, 1);

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
                label:
                    _camp.location.isEmpty ? 'Konum belirtilmemiş' : _camp.location,
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.note_outlined,
                label: _camp.note.isEmpty ? 'Not eklenmedi' : 'Not kaydedildi',
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
                          value: progress,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(_camp.items.where((e) => e.isChecked).length)} / ${_camp.items.length} madde',
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
