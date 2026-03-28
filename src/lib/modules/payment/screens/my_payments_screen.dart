import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/payment/models/payment_model.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/payment/widgets/invoice_download_button.dart';
import 'package:src/providers/payment_provider.dart';
import 'package:src/shared/widgets/common_bottom_nav.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

final myPaymentsProvider = FutureProvider.autoDispose<List<PaymentModel>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];
  final service = ref.read(paymentServiceProvider);
  return service.getByPayerId(currentUser.id);
});

class MyPaymentsScreen extends ConsumerWidget {
  const MyPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(myPaymentsProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: CustomAppBar(
        elevation: 0,
        title: 'My Payments',
        centerTitle: true,
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 2),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (payments) {
          if (payments.isEmpty) return const _EmptyState();
          return _PaymentsList(payments: payments);
        },
      ),
    );
  }
}

class _PaymentsList extends StatelessWidget {
  const _PaymentsList({required this.payments});

  final List<PaymentModel> payments;

  @override
  Widget build(BuildContext context) {
    final sorted = [...payments]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _PaymentCard(payment: sorted[index]),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.payment});

  final PaymentModel payment;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy · HH:mm').format(payment.createdAt);
    final amountStr =
        '${payment.amount.toStringAsFixed(2)} ${payment.currency.toUpperCase()}';

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusBadge(status: payment.status),
                const Spacer(),
                Text(
                  amountStr,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _DetailRow(
              icon: Icons.receipt_long_outlined,
              label: 'Reservation',
              value: '#${payment.reservationId}',
            ),
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: dateStr,
            ),
            const SizedBox(height: 6),
            _DetailRow(
              icon: Icons.payment_outlined,
              label: 'Method',
              value: _methodLabel(payment.method),
            ),

            if (payment.isRefunded && payment.refundAmount != null) ...[
              const SizedBox(height: 6),
              _DetailRow(
                icon: Icons.undo_outlined,
                label: 'Refunded',
                value:
                    '${payment.refundAmount!.toStringAsFixed(2)} ${payment.currency.toUpperCase()}',
                valueColor: Colors.orange,
              ),
            ],

            const SizedBox(height: 16),
            Row(
              children: [
                // Download: only when succeeded or refunded
                if ((payment.isSuccessful || payment.isRefunded) &&
                    payment.invoiceUrl != null) ...[
                  Expanded(child: DownloadButton(payment: payment)),
                  const SizedBox(width: 8),
                ],

                // More: always visible
                Expanded(child: _MoreButton(id: payment.id)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _methodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return 'Credit / Debit Card';
      case PaymentMethod.googlePay:
        return 'Google Pay';
      case PaymentMethod.applePay:
        return 'Apple Pay';
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PaymentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _attrs(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color, Color) _attrs(PaymentStatus s) {
    switch (s) {
      case PaymentStatus.succeeded:
        return ('Paid', const Color(0xFFD1FAE5), const Color(0xFF065F46));
      case PaymentStatus.pending:
        return ('Pending', const Color(0xFFFEF3C7), const Color(0xFF92400E));
      case PaymentStatus.failed:
        return ('Failed', const Color(0xFFFEE2E2), const Color(0xFF991B1B));
      case PaymentStatus.refunded:
        return ('Refunded', const Color(0xFFFFEDD5), const Color(0xFF9A3412));
      case PaymentStatus.cancelled:
        return ('Cancelled', const Color(0xFFF3F4F6), const Color(0xFF374151));
      default:
        return ('Unknown', const Color(0xFFF3F4F6), const Color(0xFF374151));
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colorScheme.textSecondary),
        const SizedBox(width: 6),
        Text(
          '$label:',
          style: AppTextStyles.bodySmall.copyWith(
            color: context.colorScheme.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: valueColor ?? context.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: context.colorScheme.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No payments yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: context.colorScheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment history will appear here.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.colorScheme.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text('Failed to load payments', style: AppTextStyles.titleMedium),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.colorScheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showDetails(context),
      icon: const Icon(Icons.info_outline),
      label: const Text('More'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    context.push(PaymentRoutes.paymentDetailsPath, extra: id);
  }
}
