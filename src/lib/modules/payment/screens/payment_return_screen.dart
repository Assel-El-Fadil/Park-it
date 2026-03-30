import 'package:flutter/material.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentReturnPage extends StatefulWidget {
  const PaymentReturnPage({super.key});

  @override
  State<PaymentReturnPage> createState() => _PaymentReturnPageState();
}

class _PaymentReturnPageState extends State<PaymentReturnPage> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _handleReturn();
  }

  Future<void> _handleReturn() async {
    try {
      final uri = Uri.base;
      final status = uri.queryParameters['status'];
      final sessionId = uri.queryParameters['session_id'];

      if (status == 'success' && sessionId != null) {
        final data = await _invokeFunction({
          'action': 'confirm_checkout_session',
          'sessionId': sessionId,
        });

        final paymentId = data['paymentId'];
        final chargeId = data['chargeId'];
        final receiptUrl = data['receiptUrl'] as String?;

        await _supabase
            .from('payments')
            .update({
              'status': 'SUCCEEDED',
              'stripe_charge_id': chargeId,
              if (receiptUrl != null) 'invoice_url': receiptUrl,
            })
            .eq('id', paymentId);

        await _supabase
            .from('reservations')
            .update({
              'status': 'CONFIRMED',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', data['reservationId']);

        if (mounted) AppNavigator.goNamed(context, PaymentRoutes.myPayments);
      } else {
        if (mounted) AppNavigator.goNamed(context, AppRoutes.landing);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment confirmation failed: $e')),
        );
        AppNavigator.goNamed(context, AppRoutes.landing);
      }
    }
  }

  Future<Map<String, dynamic>> _invokeFunction(
    Map<String, dynamic> body,
  ) async {
    final res = await _supabase.functions.invoke(
      'payment_processor',
      body: body,
    );

    if (res.data == null) throw Exception('Edge function returned no data');

    final data = res.data as Map<String, dynamic>;
    if (data.containsKey('error')) throw Exception(data['error']);

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Confirming your payment...'),
          ],
        ),
      ),
    );
  }
}
