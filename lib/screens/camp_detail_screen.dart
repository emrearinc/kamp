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

    return Scaffold(
      appBar: AppBar(
        title: Text(_camp.title),
      ),
      body: Column(
        children: [
          _buildHeader(),
          const Divider(height: 0),
          Expanded(
            child: ListView(
              children: grouped.entries.map((entry) {
                final category = entry.key;
                final items = entry.value;
                final doneCount =
                    items.where((e) => e.isChecked).length;

                return ExpansionTile(
                  title: Text(category),
                  subtitle: Text('$doneCount / ${items.length} tamamlandı'),
                  children: items.map((item) {
                    return Dismissible(
                      key: ValueKey(item.id),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Icon(Icons.delete),
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
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_camp.date.day}.${_camp.date.month}.${_camp.date.year}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.place, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _camp.location.isEmpty
                      ? 'Konum belirtilmemiş'
                      : _camp.location,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _camp.note.isEmpty ? 'Not eklenmemiş' : _camp.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: _editNote,
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Not'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._camp.photoPaths.map(
                    (p) => Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Foto'),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: image_picker ile foto ekleme
                },
                icon: const Icon(Icons.photo),
                label: const Text('Foto ekle'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
