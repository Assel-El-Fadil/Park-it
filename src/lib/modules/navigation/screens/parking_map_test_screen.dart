import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';

class ParkingMapTestScreen extends ConsumerWidget {
  const ParkingMapTestScreen({super.key});

  static final List<ParkingSpotModel> _testSpots = [
    ParkingSpotModel(
      id: 1,
      ownerId: '101',
      title: 'Jemaa el-Fna Parking',
      description: 'Central parking right next to the famous square.',
      latitude: 31.6258,
      longitude: -7.9892,
      street: 'Place Jemaa el-Fna',
      city: 'Marrakesh',
      country: 'Morocco',
      postalCode: '40000',
      photos: ['https://picsum.photos/seed/spot1/800/500'],
      pricePerHour: 5.0,
      pricePerDay: 40.0,
      spotType: SpotType.outdoor,
      vehicleTypes: [VehicleType.car, VehicleType.motorcycle],
      amenities: [Amenity.lighting, Amenity.carWash],
      status: SpotStatus.available,
      averageRating: 4.5,
      totalReviews: 128,
      totalBookings: 340,
      isDynamicPricing: false,
      createdAt: DateTime(2023, 1, 10),
      updatedAt: DateTime(2024, 3, 5),
    ),
    ParkingSpotModel(
      id: 2,
      ownerId: '102',
      title: 'Medina Gate Garage',
      description: 'Covered multi-storey garage near Bab Doukkala.',
      latitude: 31.6320,
      longitude: -7.9940,
      street: 'Bab Doukkala',
      city: 'Marrakesh',
      country: 'Morocco',
      postalCode: '40000',
      photos: ['https://picsum.photos/seed/spot2/800/500'],
      pricePerHour: 8.0,
      pricePerDay: 60.0,
      spotType: SpotType.garage,
      vehicleTypes: [VehicleType.car],
      amenities: [Amenity.lighting, Amenity.cctv, Amenity.evCharger],
      status: SpotStatus.available,
      averageRating: 4.2,
      totalReviews: 85,
      totalBookings: 210,
      isDynamicPricing: true,
      createdAt: DateTime(2023, 3, 15),
      updatedAt: DateTime(2024, 2, 20),
    ),
    ParkingSpotModel(
      id: 3,
      ownerId: '103',
      title: 'Gueliz City Parking',
      description: 'Open-air lot in the heart of the new city.',
      latitude: 31.6380,
      longitude: -8.0100,
      street: 'Avenue Mohammed V',
      city: 'Marrakesh',
      country: 'Morocco',
      postalCode: '40020',
      photos: ['https://picsum.photos/seed/spot3/800/500'],
      pricePerHour: 4.0,
      pricePerDay: 30.0,
      spotType: SpotType.outdoor,
      vehicleTypes: [VehicleType.car, VehicleType.van],
      amenities: [Amenity.lighting],
      status: SpotStatus.occupied,
      averageRating: 3.8,
      totalReviews: 52,
      totalBookings: 150,
      isDynamicPricing: false,
      createdAt: DateTime(2023, 5, 1),
      updatedAt: DateTime(2024, 1, 12),
    ),
    ParkingSpotModel(
      id: 4,
      ownerId: '104',
      title: 'Majorelle Garden Spot',
      description: 'Quiet reserved lot a short walk from Majorelle Garden.',
      latitude: 31.6420,
      longitude: -8.0030,
      street: 'Rue Yves Saint Laurent',
      city: 'Marrakesh',
      country: 'Morocco',
      postalCode: '40090',
      photos: ['https://picsum.photos/seed/spot4/800/500'],
      pricePerHour: 6.0,
      pricePerDay: 45.0,
      spotType: SpotType.covered,
      vehicleTypes: [VehicleType.car],
      amenities: [Amenity.lighting, Amenity.carWash, Amenity.cctv],
      status: SpotStatus.reserved,
      averageRating: 4.7,
      totalReviews: 200,
      totalBookings: 500,
      isDynamicPricing: true,
      createdAt: DateTime(2022, 11, 20),
      updatedAt: DateTime(2024, 3, 1),
    ),
    ParkingSpotModel(
      id: 5,
      ownerId: '105',
      title: 'Palais Royal Underground',
      description: 'Secure underground parking near the Royal Palace.',
      latitude: 31.6185,
      longitude: -7.9865,
      street: 'Rue de la Kasbah',
      city: 'Marrakesh',
      country: 'Morocco',
      postalCode: '40000',
      photos: ['https://picsum.photos/seed/spot5/800/500'],
      pricePerHour: 10.0,
      pricePerDay: 80.0,
      spotType: SpotType.street,
      vehicleTypes: [VehicleType.car, VehicleType.motorcycle],
      amenities: [Amenity.lighting, Amenity.carWash, Amenity.cctv],
      status: SpotStatus.available,
      averageRating: 4.9,
      totalReviews: 310,
      totalBookings: 720,
      isDynamicPricing: true,
      createdAt: DateTime(2022, 8, 5),
      updatedAt: DateTime(2024, 3, 10),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parking Map Test')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_testSpots.length} test spots loaded',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ..._testSpots.map(
              (s) => Text(
                '• ${s.title}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => {
                AppNavigator.pushNamed(
                  context,
                  NavigationRoutes.parkingMap,
                  extra: _testSpots,
                ),
              },
              icon: const Icon(Icons.map_rounded),
              label: const Text('Open Parking Map'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
