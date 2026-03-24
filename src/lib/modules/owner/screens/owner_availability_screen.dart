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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(spotId) ?? -1;

    final spot = ref.watch(
      ownerStoreProvider.select(
        (s) => s.spots.where((p) => p.id == id).firstOrNull,
      ),
    );

    final availability = ref.watch(
      ownerStoreProvider.select((s) => s.availabilityBySpotId[id] ?? const []),
    );

    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    String title = spot?.title ?? 'Parking spot';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            Text(
              'Availability (next 7 days)',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...days.map((day) {
              final specific = availability.firstWhere(
                (a) =>
                    a.specificDate != null &&
                    a.specificDate!.year == day.year &&
                    a.specificDate!.month == day.month &&
                    a.specificDate!.day == day.day,
                orElse: () => AvailabilityModel(
                  id: -1,
                  spotId: id,
                  dayOfWeek: null,
                  specificDate: day,
                  openTime: const TimeOfDay(hour: 8, minute: 0),
                  closeTime: const TimeOfDay(hour: 22, minute: 0),
                  isBlocked: false,
                ),
              );

              final dayOfWeek = day.weekday % 7; // Sunday=0
              final recurring = availability.firstWhere(
                (a) => a.dayOfWeek == dayOfWeek,
                orElse: () => AvailabilityModel(
                  id: -2,
                  spotId: id,
                  dayOfWeek: dayOfWeek,
                  specificDate: null,
                  openTime: const TimeOfDay(hour: 8, minute: 0),
                  closeTime: const TimeOfDay(hour: 22, minute: 0),
                  isBlocked: false,
                ),
              );

              final record = specific.id != -1 ? specific : recurring;

              final label =
                  '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardBorderRadius,
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      record.isBlocked
                          ? Icons.block_rounded
                          : Icons.check_circle_rounded,
                      color: record.isBlocked
                          ? AppColors.error
                          : AppColors.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Open: ${record.openTime} - ${record.closeTime}',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: !record.isBlocked,
                      onChanged: (value) {
                        ref
                            .read(ownerStoreProvider.notifier)
                            .setAvailabilityForDay(
                              spotId: id,
                              day: day,
                              blocked: !value,
                            );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
