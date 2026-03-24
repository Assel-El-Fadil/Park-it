import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/reservation/repositories/reservation_repository.dart';

final userReservationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return [];
  final repo = ref.read(reservationRepositoryProvider);
  return repo.getReservationsWithSpots(userId);
});
