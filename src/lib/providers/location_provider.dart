import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:src/modules/navigation/models/location_model.dart';

class LocationNotifier extends Notifier<AsyncValue<LocationModel>> {
  StreamSubscription<Position>? _positionStream;

  @override
  AsyncValue<LocationModel> build() {
    ref.onDispose(() => stopTracking());
    return const AsyncValue.loading();
  }

  double? distanceTo(double targetLat, double targetLng) {
    if (!state.hasValue) return null;
    final current = state.value!;
    return Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      targetLat,
      targetLng,
    );
  }

  double? distanceInKm(double lat, double lng) {
    final d = distanceTo(lat, lng);
    return d == null ? null : d / 1000;
  }

  String? distanceLabel(double lat, double lng) {
    final meters = distanceTo(lat, lng);
    if (meters == null) return null;
    return meters < 1000
        ? "${meters.toStringAsFixed(0)} m"
        : "${(meters / 1000).toStringAsFixed(2)} km";
  }

  double? bearingTo(double targetLat, double targetLng) {
    if (!state.hasValue) return null;
    final current = state.value!;
    return Geolocator.bearingBetween(
      current.latitude,
      current.longitude,
      targetLat,
      targetLng,
    );
  }

  bool isWithinRadius(double targetLat, double targetLng, double radiusMeters) {
    final d = distanceTo(targetLat, targetLng);
    return d != null && d <= radiusMeters;
  }

  List<LocationModel> filterNearby(
    List<LocationModel> spots,
    double radiusMeters,
  ) => spots
      .where((s) => isWithinRadius(s.latitude, s.longitude, radiusMeters))
      .toList();

  List<LocationModel> sortByDistance(List<LocationModel> spots) =>
      spots..sort((a, b) {
        final d1 = distanceTo(a.latitude, a.longitude) ?? double.infinity;
        final d2 = distanceTo(b.latitude, b.longitude) ?? double.infinity;
        return d1.compareTo(d2);
      });

  LocationModel? lastKnown() => state.hasValue ? state.value : null;

  Future<bool> hasPermission() async {
    final p = await Geolocator.checkPermission();
    return p == LocationPermission.whileInUse || p == LocationPermission.always;
  }

  Future<bool> isLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    return hasPermission();
  }

  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      final permission = await _ensurePermission();
      if (!permission) throw Exception("Location permission denied");

      final position = await Geolocator.getCurrentPosition();
      state = AsyncValue.data(
        LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void startTracking({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 5,
  }) {
    _positionStream?.cancel();
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: accuracy,
            distanceFilter: distanceFilter,
          ),
        ).listen(
          (position) => state = AsyncValue.data(
            LocationModel(
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          ),
          onError: (Object e, StackTrace stack) =>
              state = AsyncValue.error(e, stack),
        );
  }

  void stopTracking() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  bool get isTracking => _positionStream != null;

  String? compassDirection(double targetLat, double targetLng) {
    final bearing = bearingTo(targetLat, targetLng);
    if (bearing == null) return null;
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 360 + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  double? relativeHeading(
    double targetLat,
    double targetLng,
    double currentHeading,
  ) {
    final bearing = bearingTo(targetLat, targetLng);
    if (bearing == null) return null;
    double relative = (bearing - currentHeading + 360) % 360;
    if (relative > 180) relative -= 360; // keep in (-180, 180]
    return relative;
  }

  double? etaMinutes(
    double targetLat,
    double targetLng, {
    double speedKmh = 50,
  }) {
    final km = distanceInKm(targetLat, targetLng);
    if (km == null || speedKmh <= 0) return null;
    return (km / speedKmh) * 60;
  }

  String? etaLabel(double targetLat, double targetLng, {double speedKmh = 50}) {
    final minutes = etaMinutes(targetLat, targetLng, speedKmh: speedKmh);
    if (minutes == null) return null;
    if (minutes < 60) return "${minutes.ceil()} min";
    final h = minutes ~/ 60;
    final m = (minutes % 60).ceil().toString().padLeft(2, '0');
    return "$h h $m min";
  }

  LocationModel? midpointTo(double targetLat, double targetLng) {
    if (!state.hasValue) return null;
    final current = state.value!;

    // Accurate spherical midpoint
    final lat1 = _toRad(current.latitude);
    final lon1 = _toRad(current.longitude);
    final lat2 = _toRad(targetLat);
    final dLon = _toRad(targetLng - current.longitude);

    final bx = math.cos(lat2) * math.cos(dLon);
    final by = math.cos(lat2) * math.sin(dLon);

    final midLat = math.atan2(
      math.sin(lat1) + math.sin(lat2),
      math.sqrt((math.cos(lat1) + bx) * (math.cos(lat1) + bx) + by * by),
    );
    final midLon = lon1 + math.atan2(by, math.cos(lat1) + bx);

    return LocationModel(latitude: _toDeg(midLat), longitude: _toDeg(midLon));
  }

  ({double minLat, double maxLat, double minLng, double maxLng})? boundingBox(
    List<LocationModel> spots,
  ) {
    if (spots.isEmpty) return null;
    double minLat = spots.first.latitude;
    double maxLat = spots.first.latitude;
    double minLng = spots.first.longitude;
    double maxLng = spots.first.longitude;

    for (final s in spots) {
      if (s.latitude < minLat) minLat = s.latitude;
      if (s.latitude > maxLat) maxLat = s.latitude;
      if (s.longitude < minLng) minLng = s.longitude;
      if (s.longitude > maxLng) maxLng = s.longitude;
    }
    return (minLat: minLat, maxLat: maxLat, minLng: minLng, maxLng: maxLng);
  }

  LocationModel? closestFrom(List<LocationModel> spots) {
    if (spots.isEmpty || !state.hasValue) return null;
    return sortByDistance(List.of(spots)).first;
  }

  LocationModel? furthestFrom(List<LocationModel> spots) {
    if (spots.isEmpty || !state.hasValue) return null;
    return sortByDistance(List.of(spots)).last;
  }

  Future<bool> _ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  double _toRad(double deg) => deg * math.pi / 180;
  double _toDeg(double rad) => rad * 180 / math.pi;
}

final locationProvider =
    NotifierProvider<LocationNotifier, AsyncValue<LocationModel>>(
      LocationNotifier.new,
    );
