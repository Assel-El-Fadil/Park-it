import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/modules/payment/models/payment_model.dart';

class PaymentRepositoryCloud extends SupabaseRepository<ParkingBooking> {
  @override
  String get tableName => 'payment';

  @override
  ParkingBooking fromJson(Map<String, dynamic> json) {
    // TODO: implement fromJson
    throw UnimplementedError();
  }

  @override
  Future<ParkingBooking?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  String getItemKey(ParkingBooking item) {
    // TODO: implement getItemKey
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson(ParkingBooking item) {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
