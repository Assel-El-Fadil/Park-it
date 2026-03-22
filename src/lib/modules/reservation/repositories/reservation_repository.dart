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
}
