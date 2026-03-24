import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/payment/screens/invoice_screen.dart';
import 'package:src/modules/payment/screens/payment_screen.dart';
import 'package:src/modules/payment/screens/payment_test.dart';
import 'package:src/modules/reservation/models/reservation_model.dart';

/// Payment module route names
class PaymentRoutes {
  // Route names
  static const String payment = 'payment';
  static const String paymentTest = 'payment-test';
  static const String paymentDetails = 'payment-details';

  // Paths
  static const String paymentPath = '/payment';
  static const String paymentTestPath = '/payment-test';
  static const String paymentDetailsPath = '/payment-details';
}

/// Payment module route configuration
List<GoRoute> getPaymentRoutes() {
  return [
    GoRoute(
      path: PaymentRoutes.paymentPath,
      name: PaymentRoutes.payment,
      builder: (context, state) {
        final booking = state.extra as ReservationModel?;
        if (booking == null) {
          return const Scaffold(body: Center(child: Text('No booking data')));
        }
        return PaymentScreen(booking: booking);
      },
    ),

    GoRoute(
      path: PaymentRoutes.paymentTestPath,
      name: PaymentRoutes.paymentTest,
      builder: (context, state) {
        return PaymentTestWidget();
      },
    ),

    GoRoute(
      path: PaymentRoutes.paymentDetailsPath,
      name: PaymentRoutes.paymentDetails,
      builder: (context, state) {
        final id = state.extra as int?;
        if (id == null) {
          return const Scaffold(body: Center(child: Text('No booking data')));
        }
        return InvoiceScreen(id: id);
      },
    ),
  ];
}
