// lib/screens/camp_list_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models.dart';
import '../data/default_checklist.dart';
import 'camp_detail_screen.dart';

class CampListScreen extends StatefulWidget {
  const CampListScreen({super.key});

  @override
  State<CampListScreen> createState() => _CampListScreenState();
}

class _CampListScreenState extends State<CampListScreen> {
  final _uuid = const Uuid();
  final List<Camp> _camps = [];

  Future<void> _addCampDialog() async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text('Yeni Kamp'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Kamp adı',
                      ),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Konum',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Tarih: '),
                        Text(
                          '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setStateDialog(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: const Text('Seç'),
                        ),
                      ],
                    ),
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
                    if (titleController.text.trim().isEmpty) return;
                    Navigator.of(ctx).pop(true);
                  },
                  child: const Text('Oluştur'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      final newCamp = Camp(
        id: _uuid.v4(),
        title: titleController.text.trim(),
        date: selectedDate,
        location: locationController.text.trim(),
        note: '',
        items: buildDefaultChecklist(),
        photoPaths: [],
      );

      setState(() {
        _camps.add(newCamp);
      });
    }
  }

  void _openCampDetail(Camp camp) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CampDetailScreen(
          camp: camp,
          onUpdated: (updatedCamp) {
            setState(() {
              final index =
              _camps.indexWhere((element) => element.id == updatedCamp.id);
              if (index != -1) {
                _camps[index] = updatedCamp;
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamplarım'),
      ),
      body: _camps.isEmpty
          ? const Center(
        child: Text('Henüz kamp eklemedin. Sağ alttan + ile bir kamp oluştur.'),
      )
          : ListView.separated(
        itemCount: _camps.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (ctx, index) {
          final camp = _camps[index];
          final doneCount =
              camp.items.where((e) => e.isChecked).length;
          return ListTile(
            title: Text(camp.title),
            subtitle: Text(
              '${camp.location.isEmpty ? 'Konum yok' : camp.location} • '
                  '${camp.date.day}.${camp.date.month}.${camp.date.year}\n'
                  '$doneCount / ${camp.items.length} madde tamamlandı',
            ),
            isThreeLine: true,
            onTap: () => _openCampDetail(camp),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCampDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
