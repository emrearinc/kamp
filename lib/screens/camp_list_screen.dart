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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Kamp adı',
                        prefixIcon: Icon(Icons.terrain_outlined),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Konum',
                        prefixIcon: Icon(Icons.place_outlined),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                        ),
                        const Spacer(),
                        TextButton.icon(
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('İptal'),
                ),
                FilledButton(
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
      final defaultItems = buildDefaultChecklist();
      final defaultCategories = defaultItems
          .map((e) => e.category)
          .toSet()
          .toList()
        ..sort();

      final newCamp = Camp(
        id: _uuid.v4(),
        title: titleController.text.trim(),
        date: selectedDate,
        location: locationController.text.trim(),
        note: '',
        items: defaultItems,
        photoPaths: [],
        participants: [],
        categories: defaultCategories,
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
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.08),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              Expanded(
                child: _camps.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  itemCount: _camps.length,
                  itemBuilder: (ctx, index) {
                    final camp = _camps[index];
                    return _CampCard(
                      camp: camp,
                      onTap: () => _openCampDetail(camp),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCampDialog,
        icon: const Icon(Icons.add),
        label: const Text('Yeni kamp'),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final upcoming = _camps.where((c) => !c.date.isBefore(
      DateTime(now.year, now.month, now.day),
    ));

    final int total = _camps.length;
    final int upcomingCount = upcoming.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forest_outlined, size: 24),
              const SizedBox(width: 8),
              Text(
                'Kamplarım',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _HeaderChip(
                icon: Icons.list_alt_outlined,
                label: '$total kamp',
              ),
              const SizedBox(width: 8),
              _HeaderChip(
                icon: Icons.upcoming_outlined,
                label: upcomingCount == 0
                    ? 'Yaklaşan kamp yok'
                    : '$upcomingCount yaklaşan kamp',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.landscape_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz kamp eklemedin',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Sağ alttaki butondan ilk kampını oluştur.\nDefault checklist otomatik dolacak, sen sadece düzenleyeceksin.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _CampCard extends StatelessWidget {
  const _CampCard({
    required this.camp,
    required this.onTap,
  });

  final Camp camp;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = camp.items.where((e) => e.isChecked).length;
    final total = camp.items.length;
    final double progress =
    total == 0 ? 0.0 : completed / total.toDouble();

    final dateText =
        '${camp.date.day}.${camp.date.month}.${camp.date.year}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 1,
        shadowColor: theme.shadowColor.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                _AvatarCircle(letter: camp.title.isNotEmpty ? camp.title[0] : '?'),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        camp.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _InfoChip(
                            icon: Icons.event_outlined,
                            label: dateText,
                          ),
                          _InfoChip(
                            icon: Icons.place_outlined,
                            label: camp.location.isEmpty
                                ? 'Konum yok'
                                : camp.location,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completed / $total madde tamamlandı',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                          theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.primary.withOpacity(0.15),
      ),
      alignment: Alignment.center,
      child: Text(
        letter.toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
