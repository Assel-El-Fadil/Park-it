import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/review/models/report_model.dart';

class ReportRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<ReportModel> createSpotReport({
    required int reporterId,
    required int targetSpotId,
    required ReportReason reason,
    required String? description,
  }) async {
    try {
      final row = await _client.from('reports').insert({
        'reporter_id': reporterId,
        'target_id': targetSpotId,
        'target_type': ReportTargetType.parkingSpot.toJson(),
        'reason': reason.toJson(),
        'description': description?.trim().isEmpty == true
            ? null
            : description?.trim(),
      }).select().single();
      return ReportModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to submit report.');
    }
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

