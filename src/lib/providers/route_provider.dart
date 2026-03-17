// lib/modules/navigation/providers/route_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:src/modules/navigation/models/route_model.dart';

class RouteNotifier extends AsyncNotifier<RouteModel?> {
  @override
  Future<RouteModel?> build() async => null;

  Future<void> fetchRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    state = const AsyncValue.loading();

    try {
      // OSRM public API — free, no key needed
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving'
        '/$originLng,$originLat;$destLng,$destLat'
        '?overview=full&geometries=geojson&steps=true',
      );

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok') throw Exception('OSRM error: ${data['code']}');

      final route = data['routes'][0];
      final leg = route['legs'][0];

      // GeoJSON coordinates are [lng, lat] — flip them for latlong2
      final coordinates = route['geometry']['coordinates'] as List;
      final points = coordinates
          .map((c) => LatLng(c[1] as double, c[0] as double))
          .toList();

      final distanceKm = (leg['distance'] as num) / 1000;
      final durationMin = (leg['duration'] as num) / 60;

      state = AsyncValue.data(
        RouteModel(
          points: points,
          distanceText: distanceKm < 1
              ? '${(distanceKm * 1000).toStringAsFixed(0)} m'
              : '${distanceKm.toStringAsFixed(1)} km',
          durationText: durationMin < 60
              ? '${durationMin.ceil()} min'
              : '${(durationMin / 60).floor()} h ${(durationMin % 60).ceil()} min',
        ),
      );
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

final routeProvider = AsyncNotifierProvider<RouteNotifier, RouteModel?>(
  RouteNotifier.new,
);
