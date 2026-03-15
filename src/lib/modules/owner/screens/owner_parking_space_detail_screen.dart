import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/modules/review/routes/review_routes.dart';

class OwnerParkingSpaceDetailScreen extends StatelessWidget {
  const OwnerParkingSpaceDetailScreen({
    super.key,
    required this.parkingSpaceId,
  });

  final String parkingSpaceId;

  @override
  Widget build(BuildContext context) {
    // Mocked spot aligned with park-it.sql columns (parking_spots).
    const spot = _SpotDetailModel(
      title: 'Downtown Central Plaza',
      description:
          'Premium parking located near the city center. Well-lit, easy entry.',
      street: '123 Main St',
      city: 'Rabat',
      country: 'MA',
      postalCode: '10000',
      spotType: 'COVERED',
      status: 'AVAILABLE',
      pricePerHour: 25,
      pricePerDay: 150,
      amenities: ['CCTV', 'LIGHTING', 'EV_CHARGER', 'GUARD', 'WHEELCHAIR'],
      vehicleTypes: ['CAR', 'MOTORCYCLE', 'ELECTRIC'],
      averageRating: 4.8,
      totalReviews: 250,
      totalBookings: 18,
      isDynamicPricing: true,
    );

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
                      '${spot.street}, ${spot.city} • ${spot.country} ${spot.postalCode}',
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
                          label: spot.spotType,
                          icon: Icons.category_outlined,
                        ),
                        _Chip(
                          label: spot.status,
                          icon: Icons.circle,
                          color: spot.status == 'AVAILABLE'
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        _Chip(
                          label: '${spot.pricePerHour.toStringAsFixed(0)} /h',
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
                      spot.description,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.textPrimary,
                        height: 1.4,
                      ),
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
                      children: spot.amenities
                          .map((a) => _Chip(label: a, icon: Icons.check))
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
                      children: spot.vehicleTypes
                          .map(
                            (v) => _Chip(label: v, icon: Icons.directions_car),
                          )
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
                    _ReviewRow(
                      initials: 'JD',
                      name: 'John Doe',
                      rating: 5,
                      comment: 'Easy to find, great security.',
                      onTap: () => context.pushNamed(
                        ReviewRoutes.reviewDetail,
                        pathParameters: {'id': 'r1'},
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ReviewRow(
                      initials: 'MS',
                      name: 'Mina S.',
                      rating: 4,
                      comment: 'Great location. Signage could be clearer.',
                      onTap: () => context.pushNamed(
                        ReviewRoutes.reviewDetail,
                        pathParameters: {'id': 'r2'},
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

class _SpotDetailModel {
  const _SpotDetailModel({
    required this.title,
    required this.description,
    required this.street,
    required this.city,
    required this.country,
    required this.postalCode,
    required this.spotType,
    required this.status,
    required this.pricePerHour,
    required this.pricePerDay,
    required this.amenities,
    required this.vehicleTypes,
    required this.averageRating,
    required this.totalReviews,
    required this.totalBookings,
    required this.isDynamicPricing,
  });

  final String title;
  final String description;
  final String street;
  final String city;
  final String country;
  final String postalCode;
  final String spotType;
  final String status;
  final double pricePerHour;
  final double? pricePerDay;
  final List<String> amenities;
  final List<String> vehicleTypes;
  final double averageRating;
  final int totalReviews;
  final int totalBookings;
  final bool isDynamicPricing;
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
    required this.initials,
    required this.name,
    required this.rating,
    required this.comment,
    required this.onTap,
  });

  final String initials;
  final String name;
  final int rating;
  final String comment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                          name,
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
                            i < rating ? Icons.star : Icons.star_border,
                            size: 14,
                            color: AppColors.accentDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.textSecondary,
                    ),
                  ),
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
