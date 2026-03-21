import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';

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
        .ilike('city', '%$city%');

    return (response as List).map((e) => fromJson(e)).toList();
  }
}
