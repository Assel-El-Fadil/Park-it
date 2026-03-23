import 'package:flutter/material.dart';
import 'package:src/modules/payment/models/payment_model.dart';
import 'package:src/modules/payment/widgets/line_item.dart';
import 'package:src/shared/widgets/custom_card.dart';

class BreakdownCard extends StatelessWidget {
  final PaymentModel payment;

  const BreakdownCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final symbol = _currencySymbol(payment.currency);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount breakdown',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          LineItem(
            label: 'Subtotal',
            value: '$symbol${payment.amount.toStringAsFixed(2)}',
          ),
          LineItem(
            label: 'Platform fee',
            value: '$symbol${payment.platformFee.toStringAsFixed(2)}',
            valueColor: colorScheme.onSurfaceVariant,
          ),
          Divider(color: colorScheme.outlineVariant, height: 24),
          LineItem(
            label: 'Owner payout',
            value: '$symbol${payment.ownerPayout.toStringAsFixed(2)}',
            labelStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            valueStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
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
