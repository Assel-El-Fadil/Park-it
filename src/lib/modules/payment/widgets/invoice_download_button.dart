import 'package:flutter/material.dart';
import 'package:src/modules/payment/models/payment_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadButton extends StatelessWidget {
  final PaymentModel payment;

  const DownloadButton({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _downloadInvoice(context),
      icon: const Icon(Icons.download_outlined),
      label: const Text('Invoice'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _downloadInvoice(BuildContext context) async {
    if (payment.invoiceUrl == null) {
      return;
    } else {
      final uri = Uri.parse(payment.invoiceUrl as String);
      if (!await canLaunchUrl(uri)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open invoice URL')),
          );
        }
        return;
      }

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
