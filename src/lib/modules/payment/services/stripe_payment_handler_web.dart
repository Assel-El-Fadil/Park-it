import 'package:src/modules/payment/stubs/stripe_web_redirect.dart';
import 'stripe_payment_handler.dart';

class WebStripePaymentHandler implements StripePaymentHandler {
  @override
  Future<void> present(String clientSecret) {
    throw UnimplementedError('Use createCheckoutAndRedirect() on web');
  }

  Future<String> createCheckoutAndRedirect({
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>)
    invokeFunction,
    required int reservationId,
    required String payerId,
    required int paymentId,
    required double amount,
    required String currency,
  }) async {
    final returnUrl = '${getOrigin()}/payment-return';

    final sessionData = await invokeFunction({
      'action': 'create_checkout_session',
      'amount': amount,
      'currency': currency.toLowerCase(),
      'reservationId': reservationId,
      'payerId': payerId,
      'paymentId': paymentId,
      'returnUrl': returnUrl,
    });

    final url = sessionData['url'] as String;
    await redirectToStripe(url);
    return sessionData['sessionId'] as String;
  }
}
