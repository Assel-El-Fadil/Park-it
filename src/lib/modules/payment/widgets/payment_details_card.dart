import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/payment/models/payment_model.dart';
import 'package:src/shared/widgets/custom_card.dart';
import 'package:src/shared/widgets/detail_row.dart';

class PaymentDetailsCard extends ConsumerWidget {
  final PaymentModel payment;

  const PaymentDetailsCard({super.key, required this.payment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final currentUser = ref.watch(currentUserProvider);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment details',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          DetailRow(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: '${currentUser!.firstName} ${currentUser.lastName}',
          ),
          DetailRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: '${currentUser.email}',
          ),

          DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Reservation',
            value: '#${payment.reservationId}',
          ),

          DetailRow(
            icon: _methodIcon(payment.method),
            label: 'Method',
            value: payment.method.name,
          ),

          if (payment.stripePaymentIntentId != null)
            DetailRow(
              icon: Icons.tag_outlined,
              label: 'Payment ID',
              value: _truncate(payment.stripePaymentIntentId!),
              onTap: () =>
                  _copyToClipboard(context, payment.stripePaymentIntentId!),
            ),

          if (payment.stripeChargeId != null)
            DetailRow(
              icon: Icons.receipt_outlined,
              label: 'Charge ID',
              value: _truncate(payment.stripeChargeId!),
              onTap: () => _copyToClipboard(context, payment.stripeChargeId!),
            ),

          DetailRow(
            icon: Icons.update_outlined,
            label: 'Last updated',
            value: _formatDate(payment.updatedAt),
          ),
        ],
      ),
    );
  }

  IconData _methodIcon(PaymentMethod method) => switch (method) {
    PaymentMethod.card => Icons.credit_card_outlined,
    PaymentMethod.applePay => Icons.account_balance_outlined,
    _ => Icons.payments_outlined,
  };

  String _truncate(String s) => s.length > 20
      ? '${s.substring(0, 10)}...${s.substring(s.length - 6)}'
      : s;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _copyToClipboard(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
