import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/payment/models/payment_model.dart';
import 'package:src/modules/payment/screens/booking_confirmation_screen.dart';
import 'package:src/modules/payment/screens/booking_details_screen.dart';
import 'package:src/modules/payment/screens/booking_failure_screen.dart';
import 'package:src/modules/payment/screens/my_bookings_screen.dart';
import 'package:src/modules/payment/screens/payment_screen.dart';

/// Payment module route names
class PaymentRoutes {
  // Route names
  static const String payment = 'payment';
  static const String bookingConfirmation = 'booking-confirmation';
  static const String bookings = 'bookings';
  static const String bookingDetails = 'booking-details';
  static const String bookingFailure = 'booking-failure';

  // Paths
  static const String paymentPath = '/payment';
  static const String bookingConfirmationPath = '/booking-confirmation';
  static const String bookingsPath = '/bookings';
  static const String bookingDetailsPath = '/booking-details/:id';
  static const String bookingFailurePath = '/booking-failure';
}

/// Payment module route configuration
List<GoRoute> getPaymentRoutes() {
  return [
    // GoRoute(
    //   path: PaymentRoutes.paymentPath,
    //   name: PaymentRoutes.payment,
    //   builder: (context, state) {
    //     final booking = state.extra as ParkingBooking?;
    //     if (booking == null) {
    //       return const Scaffold(body: Center(child: Text('No booking data')));
    //     }
    //     return PaymentScreen(booking: booking);
    //   },
    // ),
    // GoRoute(
    //   path: PaymentRoutes.bookingsPath,
    //   name: PaymentRoutes.bookings,
    //   builder: (context, state) => const MyBookingsScreen(),
    // ),
    // GoRoute(
    //   path: PaymentRoutes.bookingDetailsPath,
    //   name: PaymentRoutes.bookingDetails,
    //   builder: (context, state) {
    //     final bookingId = state.pathParameters['id'] ?? '';
    //     final booking = state.extra as ParkingBooking?;
    //     return BookingDetailsScreen(bookingId: bookingId, booking: booking);
    //   },
    // ),
    // GoRoute(
    //   path: PaymentRoutes.bookingConfirmationPath,
    //   name: PaymentRoutes.bookingConfirmation,
    //   builder: (context, state) {
    //     final booking = state.extra as ParkingBooking?;
    //     return BookingConfirmationScreen(booking: booking);
    //   },
    // ),
    // GoRoute(
    //   path: PaymentRoutes.bookingFailurePath,
    //   name: PaymentRoutes.bookingFailure,
    //   builder: (context, state) {
    //     // Extract parameters from extra
    //     final extra = state.extra as Map<String, dynamic>?;

    //     return BookingFailureScreen(
    //       failureType: extra?['failureType'] as FailureType?,
    //       customMessage: extra?['message'] as String?,
    //       booking: extra?['booking'] as ParkingBooking?,
    //       errorCode: extra?['errorCode'] as String?,
    //     );
    //   },
    // ),
  ];
}
