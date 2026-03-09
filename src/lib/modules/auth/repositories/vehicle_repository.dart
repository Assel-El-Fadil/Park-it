import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/models/vehicle_model.dart';
import 'package:src/modules/auth/services/vehicle_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class VehicleRepository {
  Future<List<VehicleModel>> getVehicles(String userId);

  Future<void> addVehicle(VehicleModel vehicle);

  Future<void> updateVehicle(VehicleModel vehicle);

  Future<void> deleteVehicle(String id);

  Future<void> setDefault(String id, String userId);
}

class VehicleRepositoryImpl implements VehicleRepository {
  VehicleRepositoryImpl(this._vehicleService);

  final VehicleService _vehicleService;

  @override
  Future<List<VehicleModel>> getVehicles(String userId) async {
    try {
      final rows = await _vehicleService.getVehicles(userId);
      return rows.map((r) => VehicleModel.fromVehicleRow(r)).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<void> addVehicle(VehicleModel vehicle) async {
    try {
      await _vehicleService.addVehicle(vehicle.toVehicleRow());
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<void> updateVehicle(VehicleModel vehicle) async {
    try {
      final data = vehicle.toVehicleRow();
      data.remove('id');
      data.remove('owner_id');
      await _vehicleService.updateVehicle(vehicle.id, data);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await _vehicleService.deleteVehicle(id);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }

  @override
  Future<void> setDefault(String id, String userId) async {
    try {
      await _vehicleService.setDefaultVehicle(id, userId);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(AppConstants.errorGeneric);
    }
  }
}

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepositoryImpl(ref.watch(vehicleServiceProvider));
});
