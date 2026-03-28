import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/primary_button.dart';
import 'package:src/shared/widgets/section_header.dart';

class OwnerParkingLotDetailScreen extends ConsumerStatefulWidget {
  const OwnerParkingLotDetailScreen({super.key, required this.parkingLotId});

  final String parkingLotId;

  @override
  ConsumerState<OwnerParkingLotDetailScreen> createState() =>
      _OwnerParkingLotDetailScreenState();
}

class _OwnerParkingLotDetailScreenState
    extends ConsumerState<OwnerParkingLotDetailScreen> {
  final _priceHourCtrl = TextEditingController();
  final _priceDayCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _dynamicPricing = false;

  @override
  void dispose() {
    _priceHourCtrl.dispose();
    _priceDayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final ownerId = currentUser?.id ?? '';
    final lotId = int.tryParse(widget.parkingLotId);

    if (lotId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Parking Lot Detail')),
        body: const Center(child: Text('Invalid parking lot ID')),
      );
    }

    final lot = ref.watch(
      ownerStoreProvider.select(
        (s) => s.lots
            .where((l) => l.id == lotId && l.ownerId == ownerId)
            .firstOrNull,
      ),
    );

    final spots = ref.watch(
      ownerStoreProvider.select(
        (s) => s.spots
            .where((s) => s.lotId == lotId && s.ownerId == ownerId)
            .toList(),
      ),
    );

    if (lot == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Parking Lot Detail')),
        body: const Center(child: Text('Parking lot not found')),
      );
    }

    // Initialize controllers with current average prices
    if (_priceHourCtrl.text.isEmpty && spots.isNotEmpty) {
      final avgPriceHour =
          spots.fold<double>(0, (sum, s) => sum + s.pricePerHour) /
          spots.length;
      _priceHourCtrl.text = avgPriceHour.toStringAsFixed(2);

      final spotsWithDayPrice = spots.where((s) => s.pricePerDay != null);
      if (spotsWithDayPrice.isNotEmpty) {
        final avgPriceDay =
            spotsWithDayPrice.fold<double>(
              0,
              (sum, s) => sum + s.pricePerDay!,
            ) /
            spotsWithDayPrice.length;
        _priceDayCtrl.text = avgPriceDay.toStringAsFixed(2);
      }

      _dynamicPricing = spots.any((s) => s.isDynamicPricing);
    }

    final availableSpots = spots
        .where((s) => s.status == SpotStatus.available)
        .length;
    final totalBookings = spots.fold<int>(0, (sum, s) => sum + s.totalBookings);
    final averageRating = spots.isEmpty
        ? 0.0
        : spots.fold<double>(0, (sum, s) => sum + s.averageRating) /
              spots.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(lot.name),
        actions: [
          IconButton(
            tooltip: 'Edit Lot',
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lot Overview
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Lot Overview'),
                  const SizedBox(height: 12),
                  Text(
                    lot.name,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${lot.street}, ${lot.city}\n${lot.country} ${lot.postalCode}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                  if (lot.description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      lot.description!,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatBadge(
                        icon: Icons.local_parking,
                        label: '${spots.length} spots',
                        value: '$availableSpots available',
                        color: AppColors.primary,
                      ),
                      _StatBadge(
                        icon: Icons.calendar_month,
                        label: 'Total bookings',
                        value: '$totalBookings',
                        color: AppColors.primary,
                      ),
                      _StatBadge(
                        icon: Icons.star,
                        label: 'Average rating',
                        value: averageRating.toStringAsFixed(1),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Uniform Pricing Control
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Uniform Pricing Control'),
                  const SizedBox(height: 8),
                  Text(
                    'Update pricing for all ${spots.length} spots in this lot',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceHourCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price per hour (min 6 MAD)',
                      prefixText: 'MAD ',
                      suffixText: '/h',
                      helperText: 'This will update all spots in the lot',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _priceDayCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price per day (optional)',
                      prefixText: 'MAD ',
                      suffixText: '/day',
                      helperText: 'Leave empty to remove day pricing',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dynamic pricing for all spots'),
                    subtitle: const Text(
                      'Enable/disable dynamic pricing uniformly',
                    ),
                    value: _dynamicPricing,
                    onChanged: (value) =>
                        setState(() => _dynamicPricing = value),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Update All Spot Pricing',
                    icon: Icons.attach_money,
                    onPressed: _isSubmitting
                        ? null
                        : () => _updateAllSpotPricing(spots),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Uniform Availability Control
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Uniform Availability Control'),
                  const SizedBox(height: 8),
                  Text(
                    'Manage availability for all spots in this lot',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () => _updateAllSpotsStatus(
                                  spots,
                                  SpotStatus.available,
                                ),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Set All Available'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isSubmitting
                          ? null
                          : () => _updateAllSpotsStatus(
                              spots,
                              SpotStatus.archived,
                            ),
                      icon: const Icon(Icons.archive),
                      label: const Text('Set All Archived'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Spot List
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Spots in this Lot'),
                  const SizedBox(height: 12),
                  ...spots.map(
                    (spot) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SpotListItem(spot: spot),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateAllSpotPricing(List<ParkingSpotModel> spots) {
    if (_isSubmitting) return;

    final priceHour = double.tryParse(_priceHourCtrl.text);
    final priceDay = _priceDayCtrl.text.isNotEmpty
        ? double.tryParse(_priceDayCtrl.text)
        : null;

    if (priceHour == null || priceHour < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum price is 6.00 MAD (Stripe requires at least ≈ \$0.50 USD).')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating pricing for ${spots.length} spots in the background...')),
    );

    Future(() async {
      try {
        for (final spot in spots) {
          final updatedSpot = ParkingSpotModel(
            id: spot.id,
            ownerId: spot.ownerId,
            lotId: spot.lotId,
            title: spot.title,
            description: spot.description,
            latitude: spot.latitude,
            longitude: spot.longitude,
            altitude: spot.altitude,
            street: spot.street,
            city: spot.city,
            country: spot.country,
            postalCode: spot.postalCode,
            photos: spot.photos,
            pricePerHour: priceHour,
            pricePerDay: priceDay,
            spotType: spot.spotType,
            vehicleTypes: spot.vehicleTypes,
            amenities: spot.amenities,
            status: spot.status,
            averageRating: spot.averageRating,
            totalReviews: spot.totalReviews,
            totalBookings: spot.totalBookings,
            isDynamicPricing: _dynamicPricing,
            createdAt: spot.createdAt,
            updatedAt: DateTime.now(),
          );

          await ref.read(ownerStoreProvider.notifier).updateSpot(updatedSpot);
        }
      } catch (e) {
        debugPrint('Failed to update pricing: $e');
      }
    });
  }

  void _updateAllSpotsStatus(
    List<ParkingSpotModel> spots,
    SpotStatus status,
  ) {
    if (_isSubmitting) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Setting ${spots.length} spots to ${status.toJson()} in the background...')),
    );

    Future(() async {
      try {
        for (final spot in spots) {
          final updatedSpot = ParkingSpotModel(
            id: spot.id,
            ownerId: spot.ownerId,
            lotId: spot.lotId,
            title: spot.title,
            description: spot.description,
            latitude: spot.latitude,
            longitude: spot.longitude,
            altitude: spot.altitude,
            street: spot.street,
            city: spot.city,
            country: spot.country,
            postalCode: spot.postalCode,
            photos: spot.photos,
            pricePerHour: spot.pricePerHour,
            pricePerDay: spot.pricePerDay,
            spotType: spot.spotType,
            vehicleTypes: spot.vehicleTypes,
            amenities: spot.amenities,
            status: status,
            averageRating: spot.averageRating,
            totalReviews: spot.totalReviews,
            totalBookings: spot.totalBookings,
            isDynamicPricing: spot.isDynamicPricing,
            createdAt: spot.createdAt,
            updatedAt: DateTime.now(),
          );

          await ref.read(ownerStoreProvider.notifier).updateSpot(updatedSpot);
        }
      } catch (e) {
        debugPrint('Failed to update status: $e');
      }
    });
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: context.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotListItem extends StatelessWidget {
  const _SpotListItem({required this.spot});

  final ParkingSpotModel spot;

  @override
  Widget build(BuildContext context) {
    Color statusColor() {
      return switch (spot.status) {
        SpotStatus.available => AppColors.success,
        SpotStatus.archived => AppColors.textTertiaryLight,
        SpotStatus.suspended => AppColors.error,
        _ => context.colorScheme.textSecondary,
      };
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.local_parking, color: statusColor(), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spot.title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${spot.pricePerHour.toStringAsFixed(0)} MAD/h',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              spot.status.toJson(),
              style: context.textTheme.labelSmall?.copyWith(
                color: statusColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
