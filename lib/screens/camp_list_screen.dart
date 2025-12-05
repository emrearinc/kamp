// lib/screens/camp_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../data/default_checklist.dart';
import '../data/models.dart';
import '../data/storage.dart';
import 'camp_detail_screen.dart';

class CampListScreen extends StatefulWidget {
  const CampListScreen({super.key});

  @override
  State<CampListScreen> createState() => _CampListScreenState();
}

class _CampListScreenState extends State<CampListScreen> {
  final _uuid = const Uuid();
  final List<Camp> _camps = [];
  final _storage = CampStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCamps();
  }

  Future<void> _loadCamps() async {
    final camps = await _storage.loadCamps();
    setState(() {
      _camps
        ..clear()
        ..addAll(camps);
      _isLoading = false;
    });
  }

  Future<void> _persist() => _storage.saveCamps(_camps);

  Future<void> _addCampDialog() async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final result = await showModalBottomSheet<bool>(
      isScrollControlled: true,
      context: context,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Kamp adı',
                      prefixIcon: Icon(Icons.terrain_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Konum',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tarih'),
                          const SizedBox(height: 6),
                          Text(
                            '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const Spacer(),
                      FilledButton.icon(
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
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                        label: const Text('Tarih seç'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) return;
                        Navigator.of(ctx).pop(true);
                      },
                      child: const Text('Kamp oluştur'),
                    ),
                  ),
                ],
              );
            },
          ),
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
      await _persist();
    }
  }

  void _openCampDetail(Camp camp) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CampDetailScreen(
          camp: camp,
          onUpdated: _handleCampUpdated,
        ),
      ),
    );
  }

  void _handleCampUpdated(Camp updatedCamp) {
    setState(() {
      final index = _camps.indexWhere((element) => element.id == updatedCamp.id);
      if (index != -1) {
        _camps[index] = updatedCamp;
      }
    });
    _persist();
  }

  Future<void> _backupCamps() async {
    final payload = await _storage.buildBackupPayload(_camps);
    final path = await _storage.saveBackupFile(payload);
    await Clipboard.setData(ClipboardData(text: payload));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Yedek alındı. Dosya: $path'),
        action: SnackBarAction(
          label: 'PANODA',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: payload));
          },
        ),
      ),
    );
  }

  Future<void> _restoreCamps() async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Yedekten geri yükle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Yedek JSON bilgisini buraya yapıştır.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '{ ... }',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Geri yükle'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final restored = await _storage.restoreFromPayload(controller.text);
        setState(() {
          _camps
            ..clear()
            ..addAll(restored);
        });
        await _persist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Yedek başarıyla geri yüklendi')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Geri yükleme başarısız: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary.withOpacity(0.1),
        Colors.white,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamplarım'),
        actions: [
          IconButton(
            tooltip: 'Yedek al',
            onPressed: _backupCamps,
            icon: const Icon(Icons.download_for_offline_outlined),
          ),
          IconButton(
            tooltip: 'Geri yükle',
            onPressed: _restoreCamps,
            icon: const Icon(Icons.upload_file_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _camps.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _camps.length,
                    itemBuilder: (ctx, index) {
                      final camp = _camps[index];
                      final doneCount = camp.items.where((e) => e.isChecked).length;
                      return _CampCard(
                        camp: camp,
                        doneCount: doneCount,
                        onTap: () => _openCampDetail(camp),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCampDialog,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _CampCard extends StatelessWidget {
  const _CampCard({
    required this.camp,
    required this.doneCount,
    required this.onTap,
  });

  final Camp camp;
  final int doneCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = camp.items.isEmpty
        ? 0.0
        : (doneCount / camp.items.length.toDouble()).clamp(0, 1);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      camp.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.place_outlined,
                    label: camp.location.isEmpty ? 'Konum yok' : camp.location,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label:
                        '${camp.date.day}.${camp.date.month}.${camp.date.year}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 6),
              Text('$doneCount / ${camp.items.length} madde tamamlandı'),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.terrain_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz kamp eklemedin',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sağ alttan + butonu ile kamp oluştur, yedek alıp paylaşmayı unutma.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
