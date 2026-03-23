import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository();
});

class ReservationRepository extends SupabaseRepository<ReservationModel> {
  @override
  String get tableName => 'reservations';

  @override
  ReservationModel fromJson(Map<String, dynamic> json) =>
      ReservationModel.fromJson(json);

  @override
  String getItemKey(ReservationModel item) => item.id.toString();

  @override
  Map<String, dynamic> toJson(ReservationModel item) => item.toJson();

  Future<ReservationModel> createReservation({
    required int driverId,
    required int spotId,
    required int vehicleId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
  }) async {
    final response = await client
        .from(tableName)
        .insert({
          'driver_id': driverId,
          'spot_id': spotId,
          'vehicle_id': vehicleId,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'status': 'PENDING',
          'total_price': totalPrice,
          'platform_fee': double.parse((totalPrice * 0.15).toStringAsFixed(2)),
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    return fromJson(response);
  }

  Future<List<Map<String, dynamic>>> getReservationsWithSpots(int driverId) async {
    final response = await client
        .from(tableName)
        .select('*, parking_spots(*)')
        .eq('driver_id', driverId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getReservationWithDetails(int reservationId) async {
    final response = await client
        .from(tableName)
        .select('*, parking_spots(*), vehicles(*)')
        .eq('id', reservationId)
        .single();
    
    return response as Map<String, dynamic>;
  }

  Future<bool> canUserReviewOrReport({
    required int reservationId,
    required int driverId,
  }) async {
    final row = await client
        .from(tableName)
        .select('id, driver_id, status, end_time')
        .eq('id', reservationId)
        .maybeSingle();

    if (row == null) return false;
    final rowDriver = row['driver_id'] as int?;
    final status = (row['status'] as String?)?.toUpperCase() ?? '';
    final endTimeStr = row['end_time'] as String?;
    if (rowDriver != driverId) return false;
    if (status != 'COMPLETED') return false;
    if (endTimeStr == null) return false;
    final endTime = DateTime.parse(endTimeStr);
    return endTime.isBefore(DateTime.now());
  }

  Future<bool> hasExistingReview(int reservationId) async {
    final row = await client
        .from('reviews')
        .select('id')
        .eq('reservation_id', reservationId)
        .maybeSingle();
    return row != null;
  }

  Future<void> seedExampleCompletedReservation({
    required int driverId,
  }) async {
    final existing = await client
        .from(tableName)
        .select('id')
        .eq('driver_id', driverId)
        .eq('status', 'COMPLETED')
        .limit(1)
        .maybeSingle();
    if (existing != null) return;

    final spot = await client
        .from('parking_spots')
        .select('id,price_per_hour')
        .limit(1)
        .maybeSingle();
    if (spot == null) return;

    Map<String, dynamic>? vehicle = await client
        .from('vehicles')
        .select('id')
        .eq('owner_id', driverId)
        .limit(1)
        .maybeSingle();

    if (vehicle == null) {
      final inserted = await client
          .from('vehicles')
          .insert({
            'owner_id': driverId,
            'plate_number': 'TEST-${driverId}A',
            'type': 'CAR',
            'brand': 'TestBrand',
            'model': 'ModelX',
            'color': 'Black',
            'is_default': true,
          })
          .select('id')
          .single();
      vehicle = inserted;
    }

    final start = DateTime.now().subtract(const Duration(hours: 5));
    final end = DateTime.now().subtract(const Duration(hours: 1));
    final pricePerHour = (spot['price_per_hour'] as num?)?.toDouble() ?? 5.0;
    final total = double.parse((pricePerHour * 4).toStringAsFixed(2));
    final fee = double.parse((total * 0.15).toStringAsFixed(2));

    await client.from(tableName).insert({
      'driver_id': driverId,
      'spot_id': spot['id'] as int,
      'vehicle_id': vehicle['id'] as int,
      'start_time': start.toIso8601String(),
      'end_time': end.toIso8601String(),
      'status': 'COMPLETED',
      'total_price': total,
      'platform_fee': fee,
      'created_at': start.toIso8601String(),
      'updated_at': end.toIso8601String(),
    });
  }
}
