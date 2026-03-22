import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/models/availability_model.dart';
import 'package:src/modules/owner/repositories/parking_spot_repository.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/rating_stars.dart';
import 'package:src/shared/widgets/section_header.dart';
import 'package:src/providers/booking_time_provider.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/controllers/vehicle_controller.dart';
import 'package:src/modules/reservation/repositories/reservation_repository.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/core/config/routes/app_routes.dart';

final parkingSpotDetailProvider = FutureProvider.family<ParkingSpotModel?, String>((ref, id) {
  final repo = ref.read(parkingSpotRepositoryProvider);
  return repo.getById(id);
});


final parkingSpotAvailabilityProvider = FutureProvider.family<List<AvailabilityModel>, int>((ref, spotId) async {
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
                  padding: const EdgeInsets.only(bottom: 100), // padding for the bottom action bar
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
                                  'Spot Details',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48), // To balance the back arrow
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _HeroImage(theme: theme, imageUrl: spot.photos?.firstOrNull),
                        const SizedBox(height: 12),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      spot.title,
                                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star_rounded, size: 16, color: theme.colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          spot.averageRating.toStringAsFixed(1),
                                          style: theme.textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: theme.colorScheme.primary,
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
                                  Icon(Icons.location_on_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${spot.street ?? ""}, ${spot.city ?? ""}',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                                      value: '\$${spot.pricePerHour.toStringAsFixed(2)}/hr',
                                      valueColor: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoTile(
                                      title: 'Daily rate',
                                      value: spot.pricePerDay != null ? '\$${spot.pricePerDay!.toStringAsFixed(2)}/d' : 'N/A',
                                      valueColor: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (spot.description != null && spot.description!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SectionHeader(title: 'Description'),
                                const SizedBox(height: 8),
                                Text(
                                  spot.description!,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
                                  RatingStars(rating: spot.averageRating, size: 16),
                                  const SizedBox(width: 8),
                                  Text('${spot.averageRating} • ${spot.totalReviews} reviews', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                ],
                              ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      border: Border(
                        top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
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
                                '\$${(spot.pricePerHour * duration).toStringAsFixed(2)}',
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
                                final currentUser = ref.read(currentUserProvider);
                                if (currentUser == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please login to book a spot.')),
                                  );
                                  return;
                                }

                                final vehicleState = ref.read(vehicleNotifierProvider).value;
                                if (vehicleState == null || vehicleState.vehicles.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please add a vehicle in your profile first.')),
                                  );
                                  return;
                                }

                                final defaultVehicle = vehicleState.vehicles.firstWhere(
                                  (v) => v.isDefault,
                                  orElse: () => vehicleState.vehicles.first,
                                );

                                try {
                                  // Show loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Preparing your booking...'), duration: Duration(seconds: 1)),
                                  );

                                  final bookingTime = ref.read(bookingTimeProvider);
                                  final reservationRepo = ref.read(reservationRepositoryProvider);

                                  final reservation = await reservationRepo.createReservation(
                                    driverId: int.parse(currentUser.id),
                                    spotId: spot.id,
                                    vehicleId: int.parse(defaultVehicle.id),
                                    startTime: bookingTime.arriveTime,
                                    endTime: bookingTime.exitTime,
                                    totalPrice: spot.pricePerHour * duration,
                                  );

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
                                      SnackBar(content: Text('Error creating reservation: $e')),
                                    );
                                  }
                                }
                              },
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    final availabilityAsync = ref.watch(parkingSpotAvailabilityProvider(spotId));

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
              ...availabilities.map((a) => Padding(
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
                      a.isBlocked ? 'Closed' : a.timeRange,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: a.isBlocked 
                            ? theme.colorScheme.error 
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: a.isBlocked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.theme, this.imageUrl});

  final ThemeData theme;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: imageUrl != null
              ? Image.network(imageUrl!, fit: BoxFit.cover)
              : const Center(
                  child: Icon(Icons.local_parking, size: 40),
                ),
        ),
      ),
    );
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
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
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
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: valueColor),
          ),
        ],
      ),
    );
  }
}
