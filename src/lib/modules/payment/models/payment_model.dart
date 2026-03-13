import 'package:src/core/enums/app_enums.dart';

class PaymentModel {
  final int id;
  final int reservationId;
  final int payerId;
  final double amount;
  final double platformFee;
  final double ownerPayout;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? stripePaymentIntentId;
  final String? stripeChargeId;
  final String? refundId;
  final double? refundAmount;
  final int retryCount;
  final String? invoiceUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.reservationId,
    required this.payerId,
    required this.amount,
    required this.platformFee,
    required this.ownerPayout,
    required this.currency,
    required this.status,
    required this.method,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.refundId,
    this.refundAmount,
    required this.retryCount,
    this.invoiceUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      reservationId: json['reservation_id'] as int,
      payerId: json['payer_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      platformFee: (json['platform_fee'] as num).toDouble(),
      ownerPayout: (json['owner_payout'] as num).toDouble(),
      currency: json['currency'] as String,
      status: PaymentStatus.fromString(json['status'] as String),
      method: PaymentMethod.fromString(json['method'] as String),
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      stripeChargeId: json['stripe_charge_id'] as String?,
      refundId: json['refund_id'] as String?,
      refundAmount: json['refund_amount'] != null
          ? (json['refund_amount'] as num).toDouble()
          : null,
      retryCount: json['retry_count'] as int,
      invoiceUrl: json['invoice_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'payer_id': payerId,
      'amount': amount,
      'platform_fee': platformFee,
      'owner_payout': ownerPayout,
      'currency': currency,
      'status': status.toJson(),
      'method': method.toJson(),
      'stripe_payment_intent_id': stripePaymentIntentId,
      'stripe_charge_id': stripeChargeId,
      'refund_id': refundId,
      'refund_amount': refundAmount,
      'retry_count': retryCount,
      'invoice_url': invoiceUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isSuccessful => status == PaymentStatus.succeeded;
  bool get isRefunded => status == PaymentStatus.refunded;
}
