import 'package:flutter/material.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/payment/models/payment_model.dart';
import 'package:src/modules/payment/services/payment_service.dart';
import 'package:src/modules/payment/widgets/breakdown_card.dart';
import 'package:src/modules/payment/widgets/invoice_download_button.dart';
import 'package:src/modules/payment/widgets/invoice_header.dart';
import 'package:src/modules/payment/widgets/payment_details_card.dart';
import 'package:src/modules/payment/widgets/refund_card.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class InvoiceScreen extends StatefulWidget {
  final int id;

  const InvoiceScreen({super.key, required this.id});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final PaymentService _paymentService = PaymentService();

  PaymentModel? _payment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPayment();
  }

  Future<void> _fetchPayment() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final payment = await _paymentService.getById(widget.id);

      setState(() {
        _payment = payment;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: 'Invoice',
        centerTitle: true,
        actions: [
          if (_payment != null)
            IconButton(
              icon: Icon(Icons.share_outlined, color: colorScheme.onSurface),
              onPressed: _shareInvoice,
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) return _buildLoading(context);
    if (_error != null) return _buildError(context);
    if (_payment == null) return _buildEmpty(context);
    return _buildInvoice(context, _payment!);
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load invoice',
              style: textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _fetchPayment,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Invoice not found',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoice(BuildContext context, PaymentModel payment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusBanner(payment: payment),
          const SizedBox(height: 24),
          InvoiceHeader(payment: payment),
          const SizedBox(height: 20),
          BreakdownCard(payment: payment),
          const SizedBox(height: 20),
          PaymentDetailsCard(payment: payment),
          if (payment.isRefunded) ...[
            const SizedBox(height: 20),
            RefundCard(payment: payment),
          ],
          const SizedBox(height: 32),
          if (payment.invoiceUrl != null) DownloadButton(payment: payment),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _shareInvoice() {
    // TODO: implement share — e.g. Share.shareUri(Uri.parse(_payment!.invoiceUrl!))
  }
}

class _StatusBanner extends StatelessWidget {
  final PaymentModel payment;

  const _StatusBanner({required this.payment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (icon, label, bg, fg) = _statusStyle(payment.status, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: fg.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              payment.status.name.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String, Color, Color) _statusStyle(
    PaymentStatus status,
    ColorScheme cs,
  ) {
    return switch (status) {
      PaymentStatus.succeeded => (
        Icons.check_circle_outline,
        'Payment successful',
        cs.primaryContainer,
        cs.primary,
      ),
      PaymentStatus.refunded => (
        Icons.currency_exchange,
        'This payment has been refunded',
        cs.secondaryContainer,
        cs.secondary,
      ),
      PaymentStatus.failed => (
        Icons.cancel_outlined,
        'Payment failed',
        cs.errorContainer,
        cs.error,
      ),
      PaymentStatus.pending => (
        Icons.hourglass_top_outlined,
        'Payment pending',
        cs.tertiaryContainer,
        cs.tertiary,
      ),
      _ => (
        Icons.info_outline,
        status.name,
        cs.surfaceContainerHighest,
        cs.onSurfaceVariant,
      ),
    };
  }
}
