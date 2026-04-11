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
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/shared/widgets/photo_carousel.dart';
import 'package:src/modules/admin/repositories/admin_repository.dart';
import 'package:src/core/enums/app_enums.dart';

final parkingSpotDetailProvider =
    FutureProvider.family<ParkingSpotModel?, String>((ref, id) {
      final repo = ref.read(parkingSpotRepositoryProvider);
      return repo.getById(id);
    });

final parkingSpotAvailabilityProvider =
    FutureProvider.family<List<AvailabilityModel>, int>((ref, spotId) async {
      final repo = ref.read(parkingSpotRepositoryProvider);
      return repo.getAvailabilities(spotId);
    });

class AdminSpotDetailScreen extends ConsumerStatefulWidget {
  const AdminSpotDetailScreen({super.key, required this.spotId});

  final String spotId;

  @override
  ConsumerState<AdminSpotDetailScreen> createState() => _AdminSpotDetailScreenState();
}

class _AdminSpotDetailScreenState extends ConsumerState<AdminSpotDetailScreen> {
  bool _isLoading = false;

  Future<void> _toggleStatus(ParkingSpotModel spot) async {
    setState(() => _isLoading = true);
    try {
      final newStatus = spot.status == SpotStatus.suspended
          ? SpotStatus.available
          : SpotStatus.suspended;
          
      await ref.read(adminRepositoryProvider).updateSpotStatus(
            spotId: spot.id,
            status: newStatus,
          );
      ref.invalidate(parkingSpotDetailProvider(widget.spotId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spot status updated to ${newStatus.toJson()}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spotAsyncValue = ref.watch(parkingSpotDetailProvider(widget.spotId));    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Spot Details',
          centerTitle: false,
          showBottomBorder: true,
          isTransparent: false,
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
                          Expanded(
                            child: _isLoading ? const Center(child: CircularProgressIndicator()) : FilledButton(
                              onPressed: () => _toggleStatus(spot),
                              style: FilledButton.styleFrom(
                                backgroundColor: spot.status == SpotStatus.suspended 
                                    ? Colors.green 
                                    : Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                spot.status == SpotStatus.suspended ? 'Unsuspend Spot' : 'Suspend Spot',
                                style: const TextStyle(
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