import 'package:src/core/base/cloud/supabase_repo.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/payment/models/payment_model.dart';

class PaymentRepository extends SupabaseRepository<PaymentModel> {
  @override
  String get tableName => 'payments';

  @override
  String getItemKey(PaymentModel item) => item.id.toString();

  @override
  Map<String, dynamic> toJson(PaymentModel item) => item.toJson();

  @override
  PaymentModel fromJson(Map<String, dynamic> json) =>
      PaymentModel.fromJson(json);

  Future<List<PaymentModel>> getByPayerId(String payerId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('payer_id', payerId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => fromJson(e)).toList();
  }

  Future<PaymentModel?> getByReservationId(int reservationId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('reservation_id', reservationId)
        .maybeSingle();

    if (response == null) return null;
    return fromJson(response);
  }

  Future<List<PaymentModel>> getByStatus(PaymentStatus status) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('status', status.toJson())
        .order('created_at', ascending: false);

    return (response as List).map((e) => fromJson(e)).toList();
  }

  Future<PaymentModel?> getByStripePaymentIntentId(
    String stripePaymentIntentId,
  ) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('stripe_payment_intent_id', stripePaymentIntentId)
        .maybeSingle();

    if (response == null) return null;
    return fromJson(response);
  }

  Future<PaymentModel?> getByStripeChargeId(String stripeChargeId) async {
    final response = await client
        .from(tableName)
        .select()
        .eq('stripe_charge_id', stripeChargeId)
        .maybeSingle();

    if (response == null) return null;
    return fromJson(response);
  }

  Future<void> updateStatus(int paymentId, PaymentStatus status) async {
    await client
        .from(tableName)
        .update({
          'status': status.toJson(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', paymentId);
  }

  Future<void> updateStripeDetails(
    int paymentId, {
    String? stripePaymentIntentId,
    String? stripeChargeId,
    PaymentStatus? status,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (stripePaymentIntentId != null) {
      updates['stripe_payment_intent_id'] = stripePaymentIntentId;
    }
    if (stripeChargeId != null) {
      updates['stripe_charge_id'] = stripeChargeId;
    }
    if (status != null) {
      updates['status'] = status.toJson();
    }

    await client.from(tableName).update(updates).eq('id', paymentId);
  }

  Future<void> markAsRefunded(
    int paymentId, {
    required String refundId,
    required double refundAmount,
  }) async {
    await client
        .from(tableName)
        .update({
          'status': PaymentStatus.refunded.toJson(),
          'refund_id': refundId,
          'refund_amount': refundAmount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', paymentId);
  }

  Future<void> incrementRetryCount(int paymentId) async {
    final payment = await getById(paymentId.toString());
    if (payment != null) {
      await client
          .from(tableName)
          .update({
            'retry_count': payment.retryCount + 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', paymentId);
    }
  }

  Future<List<PaymentModel>> getPendingPayments({
    int hoursThreshold = 24,
  }) async {
    final cutoffTime = DateTime.now().subtract(Duration(hours: hoursThreshold));
    final response = await client
        .from(tableName)
        .select()
        .eq('status', PaymentStatus.pending.toJson())
        .lt('created_at', cutoffTime.toIso8601String())
        .order('created_at', ascending: false);

    return (response as List).map((e) => fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getOwnerEarningsData(
    String ownerId, {
    int days = 30,startDate,
    DateTime? endDate,
  }) async {
    var query = client
        .from(tableName)
        .select('owner_payout')
        .eq('owner_id', ownerId)
        .eq('status', PaymentStatus.succeeded.toJson());

    final now = DateTime.now();
    final defaultStartDate = now.subtract(Duration(days: days));

    if (startDate != null) {
      query = query.gte('created_at', startDate.toIso8601String());
    } else {
      query = query.gte('created_at', defaultStartDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('created_at', endDate.toIso8601String());
    } else {
      query = query.lte('created_at', now.toIso8601String());
    }

    final response = await query;
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<double> getTotalRevenueForOwner(
    String ownerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var query = client
        .from(tableName)
        .select('owner_payout')
        .eq('status', PaymentStatus.succeeded.toJson());

    if (startDate != null) {
      query = query.gte('created_at', startDate.toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('created_at', endDate.toIso8601String());
    }

    final response = await query;
    final payments = response as List;

    return payments.fold<double>(
      0,
      (sum, payment) => sum + (payment['owner_payout'] as num).toDouble(),
    );
  }
}
