import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  // Get current location
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  // Get address from coordinates
  static Future<String> getAddressFromLatLng(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.country}';
      }
    } catch (e) {
      print('Error getting address: $e');
    }
    return 'Unknown location';
  }

  // Open in external navigation app
  static Future<void> navigateToParking(
    BuildContext context,
    double latitude,
    double longitude,
    String parkingName,
  ) async {
    final availableMaps = await MapLauncher.installedMaps;

    if (availableMaps.isEmpty) {
      // Fallback to URL launcher
      final url =
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
      return;
    }

    // Show map selection dialog
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Navigate with',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...availableMaps.map((map) {
                return ListTile(
                  leading: Image.memory(map.icon, width: 32, height: 32),
                  title: Text(map.mapName),
                  onTap: () {
                    Navigator.pop(context);
                    map.showDirections(
                      destination: Coords(latitude, longitude),
                      destinationTitle: parkingName,
                    );
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Calculate distance between two points
  static double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000; // Convert to kilometers
  }

  // Estimate driving time (rough estimate: 50 km/h average)
  static int estimateDrivingTime(double distanceKm) {
    return (distanceKm / 50 * 60).round(); // minutes
  }

  // Format duration
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      return remainingMinutes > 0
          ? '$hours hr $remainingMinutes min'
          : '$hours hr';
    }
  }
}
