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

  /// Insert a new row (park-it.sql `parking_lots`). Returns new id.
  Future<int> insertLot({
    required int ownerId,
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    required String street,
    required String city,
    required String country,
    required String postalCode,
    List<String> photos = const <String>[],
    List<String> amenitiesDb = const <String>[],
    int? totalSpots,
  }) async {
    final res = await client.from(tableName).insert({
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'street': street,
      'city': city,
      'country': country,
      'postal_code': postalCode,
      'photos': photos,
      'amenities': amenitiesDb,
      'total_spots': totalSpots,
    }).select('id').single();
    return res['id'] as int;
  }
}
