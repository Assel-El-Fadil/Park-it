import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/owner/models/availability_model.dart';
import 'package:src/modules/owner/models/dynamic_pricing_model.dart';
import 'package:src/modules/owner/models/parking_lot_model.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/repositories/owner_repository.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/modules/review/models/review_model.dart';

class OwnerRepositoryCloud implements OwnerRepository {
  OwnerRepositoryCloud(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ParkingSpotModel>> getOwnerSpots(int ownerId) async {
    try {
      final response = await _client
          .from('parking_spots')
          .select()
          .eq('owner_id', ownerId)
          .order('updated_at', ascending: false);

      return (response as List).map((e) {
        return ParkingSpotModel.fromJson(e as Map<String, dynamic>);
      }).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load owner parking spots.');
    }
  }

  @override
  Future<List<ParkingLotModel>> getOwnerLots(int ownerId) async {
    try {
      final response = await _client
          .from('parking_lots')
          .select()
          .eq('owner_id', ownerId)
          .order('updated_at', ascending: false);

      return (response as List).map((e) {
        return ParkingLotModel.fromJson(e as Map<String, dynamic>);
      }).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load owner parking lots.');
    }
  }

  @override
  Future<List<ReviewModel>> getReviewsForSpotIds(List<int> spotIds) async {
    if (spotIds.isEmpty) return const [];
    try {
      final response = await _client
          .from('reviews')
          .select()
          .inFilter('spot_id', spotIds)
          .order('created_at', ascending: false);

      return (response as List).map((e) {
        return ReviewModel.fromJson(e as Map<String, dynamic>);
      }).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load reviews.');
    }
  }

  @override
  Future<List<AvailabilityModel>> getAvailabilitiesForSpotIds(
    List<int> spotIds,
  ) async {
    if (spotIds.isEmpty) return const [];
    try {
      final response = await _client
          .from('availabilities')
          .select()
          .inFilter('spot_id', spotIds);

      return (response as List).map((e) {
        return AvailabilityModel.fromJson(e as Map<String, dynamic>);
      }).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load availabilities.');
    }
  }

  @override
  Future<List<DynamicPricingRuleModel>> getDynamicPricingRulesForSpotIds(
    List<int> spotIds,
  ) async {
    if (spotIds.isEmpty) return const [];
    try {
      final response = await _client
          .from('dynamic_pricing_rules')
          .select()
          .inFilter('spot_id', spotIds);

      return (response as List).map((e) {
        return DynamicPricingRuleModel.fromJson(e as Map<String, dynamic>);
      }).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load dynamic pricing rules.');
    }
  }

  @override
  Future<List<ReservationModel>> getReservationsForSpotIds(
    List<int> spotIds,
  ) async {
    if (spotIds.isEmpty) return const [];
    try {
      final response = await _client
          .from('reservations')
          .select()
          .inFilter('spot_id', spotIds)
          .order('start_time', ascending: false);

      return (response as List).map((e) {
        return ReservationModel.fromJson(e as Map<String, dynamic>);
      }).toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load reservations.');
    }
  }

  @override
  Future<void> addParkingSpot(ParkingSpotModel spot) async {
    try {
      final data = spot.toJson()..remove('id');
      await _client.from('parking_spots').insert(data);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to add parking spot.');
    }
  }

  @override
  Future<void> addParkingLot(ParkingLotModel lot) async {
    try {
      final data = lot.toJson()..remove('id');
      await _client.from('parking_lots').insert(data);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to add parking lot.');
    }
  }

  @override
  Future<void> updateParkingSpot(ParkingSpotModel spot) async {
    try {
      // Remove id; keep owner-owned fields.
      final data = spot.toJson()..remove('id');
      await _client.from('parking_spots').update(data).eq('id', spot.id);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to update parking spot.');
    }
  }

  @override
  Future<void> archiveParkingSpot(int spotId) async {
    try {
      await _client.from('parking_spots').update({
        'status': 'ARCHIVED',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', spotId);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to archive parking spot.');
    }
  }

  @override
  Future<void> updateReviewOwnerReply({
    required int reviewId,
    required String ownerReply,
  }) async {
    try {
      await _client.from('reviews').update({
        'owner_reply': ownerReply,
        'owner_replied_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to update owner reply.');
    }
  }

  @override
  Future<void> setAvailabilityException({
    required int spotId,
    required DateTime day,
    required bool blocked,
    required String openTime,
    required String closeTime,
  }) async {
    // The DB column is a DATE; pass it as YYYY-MM-DD.
    final dayKey = DateTime(day.year, day.month, day.day);
    final isoDay =
        '${dayKey.year.toString().padLeft(4, '0')}-${dayKey.month.toString().padLeft(2, '0')}-${dayKey.day.toString().padLeft(2, '0')}';

    try {
      final existing = await _client
          .from('availabilities')
          .select()
          .eq('spot_id', spotId)
          .eq('specific_date', isoDay)
          .maybeSingle();

      final data = {
        'spot_id': spotId,
        'day_of_week': null,
        'specific_date': isoDay,
        'open_time': openTime,
        'close_time': closeTime,
        'is_blocked': blocked,
      };

      if (existing == null) {
        await _client.from('availabilities').insert(data);
      } else {
        final id = existing['id'] as int;
        await _client
            .from('availabilities')
            .update(data)
            .eq('id', id);
      }
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to update availability.');
    }
  }

  @override
  Future<void> setDynamicPricing({
    required int spotId,
    required double? threeHours,
    required double? sixHours,
    required double? twelveHours,
    required bool enabled,
  }) async {
    try {
      final existing = await _client
          .from('dynamic_pricing_rules')
          .select()
          .eq('spot_id', spotId)
          .order('id', ascending: true)
          .limit(1)
          .maybeSingle();

      final data = {
        'spot_id': spotId,
        'three_hours': threeHours,
        'six_hours': sixHours,
        'twelve_hours': twelveHours,
        'is_active': enabled,
      };

      if (existing == null) {
        await _client.from('dynamic_pricing_rules').insert(data);
      } else {
        final id = existing['id'] as int;
        await _client
            .from('dynamic_pricing_rules')
            .update(data)
            .eq('id', id);
      }

      await _client.from('parking_spots').update({
        'is_dynamic_pricing': enabled,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', spotId);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to update dynamic pricing.');
    }
  }
}

final ownerRepositoryProvider = Provider<OwnerRepository>((ref) {
  return OwnerRepositoryCloud(Supabase.instance.client);
});

