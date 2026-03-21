import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  final double amount;
  final double platformFee;
  final double ownerPayout;
  final String currency;

  const OrderSummary({
    super.key,
    required this.amount,
    required this.platformFee,
    required this.ownerPayout,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order summary', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            _SummaryRow(
              label: 'Parking fee',
              value: ownerPayout,
              currency: currency,
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Platform fee',
              value: platformFee,
              currency: currency,
              muted: true,
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Total',
              value: amount,
              currency: currency,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final String currency;
  final bool muted;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.currency,
    this.muted = false,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: muted ? Theme.of(context).hintColor : null,
      fontWeight: bold ? FontWeight.bold : null,
      fontSize: bold ? 16 : null,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${value.toStringAsFixed(2)} $currency', style: style),
        Text(label, style: style),
      ],
    );
  }
}
