import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/availability_model.dart';

class OwnerAvailabilityScreen extends ConsumerWidget {
  const OwnerAvailabilityScreen({super.key, required this.spotId});

  final String spotId;

  // Days ordered Mon–Sun using DB convention: 0=Sunday, 1=Monday … 6=Saturday.
  static const _days = [1, 2, 3, 4, 5, 6, 0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(spotId) ?? -1;

    final spot = ref.watch(
      ownerStoreProvider.select(
        (s) => s.spots.where((p) => p.id == id).firstOrNull,
      ),
    );

    // All availability rules for this spot, keyed by dayOfWeek.
    final availabilityList = ref.watch(
      ownerStoreProvider.select((s) => s.availabilityBySpotId[id] ?? const []),
    );

    final availabilityByDay = {
      for (final a in availabilityList) a.dayOfWeek: a,
    };

    final title = spot?.title ?? 'Parking Spot';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            Text(
              'Weekly Schedule',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure which days your spot is open. These settings repeat every week.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ..._days.map((dow) {
              final record =
                  availabilityByDay[dow] ??
                  AvailabilityModel.defaultOpen(id, dow);

              return _DayCard(
                spotId: id,
                record: record,
                onToggle: (isOpen) {
                  ref
                      .read(ownerStoreProvider.notifier)
                      .setWeeklyAvailability(
                        spotId: id,
                        dayOfWeek: dow,
                        isBlocked: !isOpen,
                        openTime: _fmtDb(record.openTime),
                        closeTime: _fmtDb(record.closeTime),
                      );
                },
                onOpenTimeTap: (picked) {
                  ref
                      .read(ownerStoreProvider.notifier)
                      .setWeeklyAvailability(
                        spotId: id,
                        dayOfWeek: dow,
                        isBlocked: record.isBlocked,
                        openTime: _fmtDb(picked),
                        closeTime: _fmtDb(record.closeTime),
                      );
                },
                onCloseTimeTap: (picked) {
                  ref
                      .read(ownerStoreProvider.notifier)
                      .setWeeklyAvailability(
                        spotId: id,
                        dayOfWeek: dow,
                        isBlocked: record.isBlocked,
                        openTime: _fmtDb(record.openTime),
                        closeTime: _fmtDb(picked),
                      );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  static String _fmtDb(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
}

// ---------------------------------------------------------------------------
// Day card widget
// ---------------------------------------------------------------------------

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.spotId,
    required this.record,
    required this.onToggle,
    required this.onOpenTimeTap,
    required this.onCloseTimeTap,
  });

  final int spotId;
  final AvailabilityModel record;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onOpenTimeTap;
  final ValueChanged<TimeOfDay> onCloseTimeTap;

  bool get _isOpen => !record.isBlocked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: _isOpen ? AppColors.secondary.withOpacity(0.5) : AppColors.border,
          width: _isOpen ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row: day name + open/closed toggle ──────────────────
            Row(
              children: [
                // Coloured indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOpen ? AppColors.secondary : AppColors.error,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    record.dayName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  _isOpen ? 'Open' : 'Closed',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: _isOpen ? AppColors.secondary : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isOpen,
                  activeColor: AppColors.secondary,
                  onChanged: onToggle,
                ),
              ],
            ),

            // ── Hours row (only visible when open) ─────────────────────────
            if (_isOpen) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16),
                  const SizedBox(width: 6),
                  _TimeChip(
                    label: 'Opens',
                    time: record.openTime,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: record.openTime,
                        helpText: 'Select opening time',
                      );
                      if (picked != null) onOpenTimeTap(picked);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '→',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                    ),
                  ),
                  _TimeChip(
                    label: 'Closes',
                    time: record.closeTime,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: record.closeTime,
                        helpText: 'Select closing time',
                      );
                      if (picked != null) onCloseTimeTap(picked);
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tappable time chip
// ---------------------------------------------------------------------------

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.time,
    required this.onTap,
  });

  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  String _fmt(TimeOfDay t) {
    final hour = t.hour == 0 ? 12 : (t.hour > 12 ? t.hour - 12 : t.hour);
    final period = t.hour >= 12 ? 'PM' : 'AM';
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
            ),
            Text(
              _fmt(time),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
