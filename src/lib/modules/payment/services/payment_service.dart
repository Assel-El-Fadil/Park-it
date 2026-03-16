import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/payment/models/payment_model.dart';
import 'package:src/modules/payment/repositories/payment_repository_cloud.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final _supabase = Supabase.instance.client;
  final _repo = PaymentRepository();

  static const double _platformFeeRate = 0.15; // 15%

  double _calcPlatformFee(double amount) =>
      double.parse((amount * _platformFeeRate).toStringAsFixed(2));

  double _calcOwnerPayout(double amount) =>
      double.parse((amount * (1 - _platformFeeRate)).toStringAsFixed(2));

  Future<Map<String, dynamic>> _invokeFunction(
    Map<String, dynamic> body,
  ) async {
    final res = await _supabase.functions.invoke(
      'payment_processor',
      body: body,
    );

    if (res.data == null) {
      throw Exception('Edge function returned no data');
    }

    final data = res.data as Map<String, dynamic>;

    if (data.containsKey('error')) {
      throw Exception(data['error']);
    }

    return data;
  }

  Future<PaymentModel> processPayment({
    required int reservationId,
    required int payerId,
    required double amount,
    required PaymentMethod method,
    String currency = 'MAD',
  }) async {
    final platformFee = _calcPlatformFee(amount);
    final ownerPayout = _calcOwnerPayout(amount);

    // Step 1 — create Stripe Payment Intent
    final intentData = await _invokeFunction({
      'action': 'create_payment_intent',
      'amount': amount,
      'currency': currency.toLowerCase(),
      'reservationId': reservationId,
      'payerId': payerId,
      'platformFee': platformFee,
      'ownerPayout': ownerPayout,
    });

    final clientSecret = intentData['clientSecret'] as String;
    final paymentIntentId = intentData['paymentIntentId'] as String;

    final pendingData = await _supabase
        .from('payments')
        .insert({
          'reservation_id': reservationId,
          'payer_id': payerId,
          'amount': amount,
          'platform_fee': platformFee,
          'owner_payout': ownerPayout,
          'currency': currency,
          'status': 'PENDING',
          'method': method.toJson(),
          'stripe_payment_intent_id': paymentIntentId,
          'retry_count': 0,
        })
        .select()
        .single();

    final paymentId = pendingData['id'] as int;

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Park-it',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final confirmData = await _invokeFunction({
        'action': 'confirm_payment',
        'paymentIntentId': paymentIntentId,
      });

      final chargeId = confirmData['chargeId'] as String?;
      final receiptUrl = confirmData['receiptUrl'] as String?;

      await _repo.updateStripeDetails(
        paymentId,
        stripeChargeId: chargeId,
        status: PaymentStatus.succeeded,
      );

      if (receiptUrl != null) {
        await _supabase
            .from('payments')
            .update({'invoice_url': receiptUrl})
            .eq('id', paymentId);
      }

      await _supabase
          .from('reservations')
          .update({
            'status': 'CONFIRMED',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reservationId);

      // Return final model
      final completed = await _repo.getById(paymentId.toString());
      return completed!;
    } on StripeException catch (e) {
      await _repo.incrementRetryCount(paymentId);
      rethrow;
    } catch (e) {
      await _repo.incrementRetryCount(paymentId);
      rethrow;
    }
  }

  Future<PaymentModel> refundPayment({
    required int paymentId,
    double? refundAmount,
  }) async {
    final payment = await _repo.getById(paymentId.toString());

    if (payment == null) throw Exception('Payment not found');
    if (payment.stripeChargeId == null) {
      throw Exception('No charge ID on record');
    }
    if (payment.isRefunded) throw Exception('Payment already refunded');

    final refundData = await _invokeFunction({
      'action': 'refund',
      'chargeId': payment.stripeChargeId,
      'reservationId': payment.reservationId,
      if (refundAmount != null) 'amount': refundAmount,
    });

    final refundId = refundData['refundId'] as String;
    final actualAmount = (refundData['refundAmount'] as num).toDouble();

    await _repo.markAsRefunded(
      paymentId,
      refundId: refundId,
      refundAmount: actualAmount,
    );

    await _supabase
        .from('reservations')
        .update({
          'status': 'REFUNDED',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', payment.reservationId);

    final updated = await _repo.getById(paymentId.toString());
    return updated!;
  }
}
