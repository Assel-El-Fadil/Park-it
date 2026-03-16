// // lib/services/navigation_service.dart
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:map_launcher/map_launcher.dart';
// import 'package:src/core/enums/app_enums.dart';
// import 'package:src/modules/navigation/models/navigation_result.dart';
// import 'package:src/modules/owner/models/parking_spot_model.dart';
// import 'package:src/modules/reservation/models/reservation_model.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:convert';
// import 'dart:math';
//  // Assuming you have this

// class NavigationService {
//   // Singleton pattern
//   static final NavigationService _instance = NavigationService._internal();
//   factory NavigationService() => _instance;
//   NavigationService._internal();

//   // Cache for last known location
//   Position? _lastKnownPosition;
//   DateTime? _lastPositionTimestamp;
//   static const Duration positionCacheDuration = Duration(minutes: 5);

//   // Error types for better handling
//   enum NavigationError {
//     locationServicesDisabled,
//     permissionDenied,
//     permissionDeniedForever,
//     locationNotFound,
//     mapsNotAvailable,
//     networkError,
//     unknown
//   }

//   // Result class for navigation operations
//   class NavigationResult {
//     final bool success;
//     final String? message;
//     final NavigationError? error;

//     NavigationResult({required this.success, this.message, this.error});

//     factory NavigationResult.success([String? message]) => 
//         NavigationResult(success: true, message: message);
    
//     factory NavigationResult.failure(NavigationError error, [String? message]) => 
//         NavigationResult(success: false, error: error, message: message);
//   }

//   // Get current location with caching
//   Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
//     // Return cached position if valid
//     if (!forceRefresh && 
//         _lastKnownPosition != null && 
//         _lastPositionTimestamp != null &&
//         DateTime.now().difference(_lastPositionTimestamp!) < positionCacheDuration) {
//       return _lastKnownPosition;
//     }

//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw NavigationError.locationServicesDisabled;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw NavigationError.permissionDenied;
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         throw NavigationError.permissionDeniedForever;
//       }

//       // Get location with better accuracy
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10),
//       );

//       // Cache the position
//       _lastKnownPosition = position;
//       _lastPositionTimestamp = DateTime.now();

//       return position;
//     } catch (e) {
//       print('Error getting location: $e');
//       return null;
//     }
//   }

//   // Get address from coordinates with error handling
//   Future<String> getAddressFromLatLng(LatLng coordinates) async {
//     try {
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         coordinates.latitude,
//         coordinates.longitude,
//       );

//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
        
//         // Build a more comprehensive address
//         List<String> addressParts = [];
        
//         if (place.street?.isNotEmpty ?? false) {
//           addressParts.add(place.street!);
//         }
//         if (place.subLocality?.isNotEmpty ?? false) {
//           addressParts.add(place.subLocality!);
//         }
//         if (place.locality?.isNotEmpty ?? false) {
//           addressParts.add(place.locality!);
//         }
//         if (place.administrativeArea?.isNotEmpty ?? false) {
//           addressParts.add(place.administrativeArea!);
//         }
//         if (place.country?.isNotEmpty ?? false) {
//           addressParts.add(place.country!);
//         }
//         if (place.postalCode?.isNotEmpty ?? false) {
//           addressParts.add(place.postalCode!);
//         }

//         return addressParts.join(', ');
//       }
//     } 
//     // on ServiceNotFoundException {
//     //   return 'Location services not available';
//     // } 
//     catch (e) {
//       print('Error getting address: $e');
//     }
//     return 'Address unavailable';
//   }

//   // Navigate to parking spot using reservation
//   Future<NavigationResult> navigateToParkingFromReservation(
//     BuildContext context,
//     ReservationModel reservation,
//     ParkingSpotModel parkingSpot, // You'll need this model
//   ) async {
//     try {
//       // Check if navigation is needed based on reservation status
//       if (!_shouldEnableNavigation(reservation)) {
//         return NavigationResult.failure(
//           NavigationError.unknown,
//         );
//       }

//       // Get available maps
//       final availableMaps = await MapLauncher.installedMaps;

//       if (availableMaps.isEmpty) {
//         // Fallback to browser
//         // return await _openInBrowserNavigation(
//         //   parkingSpot.latitude,
//         //   parkingSpot.longitude,
//         //   parkingSpot.name,
//         // );
//       }

//       // Get current location for distance calculation
//       final currentLocation = await getCurrentLocation();
      
//       // Calculate distance and ETA
//       String? distanceInfo;
//       if (currentLocation != null) {
//         final distance = calculateDistance(
//           currentLocation.latitude,
//           currentLocation.longitude,
//           parkingSpot.latitude,
//           parkingSpot.longitude,
//         );
        
//         final eta = estimateTravelTime(distance, TravelMode.driving);
//         distanceInfo = '${distance.toStringAsFixed(1)} km • $eta';
//       }

//       // Show enhanced map selection dialog
//       final selected = await _showMapSelectionDialog(
//         context,
//         availableMaps,
//         parkingSpot,
//         distanceInfo,
//         reservation,
//       );

//       if (selected != null) {
//         // await selected.showDirections(
//         //   destination: Coords(parkingSpot.latitude, parkingSpot.longitude),
//         //   destinationTitle: parkingSpot.name,
//         //   directionsMode: DirectionsMode.driving,
//         // );
        
//         return NavigationResult.success();
//       }

//       return NavigationResult.failure(
//         NavigationError.unknown,
//       );
//     } catch (e) {
//       return NavigationResult.failure(
//         NavigationError.unknown,
//       );
//     }
//   }

//   // Navigate directly to coordinates
//   Future<NavigationResult> navigateToCoordinates(
//     BuildContext context, {
//     required double latitude,
//     required double longitude,
//     required String locationName,
//     String? address,
//   }) async {
//     try {
//       final availableMaps = await MapLauncher.installedMaps;

//       if (availableMaps.isEmpty) {
//         return await _openInBrowserNavigation(latitude, longitude, locationName);
//       }

//       final selected = await _showSimpleMapSelectionDialog(
//         context,
//         availableMaps,
//         latitude,
//         longitude,
//         locationName,
//         address,
//       );

//       if (selected != null) {
//         await selected.showDirections(
//           destination: Coords(latitude, longitude),
//           destinationTitle: locationName,
//           directionsMode: DirectionsMode.driving,
//         );
//         return NavigationResult.success();
//       }

//       return NavigationResult.failure(
//         NavigationError.unknown,
//       );
//     } catch (e) {
//       return NavigationResult.failure(
//         NavigationError.unknown,
//       );
//     }
//   }

//   // Check if navigation should be enabled for reservation
//   bool _shouldEnableNavigation(ReservationModel reservation) {
//     final now = DateTime.now();
    
//     // Enable navigation for:
//     // - Active reservations
//     // - Confirmed reservations within 2 hours of start time
//     // - Pending reservations within 1 hour of start time (if they're about to start)
    
//     if (reservation.isActive) {
//       return true;
//     }
    
//     if (reservation.status == ReservationStatus.confirmed) {
//       final timeUntilStart = reservation.startTime.difference(now);
//       return timeUntilStart.inHours <= 2 && timeUntilStart.inHours >= 0;
//     }
    
//     if (reservation.status == ReservationStatus.pending) {
//       final timeUntilStart = reservation.startTime.difference(now);
//       return timeUntilStart.inHours <= 1 && timeUntilStart.inHours >= 0;
//     }
    
//     return false;
//   }

//   // Enhanced map selection dialog for reservations
//   Future<AvailableMap?> _showMapSelectionDialog(
//     BuildContext context,
//     List<AvailableMap> maps,
//     ParkingSpotModel parkingSpot,
//     String? distanceInfo,
//     ReservationModel reservation,
//   ) async {
//     return showModalBottomSheet<AvailableMap>(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header with parking info
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor.withOpacity(0.1),
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Navigate to Parking Spot',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "parkingSpot.name",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     if (distanceInfo != null) ...[
//                       const SizedBox(height: 4),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.green.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Text(
//                           distanceInfo,
//                           style: const TextStyle(
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                     const SizedBox(height: 8),
//                     _buildReservationTimeInfo(reservation),
//                   ],
//                 ),
//               ),
              
//               // Map list
//               ...maps.map((map) {
//                 return ListTile(
//                   leading: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Image.memory(
//                       base64Decode(map.icon),
//                       width: 32,
//                       height: 32,
//                     ),
//                   ),
//                   title: Text(
//                     map.mapName,
//                     style: const TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   subtitle: Text('Open in ${map.mapName}'),
//                   onTap: () => Navigator.pop(context, map),
//                 );
//               }).toList(),
              
//               // Cancel button
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Simple map selection dialog for general navigation
//   Future<AvailableMap?> _showSimpleMapSelectionDialog(
//     BuildContext context,
//     List<AvailableMap> maps,
//     double latitude,
//     double longitude,
//     String locationName,
//     String? address,
//   ) async {
//     return showModalBottomSheet<AvailableMap>(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Navigate to',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       locationName,
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     if (address != null) ...[
//                       const SizedBox(height: 4),
//                       Text(
//                         address,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               ...maps.map((map) {
//                 return ListTile(
//                   leading: Image.memory(
//                     base64Decode(map.icon),
//                     width: 32,
//                     height: 32,
//                   ),
//                   title: Text(map.mapName),
//                   onTap: () => Navigator.pop(context, map),
//                 );
//               }).toList(),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Cancel'),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // Build reservation time information
//   Widget _buildReservationTimeInfo(ReservationModel reservation) {
//     final now = DateTime.now();
//     final timeUntilStart = reservation.startTime.difference(now);
//     final timeUntilEnd = reservation.endTime.difference(now);
    
//     String timeInfo;
//     Color color = Colors.blue;
    
//     if (reservation.isActive) {
//       if (timeUntilEnd.inMinutes < 30) {
//         timeInfo = 'Ending soon (${timeUntilEnd.inMinutes} min left)';
//         color = Colors.orange;
//       } else {
//         timeInfo = 'Active until ${_formatTime(reservation.endTime)}';
//         color = Colors.green;
//       }
//     } else if (reservation.startTime.isAfter(now)) {
//       if (timeUntilStart.inHours < 1) {
//         timeInfo = 'Starts in ${timeUntilStart.inMinutes} minutes';
//         color = Colors.orange;
//       } else {
//         timeInfo = 'Starts at ${_formatTime(reservation.startTime)}';
//         color = Colors.blue;
//       }
//     } else {
//       return const SizedBox.shrink();
//     }
    
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Text(
//         timeInfo,
//         style: TextStyle(
//           color: color,
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   // Open in browser as fallback
//   Future<NavigationResult> _openInBrowserNavigation(
//     double latitude,
//     double longitude,
//     String locationName,
//   ) async {
//     // final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_place_id=$locationName';
//     // final appleMapsUrl = 'http://maps.apple.com/?daddr=$latitude,$longington&q=$locationName';
    
//     // Try Apple Maps first on iOS, Google Maps on Android
//     // if (Theme.of(navigatorKey.currentContext!).platform == TargetPlatform.iOS) {
//     //   if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
//     //     await launchUrl(Uri.parse(appleMapsUrl));
//     //     return NavigationResult.success();
//     //   }
//     // }
    
//     // if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
//     //   await launchUrl(Uri.parse(googleMapsUrl));
//     //   return NavigationResult.success();
//     // }
    
//     return NavigationResult.failure(
//       NavigationError.mapsNotAvailable,
//     );
//   }

//   // Calculate distance between two points (Haversine formula)
//   static double calculateDistance(
//     double startLat,
//     double startLng,
//     double endLat,
//     double endLng,
//   ) {
//     return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) / 1000;
//   }

//   // Get travel time based on mode
//   static String estimateTravelTime(double distanceKm, TravelMode mode) {
//     double speedKmh;
    
//     switch (mode) {
//       case TravelMode.driving:
//         speedKmh = 50; // Average city driving speed
//         break;
//       case TravelMode.walking:
//         speedKmh = 5; // Average walking speed
//         break;
//       case TravelMode.bicycling:
//         speedKmh = 15; // Average cycling speed
//         break;
//       case TravelMode.transit:
//         speedKmh = 30; // Average public transit speed
//         break;
//     }
    
//     final minutes = (distanceKm / speedKmh * 60).round();
//     return formatDuration(minutes);
//   }

//   // Enhanced duration formatting
//   static String formatDuration(int minutes) {
//     if (minutes < 1) {
//       return 'Less than a minute';
//     } else if (minutes < 60) {
//       return '$minutes min';
//     } else {
//       int hours = minutes ~/ 60;
//       int remainingMinutes = minutes % 60;
      
//       if (remainingMinutes == 0) {
//         return '$hours ${hours == 1 ? 'hour' : 'hours'}';
//       } else {
//         return '$hours ${hours == 1 ? 'hour' : 'hours'} $remainingMinutes min';
//       }
//     }
//   }

//   // Format time for display
//   static String _formatTime(DateTime time) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final timeDate = DateTime(time.year, time.month, time.day);
    
//     if (timeDate == today) {
//       return 'Today ${_formatTimeOfDay(time)}';
//     } else if (timeDate == today.add(const Duration(days: 1))) {
//       return 'Tomorrow ${_formatTimeOfDay(time)}';
//     } else {
//       return '${time.day}/${time.month} ${_formatTimeOfDay(time)}';
//     }
//   }

//   static String _formatTimeOfDay(DateTime time) {
//     final hour = time.hour.toString().padLeft(2, '0');
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '$hour:$minute';
//   }

//   // Show location permission dialog
//   static Future<void> showLocationPermissionDialog(BuildContext context) async {
//     return showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Location Access Required'),
//         content: const Text(
//           'To navigate to parking spots, we need access to your location. '
//           'Please enable location services in settings.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Geolocator.openLocationSettings();
//             },
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Check if user is near parking spot
//   Future<bool> isUserNearParkingSpot(
//     double spotLat,
//     double spotLng, {
//     double radiusMeters = 100,
//   }) async {
//     final currentLocation = await getCurrentLocation();
//     if (currentLocation == null) return false;
    
//     final distance = Geolocator.distanceBetween(
//       currentLocation.latitude,
//       currentLocation.longitude,
//       spotLat,
//       spotLng,
//     );
    
//     return distance <= radiusMeters;
//   }

//   // Get walking directions to spot (for last mile navigation)
//   Future<NavigationResult> getWalkingDirections(
//     BuildContext context,
//     double spotLat,
//     double spotLng,
//     String spotName,
//   ) async {
//     final currentLocation = await getCurrentLocation();
//     if (currentLocation == null) {
//       return NavigationResult.failure(
//         NavigationError.locationNotFound,

//       );
//     }
    
//     final distance = Geolocator.distanceBetween(
//       currentLocation.latitude,
//       currentLocation.longitude,
//       spotLat,
//       spotLng,
//     );
    
//     // If very close, show walking directions
//     if (distance < 500) { // Within 500 meters
//       return navigateToCoordinates(
//         context,
//         latitude: spotLat,
//         longitude: spotLng,
//         locationName: spotName,
//         address: 'You are ${distance.round()}m away',
//       );
//     }
    
//     return NavigationResult.failure(
//       NavigationError.unknown,
//     );
//   }
// }

// // Travel mode enum
// enum TravelMode {
//   driving,
//   walking,
//   bicycling,
//   transit
// }




