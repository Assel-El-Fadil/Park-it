import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/report/repositories/report_repository.dart';
import 'package:src/modules/review/models/report_model.dart';
import 'package:src/modules/report/routes/report_routes.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';

final ownerReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final ownerId = user?.id;
  if (ownerId == null || ownerId.isEmpty) return const <ReportModel>[];
  return ref.read(reportRepositoryProvider).getReportsForOwner(ownerId);
});

class OwnerReportsScreen extends ConsumerWidget {
  const OwnerReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(ownerReportsProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: FrostedBar(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Reports',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AppLayout(
              child: reportsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Text('Failed to load reports: $error'),
                ),
                data: (reports) {
                  final openCount = reports
                      .where((r) => r.status == ReportStatus.pending)
                      .length;
                  final resolvedCount = reports
                      .where((r) => r.status == ReportStatus.resolved)
                      .length;
                  final avgResolution = _avgResolutionDays(reports);
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppCard(
                          child: Row(
                            children: [
                              _Kpi(
                                label: 'Open',
                                value: '$openCount',
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              _Kpi(
                                label: 'Resolved',
                                value: '$resolvedCount',
                                color: Colors.green,
                              ),
                              const SizedBox(width: 12),
                              _Kpi(
                                label: 'Avg time',
                                value: avgResolution,
                                color: theme.colorScheme.tertiary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (reports.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 32),
                            child: Center(
                              child: Text(
                                'No reports for your spots yet.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        else
                          ...reports.map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AppCard(
                                onTap: () => context.pushNamed(
                                  ReportRoutes.reportDetail,
                                  pathParameters: {'id': r.id.toString()},
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            r.reason.toJson(),
                                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Spot #${r.targetId} • ${DateFormat('MMM d, yyyy').format(r.createdAt)}',
                                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                          ),
                                          const SizedBox(height: 10),
                                          _StatusChip(status: r.status),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _avgResolutionDays(List<ReportModel> reports) {
    final resolved = reports.where((r) => r.resolvedAt != null).toList();
    if (resolved.isEmpty) return '-';
    final totalHours = resolved.fold<int>(
      0,
      (sum, r) => sum + r.resolvedAt!.difference(r.createdAt).inHours,
    );
    final avgDays = (totalHours / resolved.length) / 24;
    return '${avgDays.toStringAsFixed(1)}d';
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    late final String label;
    late final Color color;
    switch (status) {
      case ReportStatus.pending:
        label = 'Pending';
        color = theme.colorScheme.primary;
      case ReportStatus.resolved:
        label = 'Resolved';
        color = Colors.green;
      case ReportStatus.dismissed:
        label = 'Dismissed';
        color = theme.colorScheme.tertiary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}

