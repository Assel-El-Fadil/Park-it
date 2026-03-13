import 'package:flutter/material.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/primary_button.dart';
import 'package:src/shared/widgets/section_header.dart';

class ReportDetailScreen extends StatelessWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Report', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: AppLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Summary'),
                      const SizedBox(height: 10),
                      _KeyValue(label: 'Report ID', value: reportId),
                      const SizedBox(height: 8),
                      const _KeyValue(label: 'Status', value: 'Open'),
                      const SizedBox(height: 8),
                      const _KeyValue(label: 'Spot', value: 'Downtown Central Plaza'),
                      const SizedBox(height: 8),
                      const _KeyValue(label: 'Created', value: 'Yesterday • 7:20 PM'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Description'),
                      const SizedBox(height: 10),
                      Text(
                        'Customer reported noise and congestion near the entry gate during peak hours.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Actions'),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: 'Mark as resolved',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Message reporter'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 12),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

