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
    required String driverId,
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
          'start_time': startTime.toUtc().toIso8601String(),
          'end_time': endTime.toUtc().toIso8601String(),
          'status': 'PENDING',
          'total_price': totalPrice,
          'platform_fee': double.parse((totalPrice * 0.15).toStringAsFixed(2)),
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();

    return fromJson(response);
  }

  Future<List<Map<String, dynamic>>> getReservationsWithSpots(String driverId) async {
    final response = await client
        .from(tableName)
        .select('*, parking_spots(*)')
        .eq('driver_id', driverId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> cancelReservation(int reservationId) async {
    await client
        .from(tableName)
        .update({
          'status': 'CANCELLED',
          'updated_at': DateTime.now().toUtc().toIso8601String()
        })
        .eq('id', reservationId);
  }

  Future<Map<String, dynamic>> getReservationWithDetails(int reservationId) async {
    final response = await client
        .from(tableName)
        .select('*, parking_spots(*), vehicles(*)')
        .eq('id', reservationId)
        .single();
    
    return response as Map<String, dynamic>;
  }
}
