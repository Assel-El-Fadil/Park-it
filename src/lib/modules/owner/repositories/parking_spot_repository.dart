import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/models/availability_model.dart';

final parkingSpotRepositoryProvider = Provider<ParkingSpotRepository>((ref) {
  return ParkingSpotRepository();
});

class ParkingSpotRepository extends SupabaseRepository<ParkingSpotModel> {
  @override
  String get tableName => 'parking_spots';

  @override
  ParkingSpotModel fromJson(Map<String, dynamic> json) =>
      ParkingSpotModel.fromJson(json);

  @override
  String getItemKey(ParkingSpotModel item) => item.id.toString();

  @override
  Map<String, dynamic> toJson(ParkingSpotModel item) => item.toJson();

  Future<List<ParkingSpotModel>> searchByCity(String city) async {
    final response = await client
        .from(tableName)
        .select()
        .ilike('city', '%$city%')
        .eq('status', 'AVAILABLE');

    return (response as List).map((e) => fromJson(e)).toList();
  }

  Future<List<ParkingSpotModel>> searchAvailableByCity(
    String city,
    DateTime start,
    DateTime end,
  ) async {
    // 1. Get all available spots in the city
    final spots = await searchByCity(city);
    if (spots.isEmpty) return [];

    final spotIds = spots.map((s) => s.id).toList();

    // 2. Get spot IDs that have overlapping reservations
    final reservedResponse = await client
        .from('reservations')
        .select('spot_id')
        .filter('spot_id', 'in', spotIds)
        .lt('start_time', end.toUtc().toIso8601String())
        .gt('end_time', start.toUtc().toIso8601String())
        .filter('status', 'in', ['CONFIRMED', 'ACTIVE', 'PENDING']);

    final reservedIds =
        (reservedResponse as List).map((r) => r['spot_id'] as int).toSet();

    // 3. Fetch opening hours (availabilities)
    final availabilityResponse = await client
        .from('availabilities')
        .select()
        .filter('spot_id', 'in', spotIds);

    final allAvailabilities = (availabilityResponse as List)
        .map((a) => AvailabilityModel.fromJson(a))
        .toList();

    // Group availabilities by spotId
    final spotAvailMap = <int, List<AvailabilityModel>>{};
    for (final a in allAvailabilities) {
      spotAvailMap.putIfAbsent(a.spotId, () => []).add(a);
    }

    // 4. Filter spots
    return spots.where((spot) {
      // Must not be reserved
      if (reservedIds.contains(spot.id)) return false;

      final rules = spotAvailMap[spot.id];
      // If no availability rules are defined, show it (as per user request)
      if (rules == null || rules.isEmpty) return true;

      // Check if start and end times are within open hours
      bool isDateTimeAllowed(DateTime dt) {
        final dayOfWeek = dt.weekday % 7; // 0=Sunday to 6=Saturday
        final dayRules = rules.where((r) => r.dayOfWeek == dayOfWeek);

        // If no rule for this specific day, show it
        if (dayRules.isEmpty) return true;

        for (final rule in dayRules) {
          if (rule.isBlocked) return false;

          final open = rule.openTime.hour * 60 + rule.openTime.minute;
          final close = rule.closeTime.hour * 60 + rule.closeTime.minute;
          final current = dt.hour * 60 + dt.minute;

          if (current >= open && current <= close) return true;
        }
        return false;
      }

      // We check arrive and exit times (standard simplified check for short bookings)
      return isDateTimeAllowed(start) && isDateTimeAllowed(end);
    }).toList();
  }

  Future<List<AvailabilityModel>> getAvailabilities(int spotId) async {
    final response = await client
        .from('availabilities')
        .select()
        .eq('spot_id', spotId)
        .order('day_of_week', ascending: true);

    return (response as List).map((e) => AvailabilityModel.fromJson(e)).toList();
  }
}
