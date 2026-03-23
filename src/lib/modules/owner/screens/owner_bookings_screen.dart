import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final ownerId = int.tryParse(currentUser?.id ?? '') ?? 1;

    final spots = ref.watch(
      ownerStoreProvider.select((s) => s.spots.where((p) => p.ownerId == ownerId).toList()),
    );
    final ownedSpotIds = spots.map((s) => s.id).toSet();

    final reservations = ref.watch(
      ownerStoreProvider.select((s) => s.reservations
          .where((r) => ownedSpotIds.contains(r.spotId))
          .toList()),
    );

    final now = DateTime.now();
    final upcoming = reservations.where((r) => r.endTime.isAfter(now)).toList();

    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            if (upcoming.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Center(
                  child: Text(
                    'No upcoming reservations.',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...upcoming.map(
                (r) => _ReservationCard(
                  reservation: r,
                  spotsById: {for (final s in spots) s.id: s},
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.spotsById,
  });

  final ReservationModel reservation;
  final Map<int, ParkingSpotModel> spotsById;

  @override
  Widget build(BuildContext context) {
    final spot = spotsById[reservation.spotId];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (spot?.title ?? 'Parking spot'),
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${reservation.startTime} - ${reservation.endTime}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InlineChip(
                icon: Icons.calendar_month_outlined,
                label: reservation.status.name.toUpperCase(),
              ),
              const SizedBox(width: 8),
              _InlineChip(
                icon: Icons.attach_money,
                label: '${reservation.totalPrice.toStringAsFixed(0)}',
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Spot details',
                onPressed: () {
                  if (spot == null) return;
                  context.pushNamed(
                    OwnerRoutes.parkingSpaceDetail,
                    pathParameters: {'id': spot.id.toString()},
                  );
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineChip extends StatelessWidget {
  const _InlineChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

