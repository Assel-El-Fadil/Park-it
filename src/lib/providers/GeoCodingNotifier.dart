import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:src/modules/navigation/models/location_model.dart';

class GeocodingNotifier extends Notifier<AsyncValue<LocationModel?>> {
  @override
  AsyncValue<LocationModel?> build() {
    return const AsyncValue.data(null);
  }

  /// Convert full address string → LocationModel using Nominatim API
  Future<void> getFromAddress(String address) async {
    state = const AsyncValue.loading();
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': address,
        'format': 'json',
        'limit': '1',
      });

      final response = await http.get(uri, headers: {
        'User-Agent': 'ParkItApp/1.0 (parking-app)',
        'Accept': 'application/json',
      });

      if (response.statusCode != 200) {
        debugPrint('[Geocoding] Nominatim returned ${response.statusCode}');
        state = const AsyncValue.data(null);
        return;
      }

      final List<dynamic> results = json.decode(response.body);

      if (results.isEmpty) {
        debugPrint('[Geocoding] No results for: $address');
        state = const AsyncValue.data(null);
        return;
      }

      final first = results.first;
      final lat = double.tryParse(first['lat'].toString());
      final lon = double.tryParse(first['lon'].toString());

      if (lat == null || lon == null) {
        state = const AsyncValue.data(null);
        return;
      }

      debugPrint('[Geocoding] "$address" → ($lat, $lon)');
      state = AsyncValue.data(
        LocationModel(latitude: lat, longitude: lon),
      );
    } catch (e, stack) {
      debugPrint('[Geocoding] Error: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  /// Structured address → LocationModel
  Future<void> getFromFields({
    required String street,
    required String city,
    required String country,
    String? postalCode,
  }) async {
    final address = [
      street,
      city,
      postalCode,
      country,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    await getFromAddress(address);
  }

  /// Reverse geocoding (lat/lng → readable address) using Nominatim
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'json',
      });

      final response = await http.get(uri, headers: {
        'User-Agent': 'ParkItApp/1.0 (parking-app)',
        'Accept': 'application/json',
      });

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      return data['display_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Last fetched result
  LocationModel? lastKnown() => state.value;

  /// Check if we have a valid result
  bool get hasValue => state.hasValue && state.value != null;

  /// Clear state (useful when user edits address)
  void clear() {
    state = const AsyncValue.data(null);
  }
}

final geocodingProvider =
    NotifierProvider<GeocodingNotifier, AsyncValue<LocationModel?>>(
      GeocodingNotifier.new,
    );
