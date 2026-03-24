import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/review/models/report_model.dart';

class AdminRepository {
  SupabaseClient get _client => Supabase.instance.client;

  /// Fetch all users who are either 'DRIVER' or 'OWNER'
  Future<List<UserModel>> getNormalUsers() async {
    try {
      final rows = await _client
          .from('users')
          .select()
          .inFilter('role', ['DRIVER', 'OWNER'])
          .order('created_at', ascending: false);
      
      return (rows as List)
          .map((e) => UserModel.fromUserRow(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to fetch users.');
    }
  }

  /// Update the suspend/ban status for a user
  Future<void> updateUserStatus({
    required String userId,
    bool? isSuspended,
    bool? isBanned,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (isSuspended != null) updates['is_suspended'] = isSuspended;
      if (isBanned != null) updates['is_banned'] = isBanned;

      if (updates.isEmpty) return;
      
      await _client.from('users').update(updates).eq('id', userId);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to update user status.');
    }
  }

  /// Fetch all parking spots across the platform
  Future<List<ParkingSpotModel>> getAllSpots() async {
    try {
      final rows = await _client
          .from('parking_spots')
          .select()
          .order('created_at', ascending: false);
      
      return (rows as List)
          .map((e) => ParkingSpotModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to fetch parking spots.');
    }
  }

  /// Fetch a single parking spot by its ID
  Future<ParkingSpotModel?> getSpotById(int id) async {
    try {
      final row = await _client
          .from('parking_spots')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (row == null) return null;
      return ParkingSpotModel.fromJson(row);
    } catch (_) {
      return null;
    }
  }

  /// Update the status of a parking spot
  Future<void> updateSpotStatus({
    required int spotId,
    required SpotStatus status,
  }) async {
    try {
      await _client
          .from('parking_spots')
          .update({'status': status.toJson()})
          .eq('id', spotId);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to update spot status.');
    }
  }

  /// Fetch all reports handling across the platform
  Future<List<ReportModel>> getAllReports() async {
    try {
      final rows = await _client
          .from('reports')
          .select()
          .order('created_at', ascending: false);
      
      return (rows as List)
          .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to fetch reports.');
    }
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});
