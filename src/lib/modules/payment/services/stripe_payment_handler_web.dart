// lib/payment/stripe_payment_handler_web.dart

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'stripe_payment_handler.dart';

class WebStripePaymentHandler implements StripePaymentHandler {
  final BuildContext context;
  WebStripePaymentHandler(this.context);

  @override
  Future<void> present(String clientSecret) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CardPaymentDialog(clientSecret: clientSecret),
    );

    if (confirmed != true) {
      throw const StripeException(
        error: LocalizedErrorMessage(
          code: FailureCode.Failed,
          message: 'Payment cancelled by user',
        ),
      );
    }
  }
}

class _CardPaymentDialog extends StatefulWidget {
  final String clientSecret;
  const _CardPaymentDialog({required this.clientSecret});

  @override
  State<_CardPaymentDialog> createState() => _CardPaymentDialogState();
}

class _CardPaymentDialogState extends State<_CardPaymentDialog> {
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } on StripeException catch (e) {
      setState(() {
        _error = e.error.localizedMessage ?? 'Payment failed';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Card Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CardField(),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Pay'),
        ),
      ],
    );
  }
}
