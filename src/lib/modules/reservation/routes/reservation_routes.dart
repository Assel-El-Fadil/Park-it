import 'package:go_router/go_router.dart';

/// Reservation module route names
class ReservationRoutes {
  // Route names
  static const String reservations = 'reservations';
  static const String reservationDetail = 'reservation-detail';
  static const String createReservation = 'create-reservation';
  static const String upcomingReservations = 'upcoming-reservations';
  static const String pastReservations = 'past-reservations';
  static const String cancelledReservations = 'cancelled-reservations';
  static const String reservationConfirmation = 'reservation-confirmation';
  static const String reservationMap = 'reservation-map';

  // Paths
  static const String reservationsPath = '/reservations';
  static const String reservationDetailPath = '/reservations/:id';
  static const String createReservationPath = '/reservations/create';
  static const String upcomingReservationsPath = '/reservations/upcoming';
  static const String pastReservationsPath = '/reservations/past';
  static const String cancelledReservationsPath = '/reservations/cancelled';
  static const String reservationConfirmationPath =
      '/reservations/confirmation';
  static const String reservationMapPath = '/reservations/:id/map';
}

/// Reservation module route configuration
List<GoRoute> getReservationRoutes() {
  return [
    // Main reservations list
    // GoRoute(
    //   path: ReservationRoutes.reservationsPath,
    //   name: ReservationRoutes.reservations,
    //   builder: (context, state) => const ReservationsScreen(),
    // ),

    // // Filtered reservations
    // GoRoute(
    //   path: ReservationRoutes.upcomingReservationsPath,
    //   name: ReservationRoutes.upcomingReservations,
    //   builder: (context, state) => const UpcomingReservationsScreen(),
    // ),
    // GoRoute(
    //   path: ReservationRoutes.pastReservationsPath,
    //   name: ReservationRoutes.pastReservations,
    //   builder: (context, state) => const PastReservationsScreen(),
    // ),
    // GoRoute(
    //   path: ReservationRoutes.cancelledReservationsPath,
    //   name: ReservationRoutes.cancelledReservations,
    //   builder: (context, state) => const CancelledReservationsScreen(),
    // ),

    // // Create reservation flow
    // GoRoute(
    //   path: ReservationRoutes.createReservationPath,
    //   name: ReservationRoutes.createReservation,
    //   builder: (context, state) {
    //     final spaceId = state.uri.queryParameters['spaceId'] ?? '';
    //     final startDate = state.uri.queryParameters['startDate'];
    //     final endDate = state.uri.queryParameters['endDate'];

    //     return CreateReservationScreen(
    //       parkingSpaceId: spaceId,
    //       startDate: startDate != null ? DateTime.parse(startDate) : null,
    //       endDate: endDate != null ? DateTime.parse(endDate) : null,
    //     );
    //   },
    // ),

    // // Reservation confirmation
    // GoRoute(
    //   path: ReservationRoutes.reservationConfirmationPath,
    //   name: ReservationRoutes.reservationConfirmation,
    //   builder: (context, state) {
    //     final reservationId = state.uri.queryParameters['reservationId'] ?? '';
    //     return ReservationConfirmationScreen(reservationId: reservationId);
    //   },
    // ),

    // // Reservation detail
    // GoRoute(
    //   path: ReservationRoutes.reservationDetailPath,
    //   name: ReservationRoutes.reservationDetail,
    //   builder: (context, state) {
    //     final reservationId = state.pathParameters['id'] ?? '';
    //     return ReservationDetailScreen(reservationId: reservationId);
    //   },
    // ),

    // // Reservation map view
    // GoRoute(
    //   path: ReservationRoutes.reservationMapPath,
    //   name: ReservationRoutes.reservationMap,
    //   builder: (context, state) {
    //     final reservationId = state.pathParameters['id'] ?? '';
    //     return ReservationMapScreen(reservationId: reservationId);
    //   },
    // ),
  ];
}
