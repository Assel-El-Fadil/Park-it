import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/admin/repositories/admin_repository.dart';
import 'package:src/modules/report/repositories/report_repository.dart';
import 'package:src/modules/review/models/report_model.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/primary_button.dart';
import 'package:src/shared/widgets/section_header.dart';

final reportDetailProvider = FutureProvider.family<({ReportModel report, String? spotTitle}), int>((
  ref,
  id,
) async {
  final report = await ref.read(reportRepositoryProvider).getReportById(id);
  String? spotTitle;
  if (report.targetType == ReportTargetType.parkingSpot) {
    final spot = await ref.read(adminRepositoryProvider).getSpotById(int.parse(report.targetId));
    spotTitle = spot?.title;
  }
  return (report: report, spotTitle: spotTitle);
});

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final id = int.tryParse(reportId) ?? -1;
    final reportAsync = ref.watch(reportDetailProvider(id));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Report',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (data) {
            final report = data.report;
            final spotTitle = data.spotTitle;
            return SingleChildScrollView(
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
                        _KeyValue(
                          label: 'Report ID',
                          value: report.id.toString(),
                        ),
                        const SizedBox(height: 8),
                        _KeyValue(
                          label: 'Status',
                          value: report.status.toJson(),
                        ),
                        const SizedBox(height: 8),
                        _KeyValue(
                          label: 'Target Spot',
                          value: spotTitle ?? '#${report.targetId}',
                        ),
                        const SizedBox(height: 8),
                        _KeyValue(
                          label: 'Created',
                          value: DateFormat(
                            'MMM d, yyyy • h:mm a',
                          ).format(report.createdAt),
                        ),
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
                          (report.description ?? '').trim().isEmpty
                              ? 'No description provided.'
                              : report.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
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
                        if (report.status != ReportStatus.resolved)
                          PrimaryButton(
                            label: 'Mark as resolved',
                            icon: Icons.check_circle_outline_rounded,
                            onPressed: () async {
                              final user = ref.read(currentUserProvider);
                              final resolvedBy = user?.id;
                              if (resolvedBy == null) return;
                              await ref
                                  .read(reportRepositoryProvider)
                                  .resolveReport(
                                    reportId: report.id,
                                    resolvedBy: resolvedBy,
                                  );
                              ref.invalidate(reportDetailProvider(id));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Report marked as resolved.'),
                                ),
                              );
                            },
                          ),
                        if (report.status == ReportStatus.resolved)
                          const Text('This report is already resolved.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            );
          },
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
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
