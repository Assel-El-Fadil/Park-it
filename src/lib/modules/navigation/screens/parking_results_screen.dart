import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/repositories/parking_spot_repository.dart';
import 'package:src/modules/navigation/widgets/time_selection_bar.dart';
import 'package:src/providers/booking_time_provider.dart';

import 'package:src/core/enums/app_enums.dart';

import 'package:src/providers/location_provider.dart';

class ParkingFilters {
  final VehicleType? vehicleType;
  final SpotType? spotType;
  final List<Amenity> amenities;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;

  ParkingFilters({
    this.vehicleType,
    this.spotType,
    this.amenities = const [],
    this.minPrice,
    this.maxPrice,
    this.minRating,
  });

  ParkingFilters copyWith({
    VehicleType? vehicleType,
    bool clearVehicleType = false,
    SpotType? spotType,
    bool clearSpotType = false,
    List<Amenity>? amenities,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool clearMinRating = false,
  }) {
    return ParkingFilters(
      vehicleType: clearVehicleType ? null : (vehicleType ?? this.vehicleType),
      spotType: clearSpotType ? null : (spotType ?? this.spotType),
      amenities: amenities ?? this.amenities,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
    );
  }

  bool get isEmpty =>
      vehicleType == null &&
      spotType == null &&
      amenities.isEmpty &&
      minPrice == null &&
      maxPrice == null &&
      minRating == null;
}

class ParkingFiltersNotifier extends Notifier<ParkingFilters> {
  @override
  ParkingFilters build() => ParkingFilters();

  void setVehicleType(VehicleType? type) => state = state.copyWith(vehicleType: type, clearVehicleType: type == null);
  void setSpotType(SpotType? type) => state = state.copyWith(spotType: type, clearSpotType: type == null);
  void setPriceRange(double min, double max) => state = state.copyWith(minPrice: min, maxPrice: max);
  void setMinRating(double? rating) => state = state.copyWith(minRating: rating, clearMinRating: rating == null);
  void toggleAmenity(Amenity amenity) {
    final amenities = List<Amenity>.from(state.amenities);
    if (amenities.contains(amenity)) {
      amenities.remove(amenity);
    } else {
      amenities.add(amenity);
    }
    state = state.copyWith(amenities: amenities);
  }

  void clearAll() => state = ParkingFilters();
}

final parkingFiltersProvider = NotifierProvider<ParkingFiltersNotifier, ParkingFilters>(() {
  return ParkingFiltersNotifier();
});

enum ParkingSort { closest, cheapest }

class ParkingSortNotifier extends Notifier<ParkingSort> {
  @override
  ParkingSort build() => ParkingSort.closest;

  void setSort(ParkingSort sort) => state = sort;
}

final parkingSortProvider = NotifierProvider<ParkingSortNotifier, ParkingSort>(() {
  return ParkingSortNotifier();
});

final parkingSearchResultsProvider = FutureProvider.family<List<ParkingSpotModel>, String>((ref, cityQuery) async {
  final repo = ref.read(parkingSpotRepositoryProvider);
  final bookingTime = ref.watch(bookingTimeProvider);
  final sort = ref.watch(parkingSortProvider);
  final filters = ref.watch(parkingFiltersProvider);
  final location = ref.watch(locationProvider).value;

  var spots = await repo.searchAvailableByCity(
    cityQuery,
    bookingTime.arriveTime,
    bookingTime.exitTime,
  );

  // Apply filters
  if (!filters.isEmpty) {
    spots = spots.where((spot) {
      if (filters.vehicleType != null && !(spot.vehicleTypes?.contains(filters.vehicleType) ?? true)) {
        return false;
      }
      if (filters.spotType != null && spot.spotType != filters.spotType) {
        return false;
      }
      if (filters.amenities.isNotEmpty) {
        for (final amenity in filters.amenities) {
          if (!(spot.amenities?.contains(amenity) ?? false)) return false;
        }
      }
      if (filters.minPrice != null && spot.pricePerHour < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null && spot.pricePerHour > filters.maxPrice!) {
        return false;
      }
      if (filters.minRating != null && spot.averageRating < filters.minRating!) {
        return false;
      }
      return true;
    }).toList();
  }

  if (sort == ParkingSort.cheapest) {
    spots.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
  } else if (sort == ParkingSort.closest && location != null) {
    final notifier = ref.read(locationProvider.notifier);
    spots.sort((a, b) {
      final d1 = notifier.distanceTo(a.latitude ?? 0, a.longitude ?? 0) ?? double.infinity;
      final d2 = notifier.distanceTo(b.latitude ?? 0, b.longitude ?? 0) ?? double.infinity;
      return d1.compareTo(d2);
    });
  }

  return spots;
});

class ParkingResultsScreen extends ConsumerStatefulWidget {
  final String cityQuery;

  const ParkingResultsScreen({super.key, required this.cityQuery});

  @override
  ConsumerState<ParkingResultsScreen> createState() => _ParkingResultsScreenState();
}

class _ParkingResultsScreenState extends ConsumerState<ParkingResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Start fetching location immediately to enable "Closest" sorting
    Future.microtask(() => ref.read(locationProvider.notifier).getCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    final spotsAsyncValue = ref.watch(parkingSearchResultsProvider(widget.cityQuery));
    final duration = ref.watch(bookingTimeProvider).durationHours;
    final theme = Theme.of(context);

    // ... updated body ...

    return Scaffold(
      appBar: AppBar(
        title: Text('Parking in ${widget.cityQuery}'),
      ),
      body: Column(
        children: [
          const TimeSelectionBar(),
          const _SortBar(),
          const _FilterBar(),
          Expanded(
            child: spotsAsyncValue.when(
              data: (spots) {
                if (spots.isEmpty) {
                  return Center(
                    child: Text(
                      'No parking spots found in ${widget.cityQuery}.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: spots.length,
                  itemBuilder: (context, index) {
                    final spot = spots[index];
                    final total = spot.pricePerHour * duration;
                    final distance = ref.read(locationProvider.notifier).distanceLabel(spot.latitude ?? 0, spot.longitude ?? 0);

                    return ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text(spot.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('\$${total.toStringAsFixed(2)} for $duration hours'),
                          if (distance != null)
                            Text('$distance away • ${spot.street ?? "Unknown street"}')
                          else
                            Text(spot.street ?? "Unknown street"),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        AppNavigator.pushNamed(
                          context,
                          NavigationRoutes.parkingSpotDetail,
                          pathParameters: {'id': spot.id.toString()},
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: spotsAsyncValue.value != null && spotsAsyncValue.value!.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                AppNavigator.pushNamed(
                  context,
                  NavigationRoutes.parkingMap,
                  extra: spotsAsyncValue.value,
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Map View'),
            )
          : null,
    );
  }
}

class _SortBar extends ConsumerWidget {
  const _SortBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(parkingSortProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Sort by',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 24),
          _SortTab(
            label: 'CLOSEST',
            isSelected: currentSort == ParkingSort.closest,
            onTap: () => ref.read(parkingSortProvider.notifier).setSort(ParkingSort.closest),
          ),
          const SizedBox(width: 16),
          _SortTab(
            label: 'CHEAPEST',
            isSelected: currentSort == ParkingSort.cheapest,
            onTap: () => ref.read(parkingSortProvider.notifier).setSort(ParkingSort.cheapest),
          ),
        ],
      ),
    );
  }
}

class _SortTab extends StatelessWidget {
  const _SortTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            )
          else
            const SizedBox(height: 3),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(parkingFiltersProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _FilterChip(
            label: 'Filters',
            icon: Icons.filter_list,
            isSelected: !filters.isEmpty,
            onTap: () => _showFilterSheet(context),
          ),
          const SizedBox(width: 8),
          if (filters.vehicleType != null) ...[
            _FilterChip(
              label: filters.vehicleType!.name.toUpperCase(),
              isSelected: true,
              onDeleted: () => ref.read(parkingFiltersProvider.notifier).setVehicleType(null),
            ),
            const SizedBox(width: 8),
          ],
          if (filters.spotType != null) ...[
            _FilterChip(
              label: filters.spotType!.name.toUpperCase(),
              isSelected: true,
              onDeleted: () => ref.read(parkingFiltersProvider.notifier).setSpotType(null),
            ),
            const SizedBox(width: 8),
          ],
          ...filters.amenities.map((amenity) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FilterChip(
              label: amenity.name.toUpperCase(),
              isSelected: true,
              onDeleted: () => ref.read(parkingFiltersProvider.notifier).toggleAmenity(amenity),
            ),
          )),
          if (filters.minPrice != null && filters.maxPrice != null) ...[
            _FilterChip(
              label: '\$${filters.minPrice!.toInt()} - \$${filters.maxPrice!.toInt()}',
              isSelected: true,
              onDeleted: () => ref.read(parkingFiltersProvider.notifier).setPriceRange(0, 50),
            ),
            const SizedBox(width: 8),
          ],
          if (filters.minRating != null) ...[
            _FilterChip(
              label: '${filters.minRating!.toInt()}+ Stars',
              icon: Icons.star,
              isSelected: true,
              onDeleted: () => ref.read(parkingFiltersProvider.notifier).setMinRating(null),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FilterSheet(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const _FilterChip({
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RawChip(
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      avatar: icon != null ? Icon(icon, size: 16, color: isSelected ? theme.colorScheme.onPrimary : null) : null,
      selected: isSelected,
      onPressed: onTap,
      onDeleted: onDeleted,
      deleteIconColor: isSelected ? theme.colorScheme.onPrimary : null,
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      shape: StadiumBorder(side: BorderSide(color: theme.dividerColor, width: 0.5)),
      showCheckmark: false,
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(parkingFiltersProvider);
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  ref.read(parkingFiltersProvider.notifier).clearAll();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterSection(
                    title: 'Vehicle Type',
                    child: Wrap(
                      spacing: 8,
                      children: VehicleType.values.map((type) => FilterChip(
                        label: Text(type.name.toUpperCase()),
                        selected: filters.vehicleType == type,
                        onSelected: (selected) => ref.read(parkingFiltersProvider.notifier).setVehicleType(selected ? type : null),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'Spot Type',
                    child: Wrap(
                      spacing: 8,
                      children: SpotType.values.map((type) => FilterChip(
                        label: Text(type.name.toUpperCase()),
                        selected: filters.spotType == type,
                        onSelected: (selected) => ref.read(parkingFiltersProvider.notifier).setSpotType(selected ? type : null),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'Amenities',
                    child: Wrap(
                      spacing: 8,
                      children: Amenity.values.map((amenity) => FilterChip(
                        label: Text(amenity.name.toUpperCase()),
                        selected: filters.amenities.contains(amenity),
                        onSelected: (selected) => ref.read(parkingFiltersProvider.notifier).toggleAmenity(amenity),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'Price Range (per hour)',
                    child: Column(
                      children: [
                        RangeSlider(
                          values: RangeValues(filters.minPrice ?? 0, filters.maxPrice ?? 50),
                          min: 0,
                          max: 50,
                          divisions: 10,
                          labels: RangeLabels(
                            '\$${(filters.minPrice ?? 0).toInt()}',
                            '\$${(filters.maxPrice ?? 50).toInt()}',
                          ),
                          onChanged: (values) {
                            ref.read(parkingFiltersProvider.notifier).setPriceRange(values.start, values.end);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$0', style: theme.textTheme.labelSmall),
                              Text('\$50', style: theme.textTheme.labelSmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'Minimum Rating',
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [1, 2, 3, 4, 5].map((rating) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$rating'),
                                const SizedBox(width: 4),
                                const Icon(Icons.star, size: 14),
                              ],
                            ),
                            selected: filters.minRating == rating.toDouble(),
                            onSelected: (selected) {
                              ref.read(parkingFiltersProvider.notifier).setMinRating(selected ? rating.toDouble() : null);
                            },
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

