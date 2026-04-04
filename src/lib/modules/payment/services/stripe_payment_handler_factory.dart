import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'stripe_payment_handler.dart';
import 'stripe_payment_handler_mobile.dart';
import 'stripe_payment_handler_web.dart';

class StripePaymentHandlerFactory {
  static StripePaymentHandler create([BuildContext? context]) {
    if (kIsWeb) {
      assert(context != null, 'BuildContext is required on web');
      return WebStripePaymentHandler();
    }
    return MobileStripePaymentHandler();
  }
}
