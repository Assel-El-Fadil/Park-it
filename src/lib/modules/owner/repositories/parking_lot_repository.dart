import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/modules/owner/models/parking_lot_model.dart';

final parkingLotRepositoryProvider = Provider<ParkingLotRepository>((ref) {
  return ParkingLotRepository();
});

class ParkingLotRepository extends SupabaseRepository<ParkingLotModel> {
  @override
  String get tableName => 'parking_lots';

  @override
  ParkingLotModel fromJson(Map<String, dynamic> json) =>
      ParkingLotModel.fromJson(json);

  @override
  String getItemKey(ParkingLotModel item) => item.id.toString();

  @override
  Map<String, dynamic> toJson(ParkingLotModel item) => item.toJson();
}
