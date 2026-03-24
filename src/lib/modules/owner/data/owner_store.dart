import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/models/parking_lot_model.dart';
import 'package:src/modules/owner/models/availability_model.dart';
import 'package:src/modules/owner/models/dynamic_pricing_model.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';
import 'package:src/modules/review/models/review_model.dart';
import 'package:src/modules/owner/repositories/owner_repository_cloud.dart';

class OwnerStoreState {
  final List<ParkingLotModel> lots;
  final List<ParkingSpotModel> spots;
  final Map<int, List<ReviewModel>> reviewsBySpotId;
  final Map<int, List<AvailabilityModel>> availabilityBySpotId;
  final Map<int, List<DynamicPricingRuleModel>> dynamicPricingBySpotId;
  final List<ReservationModel> reservations;

  const OwnerStoreState({
    required this.lots,
    required this.spots,
    required this.reviewsBySpotId,
    required this.availabilityBySpotId,
    required this.dynamicPricingBySpotId,
    required this.reservations,
  });

  OwnerStoreState copyWith({
    List<ParkingLotModel>? lots,
    List<ParkingSpotModel>? spots,
    Map<int, List<ReviewModel>>? reviewsBySpotId,
    Map<int, List<AvailabilityModel>>? availabilityBySpotId,
    Map<int, List<DynamicPricingRuleModel>>? dynamicPricingBySpotId,
    List<ReservationModel>? reservations,
  }) {
    return OwnerStoreState(
      lots: lots ?? this.lots,
      spots: spots ?? this.spots,
      reviewsBySpotId: reviewsBySpotId ?? this.reviewsBySpotId,
      availabilityBySpotId: availabilityBySpotId ?? this.availabilityBySpotId,
      dynamicPricingBySpotId:
          dynamicPricingBySpotId ?? this.dynamicPricingBySpotId,
      reservations: reservations ?? this.reservations,
    );
  }
}

/// In-memory data store to power the owner module UI.
///
/// This mimics the database tables from `park-it.sql`:
/// - `parking_spots`
/// - `reviews`
/// - `availabilities`
/// - `dynamic_pricing_rules`
/// - `reservations`
///
/// Later you can swap the internals with Supabase repositories.
class OwnerStoreController extends Notifier<OwnerStoreState> {
  String? _loadedOwnerId;

  @override
  OwnerStoreState build() {
    // Default state before we have an authenticated owner.
    final empty = OwnerStoreState(
      lots: <ParkingLotModel>[],
      spots: <ParkingSpotModel>[],
      reviewsBySpotId: <int, List<ReviewModel>>{},
      availabilityBySpotId: <int, List<AvailabilityModel>>{},
      dynamicPricingBySpotId: <int, List<DynamicPricingRuleModel>>{},
      reservations: <ReservationModel>[],
    );

    ref.listen(currentUserProvider, (prev, next) async {
      final ownerId = next?.id ?? '';
      if (ownerId == null) return;
      if (_loadedOwnerId == ownerId) return;
      _loadedOwnerId = ownerId;
      await _loadForOwner(ownerId);
    });

    // Trigger initial load (if already authenticated).
    final initialOwnerId = ref.read(currentUserProvider)?.id;

    if (initialOwnerId != null) {
      _loadedOwnerId = initialOwnerId;
      Future.microtask(() => _loadForOwner(initialOwnerId));
    }

    return empty;
  }

  Future<void> _loadForOwner(String ownerId) async {
    final repo = ref.read(ownerRepositoryProvider);

    final spots = await repo.getOwnerSpots(ownerId);
    final lots = await repo.getOwnerLots(ownerId);
    final spotIds = spots.map((s) => s.id).toList();

    final reservations = await repo.getReservationsForSpotIds(spotIds);
    final reviews = await repo.getReviewsForSpotIds(spotIds);
    final availabilities = await repo.getAvailabilitiesForSpotIds(spotIds);
    final pricingRules = await repo.getDynamicPricingRulesForSpotIds(spotIds);

    final reviewsBySpotId = <int, List<ReviewModel>>{};
    for (final r in reviews) {
      reviewsBySpotId.putIfAbsent(r.spotId, () => <ReviewModel>[]).add(r);
    }

    final availabilityBySpotId = <int, List<AvailabilityModel>>{};
    for (final a in availabilities) {
      availabilityBySpotId
          .putIfAbsent(a.spotId, () => <AvailabilityModel>[])
          .add(a);
    }

    final dynamicPricingBySpotId = <int, List<DynamicPricingRuleModel>>{};
    for (final rule in pricingRules) {
      dynamicPricingBySpotId
          .putIfAbsent(rule.spotId, () => <DynamicPricingRuleModel>[])
          .add(rule);
    }

    state = OwnerStoreState(
      lots: lots,
      spots: spots,
      reviewsBySpotId: reviewsBySpotId,
      availabilityBySpotId: availabilityBySpotId,
      dynamicPricingBySpotId: dynamicPricingBySpotId,
      reservations: reservations,
    );
  }

  Future<void> addSpot({required ParkingSpotModel spot}) async {
    await ref.read(ownerRepositoryProvider).addParkingSpot(spot);
    if (spot.ownerId != _loadedOwnerId) return;
    await _loadForOwner(spot.ownerId);
  }

  Future<void> addLot({
    required ParkingLotModel lot,
    required int totalSpots,
    required SpotType spotType,
    required double pricePerHour,
    required double? pricePerDay,
    required bool isDynamicPricing,
    required List<VehicleType>? vehicleTypes,
    required List<Amenity>? amenities,
  }) async {
    await ref
        .read(ownerRepositoryProvider)
        .addParkingLotWithSpots(
          lot: lot,
          totalSpots: totalSpots,
          spotType: spotType,
          pricePerHour: pricePerHour,
          pricePerDay: pricePerDay,
          isDynamicPricing: isDynamicPricing,
          vehicleTypes: vehicleTypes,
          amenities: amenities,
        );
    if (lot.ownerId != _loadedOwnerId) return;
    await _loadForOwner(lot.ownerId);
  }

  Future<void> updateSpot(ParkingSpotModel updated) async {
    await ref.read(ownerRepositoryProvider).updateParkingSpot(updated);
    if (updated.ownerId != _loadedOwnerId) return;
    await _loadForOwner(updated.ownerId);
  }

  Future<void> archiveSpot({required int spotId}) async {
    final ownerId = _loadedOwnerId;
    if (ownerId == null) return;
    await ref.read(ownerRepositoryProvider).archiveParkingSpot(spotId);
    await _loadForOwner(ownerId);
  }

  Future<void> updateReviewOwnerReply({
    required int reviewId,
    required String ownerReply,
  }) async {
    await ref
        .read(ownerRepositoryProvider)
        .updateReviewOwnerReply(reviewId: reviewId, ownerReply: ownerReply);
    final ownerId = _loadedOwnerId;
    if (ownerId == null) return;
    await _loadForOwner(ownerId);
  }

  Future<void> setWeeklyAvailability({
    required int spotId,
    required int dayOfWeek,
    required bool isBlocked,
    String openTime = '08:00:00',
    String closeTime = '22:00:00',
  }) async {
    final ownerId = _loadedOwnerId;
    if (ownerId == null) return;
    await ref
        .read(ownerRepositoryProvider)
        .setWeeklyAvailability(
          spotId: spotId,
          dayOfWeek: dayOfWeek,
          isBlocked: isBlocked,
          openTime: openTime,
          closeTime: closeTime,
        );
    await _loadForOwner(ownerId);
  }

  Future<void> setDynamicPricingRules({
    required int spotId,
    required DynamicPricingRuleModel rule,
    required bool enabled,
  }) async {
    final ownerId = _loadedOwnerId;
    if (ownerId == null) return;
    await ref
        .read(ownerRepositoryProvider)
        .setDynamicPricing(
          spotId: spotId,
          threeHours: rule.threeHours,
          sixHours: rule.sixHours,
          twelveHours: rule.twelveHours,
          enabled: enabled,
        );
    await _loadForOwner(ownerId);
  }
}

final ownerStoreProvider =
    NotifierProvider<OwnerStoreController, OwnerStoreState>(
      OwnerStoreController.new,
    );
