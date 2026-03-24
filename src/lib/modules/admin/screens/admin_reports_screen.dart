import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/admin/repositories/admin_repository.dart';
import 'package:src/modules/review/models/report_model.dart';
import 'package:src/modules/report/routes/report_routes.dart';
import 'package:src/shared/widgets/app_card.dart';

final adminReportsProvider = FutureProvider.autoDispose<List<ReportModel>>((ref) {
  return ref.read(adminRepositoryProvider).getAllReports();
});

class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  bool _showResolved = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminReportsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Reports'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Show Resolved'),
                Switch(
                  value: _showResolved,
                  onChanged: (val) => setState(() => _showResolved = val),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (reports) {
          final filtered = reports.where((r) {
            if (_showResolved) return true;
            return r.status != ReportStatus.resolved && r.status != ReportStatus.dismissed;
          }).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('No reports matching filters.'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminReportsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final report = filtered[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    onTap: () {
                      // Uses the existing report detail screen mapping
                      context.pushNamed(
                        ReportRoutes.reportDetail,
                        pathParameters: {'id': report.id.toString()},
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (report.status == ReportStatus.pending
                                        ? Colors.orange
                                        : Colors.green)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                report.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: report.status == ReportStatus.pending
                                      ? Colors.orange
                                      : Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, yyyy').format(report.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 20, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              report.reason.name.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.description ?? 'No description provided',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Target: ${report.targetType.name.toUpperCase()} #${report.targetId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
