import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/payment/models/payment_state.dart';
import 'package:src/modules/payment/services/payment_service.dart';

class PaymentNotifier extends Notifier<PaymentState> {
  late final PaymentService _service;

  @override
  PaymentState build() {
    _service = PaymentService();
    return const PaymentState();
  }

  Future<bool> processPayment({
    required int reservationId,
    required String payerId,
    required double amount,
    required PaymentMethod method,
    String currency = 'MAD',
  }) async {
    state = state.copyWith(status: PaymentStatus.loading, clearError: true);

    try {
      final payment = await _service.processPayment(
        reservationId: reservationId,
        payerId: payerId,
        amount: amount,
        method: method,
        currency: currency,
      );

      state = state.copyWith(status: PaymentStatus.succeeded, payment: payment);
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        state = state.copyWith(status: PaymentStatus.cancelled);
      } else {
        state = state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: e.error.localizedMessage ?? 'Payment failed.',
        );
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> refundPayment({
    required int paymentId,
    double? refundAmount,
  }) async {
    state = state.copyWith(isRefunding: true, clearError: true);

    try {
      final payment = await _service.refundPayment(
        paymentId: paymentId,
        refundAmount: refundAmount,
      );

      state = state.copyWith(isRefunding: false, payment: payment);
      return true;
    } catch (e) {
      state = state.copyWith(isRefunding: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() => state = const PaymentState();
}

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(
  PaymentNotifier.new,
);

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});
