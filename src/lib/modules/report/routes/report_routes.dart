import 'package:go_router/go_router.dart';
import 'package:src/modules/report/screens/report_detail_screen.dart';

class ReportRoutes {
  static const String reportDetail = 'report-detail';
  static const String reportDetailPath = '/reports/:id';
}

List<GoRoute> getReportRoutes() {
  return [
    GoRoute(
      path: ReportRoutes.reportDetailPath,
      name: ReportRoutes.reportDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ReportDetailScreen(reportId: id);
      },
    ),
  ];
}

