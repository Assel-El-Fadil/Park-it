import 'package:src/modules/owner/models/availability_model.dart';
import 'package:src/modules/owner/models/dynamic_pricing_model.dart';
import 'package:src/modules/owner/models/parking_lot_model.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/modules/review/models/review_model.dart';

abstract class OwnerRepository {
  Future<List<ParkingSpotModel>> getOwnerSpots(int ownerId);
  Future<List<ParkingLotModel>> getOwnerLots(int ownerId);

  Future<List<ReviewModel>> getReviewsForSpotIds(List<int> spotIds);

  Future<List<AvailabilityModel>> getAvailabilitiesForSpotIds(
    List<int> spotIds,
  );

  Future<List<DynamicPricingRuleModel>> getDynamicPricingRulesForSpotIds(
    List<int> spotIds,
  );

  Future<List<ReservationModel>> getReservationsForSpotIds(
    List<int> spotIds,
  );

  Future<void> addParkingSpot(ParkingSpotModel spot);
  Future<void> addParkingLot(ParkingLotModel lot);
  Future<void> updateParkingSpot(ParkingSpotModel spot);
  Future<void> archiveParkingSpot(int spotId);

  Future<void> updateReviewOwnerReply({
    required int reviewId,
    required String ownerReply,
  });

  Future<void> setAvailabilityException({
    required int spotId,
    required DateTime day,
    required bool blocked,
    required String openTime,
    required String closeTime,
  });

  Future<void> setDynamicPricing({
    required int spotId,
    required double? threeHours,
    required double? sixHours,
    required double? twelveHours,
    required bool enabled,
  });
}

