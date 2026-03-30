import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'stripe_payment_handler.dart';

class MobileStripePaymentHandler implements StripePaymentHandler {
  @override
  Future<void> present(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Park-it',
        style: ThemeMode.system,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }
}
