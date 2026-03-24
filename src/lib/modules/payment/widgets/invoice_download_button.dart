import 'package:flutter/material.dart';
import 'package:src/modules/payment/models/payment_model.dart';

class DownloadButton extends StatelessWidget {
  final PaymentModel payment;

  const DownloadButton({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: Open payment.invoiceUrl with url_launcher
      },
      icon: const Icon(Icons.download_outlined),
      label: const Text('Download invoice PDF'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
