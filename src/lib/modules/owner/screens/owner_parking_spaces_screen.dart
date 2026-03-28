import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/shared/widgets/empty_state.dart';

class OwnerParkingSpacesScreen extends ConsumerWidget {
  const OwnerParkingSpacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final ownerId = currentUser?.id ?? '';

    final spots = ref.watch(
      ownerStoreProvider.select(
        (s) => s.spots.where((p) => p.ownerId == ownerId && p.lotId == null).toList(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Parking Spots'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(OwnerRoutes.addParkingSpace),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            if (spots.isEmpty)
              EmptyState(
                title: 'No spots yet',
                subtitle: 'Add your first parking spot to start earning.',
                icon: Icons.local_parking_outlined,
                action: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.pushNamed(OwnerRoutes.addParkingSpace),
                    child: const Text('Add parking spot'),
                  ),
                ),
              )
            else
              ...spots.map(
                (spot) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OwnerSpotCard(
                    spot: spot,
                    onTap: () => context.pushNamed(
                      OwnerRoutes.parkingSpaceDetail,
                      pathParameters: {'id': spot.id.toString()},
                    ),
                    onEdit: () => context.pushNamed(
                      OwnerRoutes.editParkingSpace,
                      pathParameters: {'id': spot.id.toString()},
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OwnerSpotCard extends StatelessWidget {
  const _OwnerSpotCard({
    required this.spot,
    required this.onTap,
    required this.onEdit,
  });

  final ParkingSpotModel spot;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  Color _statusColor(BuildContext context) {
    return switch (spot.status) {
      SpotStatus.available => AppColors.success,
      SpotStatus.archived => AppColors.textTertiaryLight,
      SpotStatus.suspended => AppColors.error,
      _ => context.colorScheme.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${spot.street ?? ''}, ${spot.city ?? ''} • ${spot.country ?? ''} ${spot.postalCode ?? ''}'.trim(),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(
                  icon: Icons.category_outlined,
                  label: spot.spotType.toJson(),
                ),
                _Badge(
                  icon: Icons.circle,
                  label: spot.status.toJson(),
                  color: statusColor,
                ),
                _Badge(
                  icon: Icons.attach_money,
                  label: '${spot.pricePerHour.toStringAsFixed(0)} MAD/h',
                ),
                if (spot.pricePerDay != null)
                  _Badge(
                    icon: Icons.calendar_today_outlined,
                    label: '${spot.pricePerDay!.toStringAsFixed(0)} MAD/day',
                  ),
                _Badge(
                  icon: Icons.star,
                  label:
                      '${spot.averageRating.toStringAsFixed(1)} (${spot.totalReviews})',
                ),
                _Badge(
                  icon: Icons.bookmark_added_outlined,
                  label: '${spot.totalBookings} bookings',
                ),
                if (spot.isDynamicPricing)
                  const _Badge(icon: Icons.bolt, label: 'Dynamic'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: effectiveColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

