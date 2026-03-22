import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/repositories/parking_spot_repository.dart';
import 'package:src/modules/navigation/widgets/time_selection_bar.dart';
import 'package:src/providers/booking_time_provider.dart';

import 'package:src/providers/location_provider.dart';

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
  final location = ref.watch(locationProvider).value;

  final spots = await repo.searchAvailableByCity(
    cityQuery,
    bookingTime.arriveTime,
    bookingTime.exitTime,
  );

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

