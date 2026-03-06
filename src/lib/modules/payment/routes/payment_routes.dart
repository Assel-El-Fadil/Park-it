import 'package:go_router/go_router.dart';

/// Payment module route names
class PaymentRoutes {
  // Route names
  static const String paymentMethods = 'payment-methods';
  static const String addPaymentMethod = 'add-payment-method';
  static const String paymentDetail = 'payment-detail';
  static const String transactionHistory = 'transaction-history';
  static const String checkout = 'checkout';
  static const String paymentSuccess = 'payment-success';
  static const String paymentFailed = 'payment-failed';

  // Paths
  static const String paymentMethodsPath = '/payment/methods';
  static const String addPaymentMethodPath = '/payment/methods/add';
  static const String paymentDetailPath = '/payment/:id';
  static const String transactionHistoryPath = '/payment/history';
  static const String checkoutPath = '/payment/checkout';
  static const String paymentSuccessPath = '/payment/success';
  static const String paymentFailedPath = '/payment/failed';
}

/// Payment module route configuration
List<GoRoute> getPaymentRoutes() {
  return [
    // Payment Methods
    // GoRoute(
    //   path: PaymentRoutes.paymentMethodsPath,
    //   name: PaymentRoutes.paymentMethods,
    //   builder: (context, state) => const PaymentMethodsScreen(),
    // ),
    // GoRoute(
    //   path: PaymentRoutes.addPaymentMethodPath,
    //   name: PaymentRoutes.addPaymentMethod,
    //   builder: (context, state) => const AddPaymentMethodScreen(),
    // ),
    // GoRoute(
    //   path: PaymentRoutes.paymentDetailPath,
    //   name: PaymentRoutes.paymentDetail,
    //   builder: (context, state) {
    //     final paymentId = state.pathParameters['id'] ?? '';
    //     return PaymentDetailScreen(paymentId: paymentId);
    //   },
    // ),

    // // Transaction History
    // GoRoute(
    //   path: PaymentRoutes.transactionHistoryPath,
    //   name: PaymentRoutes.transactionHistory,
    //   builder: (context, state) => const TransactionHistoryScreen(),
    // ),

    // // Checkout Flow
    // GoRoute(
    //   path: PaymentRoutes.checkoutPath,
    //   name: PaymentRoutes.checkout,
    //   builder: (context, state) {
    //     final bookingId = state.uri.queryParameters['bookingId'] ?? '';
    //     final amount = state.uri.queryParameters['amount'] ?? '0';
    //     return CheckoutScreen(
    //       bookingId: bookingId,
    //       amount: double.tryParse(amount) ?? 0,
    //     );
    //   },
    // ),
    // GoRoute(
    //   path: PaymentRoutes.paymentSuccessPath,
    //   name: PaymentRoutes.paymentSuccess,
    //   builder: (context, state) {
    //     final transactionId = state.uri.queryParameters['transactionId'] ?? '';
    //     return PaymentSuccessScreen(transactionId: transactionId);
    //   },
    // ),
    // GoRoute(
    //   path: PaymentRoutes.paymentFailedPath,
    //   name: PaymentRoutes.paymentFailed,
    //   builder: (context, state) {
    //     final error = state.uri.queryParameters['error'] ?? 'Payment failed';
    //     return PaymentFailedScreen(errorMessage: error);
    //   },
    // ),
  ];
}
