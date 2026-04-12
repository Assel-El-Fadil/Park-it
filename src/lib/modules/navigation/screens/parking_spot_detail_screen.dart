import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/models/availability_model.dart';
import 'package:src/modules/owner/repositories/parking_spot_repository.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/custom_appbar.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/rating_stars.dart';
import 'package:src/shared/widgets/section_header.dart';
import 'package:src/providers/booking_time_provider.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/controllers/vehicle_controller.dart';
import 'package:src/modules/reservation/repositories/reservation_repository.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/shared/widgets/photo_carousel.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/reservation/screens/reservations_screen.dart';
import 'package:src/modules/review/models/review_model.dart';
import 'package:src/modules/review/repositories/review_repository.dart';
import 'package:intl/intl.dart';
import 'package:src/modules/user/controllers/wishlist_controller.dart';

final parkingSpotDetailProvider =
    FutureProvider.family<ParkingSpotModel?, String>((ref, id) {
      final repo = ref.read(parkingSpotRepositoryProvider);
      return repo.getById(id);
    });

final spotReviewsProvider = 
    FutureProvider.family<List<ReviewModel>, String>((ref, id) {
  return ref.read(reviewRepositoryProvider).getReviewsBySpotId(int.tryParse(id) ?? 0);
});

final parkingSpotAvailabilityProvider =
    FutureProvider.family<List<AvailabilityModel>, int>((ref, spotId) async {
      final repo = ref.read(parkingSpotRepositoryProvider);
      return repo.getAvailabilities(spotId);
    });

class ParkingSpotDetailScreen extends ConsumerWidget {
  const ParkingSpotDetailScreen({super.key, required this.spotId});

  final String spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spotAsyncValue = ref.watch(parkingSpotDetailProvider(spotId));
    final duration = ref.watch(bookingTimeProvider).durationHours;

    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Spot Details',
          centerTitle: false,
          showBottomBorder: true,
          isTransparent: false,
          actions: [
            Consumer(
              builder: (context, ref, _) {
                final isSavedState = ref.watch(isSpotSavedProvider(int.tryParse(spotId) ?? 0));
                
                return isSavedState.when(
                  data: (isSaved) => IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? theme.colorScheme.primary : null,
                    ),
                    onPressed: () {
                      ref.read(wishlistNotifierProvider.notifier).toggleWishlist(int.tryParse(spotId) ?? 0);
                    },
                  ),
                  loading: () => const SizedBox(
                    width: 48,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, __) => const Icon(Icons.error_outline),
                );
              },
            ),
          ],
        ),
        body: spotAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (spot) {
            if (spot == null) {
              return const Center(child: Text('Spot not found.'));
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                  ), // padding for the bottom action bar
                  child: AppLayout(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        const SizedBox(height: 16),
                        _PhotoCarousel(theme: theme, photos: spot.photos),
                        const SizedBox(height: 12),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      spot.title.split(' - Spot ').first,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          spot.averageRating.toStringAsFixed(1),
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${spot.street ?? ""}, ${spot.city ?? ""}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoTile(
                                      title: 'Hourly rate',
                                      value:
                                          '${spot.pricePerHour.toStringAsFixed(2)} MAD/hr',
                                      valueColor: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoTile(
                                      title: 'Daily rate',
                                      value: spot.pricePerDay != null
                                          ? '${spot.pricePerDay!.toStringAsFixed(2)} MAD/d'
                                          : 'N/A',
                                      valueColor: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              if (spot.lotId != null) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      AppNavigator.pushNamed(
                                        context,
                                        NavigationRoutes.parkingLotDetail,
                                        pathParameters: {
                                          'id': spot.lotId.toString(),
                                        },
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.business_outlined,
                                      size: 20,
                                    ),
                                    label: const Text(
                                      'View Parking Lot Details',
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          theme.colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (spot.description != null &&
                            spot.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader(title: 'Description'),
                                const SizedBox(height: 8),
                                Text(
                                  spot.description!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Reviews'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  RatingStars(
                                    rating: spot.averageRating,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${spot.averageRating} • ${spot.totalReviews} reviews',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              if (spot.totalReviews > 0) ...[
                                const Divider(height: 24),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final reviewsAsync = ref.watch(
                                        spotReviewsProvider(
                                            spot.id.toString()));
                                    return reviewsAsync.when(
                                      loading: () => const Center(
                                          child: CircularProgressIndicator()),
                                      error: (err, _) =>
                                          Text('Error loading reviews: $err'),
                                      data: (reviews) {
                                        if (reviews.isEmpty) {
                                          return const SizedBox.shrink();
                                        }
                                        return ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: reviews.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(height: 24),
                                          itemBuilder: (context, index) {
                                            final r = reviews[index];
                                            final initials = r.reviewerName
                                                    ?.substring(0, 1)
                                                    .toUpperCase() ??
                                                'U';
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  child: Text(
                                                    initials,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            r.reviewerName ?? 'User',
                                                            style: theme.textTheme
                                                                .titleSmall
                                                                ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                          Text(
                                                            DateFormat('MMM d')
                                                                .format(r.createdAt),
                                                            style: theme.textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                    color: theme
                                                                        .colorScheme
                                                                        .onSurfaceVariant),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      RatingStars(
                                                          rating:
                                                              r.rating.toDouble(),
                                                          size: 12),
                                                      if (r.comment != null &&
                                                          r.comment!.isNotEmpty) ...[
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          r.comment!,
                                                          style: theme.textTheme
                                                              .bodyMedium,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AvailabilitySection(spotId: spot.id),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(spot.pricePerHour * duration).toStringAsFixed(2)} MAD',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                'total for $duration hours',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                final currentUser = ref.read(
                                  currentUserProvider,
                                );
                                if (currentUser == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please login to book a spot.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                var vehicleState = await ref
                                    .read(vehicleNotifierProvider.future);

                                if (vehicleState.vehicles.isEmpty) {
                                  // Force a refresh to ensure it's not a stale empty state
                                  vehicleState = await ref
                                      .read(vehicleNotifierProvider.notifier)
                                      .loadVehicles(currentUser.id);
                                }

                                if (vehicleState.vehicles.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please add a vehicle in your profile first.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final defaultVehicle = vehicleState.vehicles
                                    .firstWhere(
                                      (v) => v.isDefault,
                                      orElse: () => vehicleState.vehicles.first,
                                    );

                                try {
                                  // Show loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Preparing your booking...',
                                      ),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );

                                  final bookingTime = ref.read(
                                    bookingTimeProvider,
                                  );
                                  final reservationRepo = ref.read(
                                    reservationRepositoryProvider,
                                  );

                                  final reservation = await reservationRepo
                                      .createReservation(
                                        driverId: currentUser.id,
                                        spotId: spot.id,
                                        vehicleId: int.parse(defaultVehicle.id),
                                        startTime: bookingTime.arriveTime,
                                        endTime: bookingTime.exitTime,
                                        totalPrice:
                                            spot.pricePerHour * duration,
                                      );

                                  // Invalidate the reservations provider to refresh the 'My Bookings' tab
                                  ref.invalidate(userReservationsProvider);

                                  if (context.mounted) {
                                    AppNavigator.pushNamed(
                                      context,
                                      PaymentRoutes.payment,
                                      extra: reservation,
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error creating reservation: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Book Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AvailabilitySection extends ConsumerWidget {
  const _AvailabilitySection({required this.spotId});

  final int spotId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final availabilityAsync = ref.watch(
      parkingSpotAvailabilityProvider(spotId),
    );

    return availabilityAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
      data: (availabilities) {
        if (availabilities.isEmpty) return const SizedBox.shrink();

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Opening Hours'),
              const SizedBox(height: 12),
              ...availabilities
                  .where((a) => a.dayOfWeek != null && !a.isBlocked)
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            a.dayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            a.timeRange,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _PhotoCarousel extends StatelessWidget {
  const _PhotoCarousel({required this.theme, this.photos});

  final ThemeData theme;
  final List<String>? photos;

  @override
  Widget build(BuildContext context) {
    return PhotoCarousel(photos: photos ?? []);
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}