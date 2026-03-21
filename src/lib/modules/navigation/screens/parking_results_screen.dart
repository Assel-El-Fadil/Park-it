import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/repositories/parking_spot_repository.dart';

final parkingSearchResultsProvider = FutureProvider.family<List<ParkingSpotModel>, String>((ref, cityQuery) async {
  final repo = ref.read(parkingSpotRepositoryProvider);
  return repo.searchByCity(cityQuery);
});

class ParkingResultsScreen extends ConsumerWidget {
  final String cityQuery;

  const ParkingResultsScreen({super.key, required this.cityQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotsAsyncValue = ref.watch(parkingSearchResultsProvider(cityQuery));

    return Scaffold(
      appBar: AppBar(
        title: Text('Parking in $cityQuery'),
      ),
      body: spotsAsyncValue.when(
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
              return ListTile(
                leading: const Icon(Icons.local_parking),
                title: Text(spot.title),
                subtitle: Text('\$${spot.pricePerHour}/hr - ${spot.street ?? "Unknown street"}'),
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
