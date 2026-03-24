import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';

class OwnerEarningsScreen extends ConsumerWidget {
  const OwnerEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final ownerId = currentUser?.id ?? '';

    final spots = ref.watch(
      ownerStoreProvider.select((s) => s.spots.where((p) => p.ownerId == ownerId && p.lotId == null).toList()),
    );
    final ownedSpotIds = spots.map((s) => s.id).toSet();

    final reservations = ref.watch(
      ownerStoreProvider.select((s) => s.reservations
          .where((r) => ownedSpotIds.contains(r.spotId))
          .toList()),
    );

    final completed = reservations
        .where((r) => r.status == ReservationStatus.completed)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final totalPayout = completed.fold<double>(0, (sum, r) => sum + r.ownerPayout);
    final totalPlatformFee =
        completed.fold<double>(0, (sum, r) => sum + r.platformFee);
    final totalAmount = completed.fold<double>(0, (sum, r) => sum + r.totalPrice);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            _KpiCard(
              icon: Icons.monetization_on_outlined,
              label: 'Total payout',
              value: '${totalPayout.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _KpiCard(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Total amount',
              value: '${totalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _KpiCard(
              icon: Icons.payment_outlined,
              label: 'Platform fee',
              value: '${totalPlatformFee.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 20),
            Text(
              'Payouts',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (completed.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No completed reservations yet.',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...completed.map(
                (r) => _PayoutCard(
                  reservation: r,
                  spot: spots.firstWhere((s) => s.id == r.spotId),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutCard extends StatelessWidget {
  const _PayoutCard({
    required this.reservation,
    required this.spot,
  });

  final ReservationModel reservation;
  final ParkingSpotModel spot;

  @override
  Widget build(BuildContext context) {
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
            spot.title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${reservation.startTime} → ${reservation.endTime}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _InlineChip(
                icon: Icons.monetization_on_outlined,
                label: '${reservation.ownerPayout.toStringAsFixed(2)} payout',
              ),
              const SizedBox(width: 8),
              _InlineChip(
                icon: Icons.payment_outlined,
                label: '${reservation.totalPrice.toStringAsFixed(2)} total',
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Spot details',
                onPressed: () => context.pushNamed(
                  OwnerRoutes.parkingSpaceDetail,
                  pathParameters: {'id': spot.id.toString()},
                ),
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

