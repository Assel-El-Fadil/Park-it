import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceBreakdown extends StatelessWidget {
  final double subtotal;
  final double serviceFee;
  final double total;
  final NumberFormat formatter;

  const PriceBreakdown({
    Key? key,
    required this.subtotal,
    required this.serviceFee,
    required this.total,
    required this.formatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildRow('Subtotal', formatter.format(subtotal), theme),
          const SizedBox(height: 12),
          _buildRow(
            'Service Fee',
            formatter.format(serviceFee),
            theme,
            subtitle: 'Covers platform costs',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildRow('Total', formatter.format(total), theme, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String amount,
    ThemeData theme, {
    String? subtitle,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: isTotal
                    ? theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : theme.textTheme.bodyMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          amount,
          style: isTotal
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                )
              : theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
