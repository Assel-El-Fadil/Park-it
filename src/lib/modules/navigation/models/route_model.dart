import 'package:latlong2/latlong.dart';

class RouteModel {
  const RouteModel({
    required this.points,
    required this.distanceText,
    required this.durationText,
  });

  final List<LatLng> points;
  final String distanceText; // e.g. "3.2 km"
  final String durationText; // e.g. "8 mins"
}
