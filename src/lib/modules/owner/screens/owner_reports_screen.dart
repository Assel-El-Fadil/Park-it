import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/report/routes/report_routes.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';

class OwnerReportsScreen extends StatelessWidget {
  const OwnerReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final reports = <_ReportCardModel>[
      const _ReportCardModel(
        id: 'p1',
        title: 'Noise complaint',
        subtitle: 'Central Plaza • Yesterday',
        status: _ReportStatus.open,
      ),
      const _ReportCardModel(
        id: 'p2',
        title: 'Blocked entry',
        subtitle: 'Harbor View • 3 days ago',
        status: _ReportStatus.inReview,
      ),
      const _ReportCardModel(
        id: 'p3',
        title: 'Incorrect pricing',
        subtitle: 'Metro Station North • 2 weeks ago',
        status: _ReportStatus.resolved,
      ),
    ];

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
                      onPressed: () {},
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
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      child: Row(
                        children: [
                          _Kpi(
                            label: 'Open',
                            value: '2',
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          _Kpi(
                            label: 'Resolved',
                            value: '14',
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _Kpi(
                            label: 'Avg time',
                            value: '1.8d',
                            color: theme.colorScheme.tertiary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...reports.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppCard(
                          onTap: () => context.pushNamed(
                            ReportRoutes.reportDetail,
                            pathParameters: {'id': r.id},
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
                                    Text(r.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 4),
                                    Text(
                                      r.subtitle,
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
              ),
            ),
          ),
        ],
      ),
    );
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

enum _ReportStatus { open, inReview, resolved }

class _ReportCardModel {
  const _ReportCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String id;
  final String title;
  final String subtitle;
  final _ReportStatus status;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    late final String label;
    late final Color color;
    switch (status) {
      case _ReportStatus.open:
        label = 'Open';
        color = theme.colorScheme.primary;
      case _ReportStatus.inReview:
        label = 'In review';
        color = theme.colorScheme.tertiary;
      case _ReportStatus.resolved:
        label = 'Resolved';
        color = Colors.green;
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

