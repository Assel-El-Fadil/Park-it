import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/repositories/parking_spot_repository.dart';
import 'package:src/modules/navigation/widgets/time_selection_bar.dart';
import 'package:src/providers/booking_time_provider.dart';

final parkingSearchResultsProvider = FutureProvider.family<List<ParkingSpotModel>, String>((ref, cityQuery) async {
  final repo = ref.read(parkingSpotRepositoryProvider);
  final bookingTime = ref.watch(bookingTimeProvider);
  return repo.searchAvailableByCity(
    cityQuery,
    bookingTime.arriveTime,
    bookingTime.exitTime,
  );
});

class ParkingResultsScreen extends ConsumerWidget {
  final String cityQuery;

  const ParkingResultsScreen({super.key, required this.cityQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotsAsyncValue = ref.watch(parkingSearchResultsProvider(cityQuery));
    final duration = ref.watch(bookingTimeProvider).durationHours;

    return Scaffold(
      appBar: AppBar(
        title: Text('Parking in $cityQuery'),
      ),
      body: Column(
        children: [
          const TimeSelectionBar(),
          Expanded(
            child: spotsAsyncValue.when(
              data: (spots) {
                if (spots.isEmpty) {
                  return Center(
                    child: Text(
                      'No parking spots found in $cityQuery.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: spots.length,
                  itemBuilder: (context, index) {
                    final spot = spots[index];
                    final total = spot.pricePerHour * duration;
                    return ListTile(
                      leading: const Icon(Icons.local_parking),
                      title: Text(spot.title),
                      subtitle: Text('\$${total.toStringAsFixed(2)} for $duration hours - ${spot.street ?? "Unknown street"}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        AppNavigator.pushNamed(
                          context,
                          NavigationRoutes.parkingMap,
                          extra: [spot],
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
