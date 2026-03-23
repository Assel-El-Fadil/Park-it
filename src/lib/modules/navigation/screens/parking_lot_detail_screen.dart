import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/modules/owner/models/parking_lot_model.dart';
import 'package:src/modules/owner/repositories/parking_lot_repository.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/photo_carousel.dart';
import 'package:src/shared/widgets/section_header.dart';

final parkingLotDetailProvider = FutureProvider.family<ParkingLotModel?, int>((ref, id) {
  final repo = ref.read(parkingLotRepositoryProvider);
  return repo.getById(id.toString());
});

class ParkingLotDetailScreen extends ConsumerWidget {
  const ParkingLotDetailScreen({super.key, required this.lotId});

  final int lotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lotAsync = ref.watch(parkingLotDetailProvider(lotId));

    return SafeArea(
      child: Scaffold(
        body: lotAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (lot) {
            if (lot == null) {
              return const Center(child: Text('Parking lot not found.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: AppLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    FrostedBar(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Lot Details',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PhotoCarousel(photos: lot.photos ?? []),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lot.name,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  lot.fullAddress,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                          if (lot.totalSpots != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.directions_car_outlined, size: 18, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  '${lot.totalSpots} Total Spots',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (lot.description != null && lot.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'Overview'),
                            const SizedBox(height: 8),
                            Text(
                              lot.description!,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (lot.amenities != null && lot.amenities!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'Amenities'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: lot.amenities!.map((amenity) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 14, color: theme.colorScheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      amenity.name.toUpperCase(),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Back to Spot'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
