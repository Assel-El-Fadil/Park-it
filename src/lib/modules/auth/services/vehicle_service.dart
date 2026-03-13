import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  SupabaseClient get _client => Supabase.instance.client;

  static const String _tableName = 'vehicles';

  Future<List<Map<String, dynamic>>> getVehicles(String userId) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('owner_id', userId)
        .order('default', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> addVehicle(Map<String, dynamic> data) async {
    await _client.from(_tableName).insert(data);
  }

  Future<void> updateVehicle(String id, Map<String, dynamic> data) async {
    await _client.from(_tableName).update(data).eq('id', id);
  }

  Future<void> deleteVehicle(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }

  Future<void> setDefaultVehicle(String id, String userId) async {
    await _client
        .from(_tableName)
        .update({'default': false})
        .eq('owner_id', userId);
    await _client.from(_tableName).update({'default': true}).eq('id', id);
  }
}

final vehicleServiceProvider = Provider<VehicleService>(
  (ref) => VehicleService(),
);
