import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/parking_lot_model.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/shared/widgets/empty_state.dart';

class OwnerParkingLotsScreen extends ConsumerWidget {
  const OwnerParkingLotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final ownerId = currentUser?.id ?? '';

    final lots = ref.watch(
      ownerStoreProvider.select(
        (s) => s.lots.where((p) => p.ownerId == ownerId).toList(),
      ),
    );

    final spots = ref.watch(
      ownerStoreProvider.select(
        (s) => s.spots.where((p) => p.ownerId == ownerId).toList(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Parking Lots'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Use the list below and tap a lot to open it.'),
              ),
            ),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(OwnerRoutes.addParkingSpace),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            if (lots.isEmpty)
              EmptyState(
                title: 'No lots yet',
                subtitle:
                    'Add your first parking lot to manage multiple spots efficiently.',
                icon: Icons.garage_outlined,
                action: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.pushNamed(OwnerRoutes.addParkingSpace),
                    child: const Text('Add parking lot'),
                  ),
                ),
              )
            else
              ...lots.map(
                (lot) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OwnerLotCard(
                    lot: lot,
                    spots: spots.where((s) => s.lotId == lot.id).toList(),
                    onTap: () => context.pushNamed(
                      OwnerRoutes.ownerParkingLotDetail,
                      pathParameters: {'id': lot.id.toString()},
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

class _OwnerLotCard extends StatelessWidget {
  const _OwnerLotCard({
    required this.lot,
    required this.spots,
    required this.onTap,
  });

  final ParkingLotModel lot;
  final List<ParkingSpotModel> spots;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final totalSpots = spots.length;
    final availableSpots = spots
        .where((s) => s.status == SpotStatus.available)
        .length;
    final averagePrice = totalSpots > 0
        ? spots.fold<double>(0, (sum, s) => sum + s.pricePerHour) / totalSpots
        : 0.0;

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
                        lot.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${lot.street}, ${lot.city} • ${lot.country} ${lot.postalCode}'
                            .trim(),
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.textSecondary,
                        ),
                      ),
                      if (lot.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          lot.description!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.garage_outlined, color: AppColors.primary, size: 28),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Badge(
                  icon: Icons.local_parking,
                  label: '$totalSpots spots',
                  color: AppColors.primary,
                ),
                _Badge(
                  icon: Icons.check_circle,
                  label: '$availableSpots available',
                  color: AppColors.success,
                ),
                _Badge(
                  icon: Icons.attach_money,
                  label: '${averagePrice.toStringAsFixed(0)} /h avg',
                  color: AppColors.primary,
                ),
                if (lot.totalSpots != null)
                  _Badge(
                    icon: Icons.inventory_2,
                    label: '${lot.totalSpots} capacity',
                    color: context.colorScheme.textSecondary,
                  ),
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
