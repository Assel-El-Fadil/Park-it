import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/modules/review/models/review_model.dart';
import 'package:src/modules/review/routes/review_routes.dart';

class OwnerParkingSpaceDetailScreen extends ConsumerWidget {
  const OwnerParkingSpaceDetailScreen({
    super.key,
    required this.parkingSpaceId,
  });

  final String parkingSpaceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotId = int.tryParse(parkingSpaceId) ?? -1;

    final spot = ref.watch(
      ownerStoreProvider.select(
        (s) => s.spots.where((p) => p.id == spotId).firstOrNull,
      ),
    );

    final reviews = ref.watch(
      ownerStoreProvider.select((s) => s.reviewsBySpotId[spotId] ?? const []),
    );

    if (spot == null) {
      return const Scaffold(
        body: Center(
          child: Text('Parking spot not found.'),
        ),
      );
    }

    final statusColor = switch (spot.status) {
      SpotStatus.available => AppColors.success,
      SpotStatus.archived => AppColors.textTertiaryLight,
      SpotStatus.suspended => AppColors.error,
      _ => context.colorScheme.textSecondary,
    };

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spot details'),
          actions: [
            IconButton(
              tooltip: 'Edit',
              onPressed: () => context.pushNamed(
                OwnerRoutes.editParkingSpace,
                pathParameters: {'id': parkingSpaceId},
              ),
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot.title,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${spot.street ?? ''}, ${spot.city ?? ''} • ${spot.country ?? ''} ${spot.postalCode ?? ''}'.trim(),
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(
                          label: spot.spotType.toJson(),
                          icon: Icons.category_outlined,
                        ),
                        _Chip(
                          label: spot.status.toJson(),
                          icon: Icons.circle,
                          color: statusColor,
                        ),
                        _Chip(
                          label:
                              '${spot.pricePerHour.toStringAsFixed(0)} /h',
                          icon: Icons.attach_money,
                        ),
                        if (spot.pricePerDay != null)
                          _Chip(
                            label:
                                '${spot.pricePerDay!.toStringAsFixed(0)} /day',
                            icon: Icons.calendar_today_outlined,
                          ),
                        _Chip(
                          label:
                              '${spot.averageRating.toStringAsFixed(1)} (${spot.totalReviews})',
                          icon: Icons.star,
                          color: AppColors.accentDark,
                        ),
                        _Chip(
                          label: '${spot.totalBookings} bookings',
                          icon: Icons.bookmark_added_outlined,
                        ),
                        if (spot.isDynamicPricing)
                          const _Chip(
                            label: 'Dynamic pricing',
                            icon: Icons.bolt,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      spot.description ?? '',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.pushNamed(
                              OwnerRoutes.ownerAvailability,
                              pathParameters: {'id': parkingSpaceId},
                            ),
                            icon: const Icon(Icons.event_available_outlined),
                            label: const Text('Availability'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.pushNamed(
                              OwnerRoutes.ownerDynamicPricing,
                              pathParameters: {'id': parkingSpaceId},
                            ),
                            icon: const Icon(Icons.bolt_outlined),
                            label: const Text('Pricing'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amenities',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (spot.amenities ?? const [])
                          .map((a) => _Chip(label: a.toJson(), icon: Icons.check))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Supported vehicles',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (spot.vehicleTypes ?? const [])
                          .map((v) => _Chip(
                                label: v.toJson(),
                                icon: Icons.directions_car,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reviews',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (reviews.isEmpty)
                      Text(
                        'No reviews yet.',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.textSecondary,
                        ),
                      )
                    else
                      ...reviews.take(5).map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ReviewRow(
                            review: r,
                            onTap: () => context.pushNamed(
                              ReviewRoutes.reviewDetail,
                              pathParameters: {'id': r.id.toString()},
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, this.color});

  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.review,
    required this.onTap,
  });

  final ReviewModel review;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = (review.reviewerId).toString().padLeft(2, '0').substring(0, 2);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                initials,
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Reviewer',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colorScheme.textPrimary,
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.comment ?? '',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
                  if ((review.ownerReply ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Owner: ${review.ownerReply!}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
