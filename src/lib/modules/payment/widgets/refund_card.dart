import 'package:flutter/material.dart';
import 'package:src/modules/payment/models/payment_model.dart';
import 'package:src/modules/payment/widgets/line_item.dart';
import 'package:src/shared/widgets/custom_card.dart';

class RefundCard extends StatelessWidget {
  final PaymentModel payment;

  const RefundCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final symbol = _currencySymbol(payment.currency);

    return CustomCard(
      color: colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.currency_exchange,
                color: colorScheme.secondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Refund issued',
                style: textTheme.titleSmall?.copyWith(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (payment.refundAmount != null)
            LineItem(
              label: 'Refunded amount',
              value: '$symbol${payment.refundAmount!.toStringAsFixed(2)}',
              valueColor: colorScheme.secondary,
            ),
          if (payment.refundId != null)
            LineItem(label: 'Refund ID', value: payment.refundId!),
        ],
      ),
    );
  }

  String _currencySymbol(String currency) => switch (currency.toUpperCase()) {
    'USD' => '\$',
    'EUR' => '€',
    'GBP' => '£',
    'MAD' => 'MAD ',
    _ => '${currency.toUpperCase()} ',
  };
}
