import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/review/models/report_model.dart';

class ReportRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<ReportModel> createSpotReport({
    required String reporterId,
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

  Future<List<ReportModel>> getReportsForOwner(String ownerId) async {
    try {
      final spots = await _client
          .from('parking_spots')
          .select('id')
          .eq('owner_id', ownerId);
      final spotIds = (spots as List)
          .map((e) => (e as Map<String, dynamic>)['id'] as int)
          .toList();
      if (spotIds.isEmpty) return const <ReportModel>[];

      final rows = await _client
          .from('reports')
          .select()
          .eq('target_type', ReportTargetType.parkingSpot.toJson())
          .inFilter('target_id', spotIds)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load owner reports.');
    }
  }

  Future<ReportModel> getReportById(int reportId) async {
    try {
      final row = await _client
          .from('reports')
          .select()
          .eq('id', reportId)
          .single();
      return ReportModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load report details.');
    }
  }

  Future<void> resolveReport({
    required int reportId,
    required String resolvedBy,
    String? resolution,
  }) async {
    try {
      await _client.from('reports').update({
        'status': ReportStatus.resolved.toJson(),
        'resolved_by': resolvedBy,
        'resolved_at': DateTime.now().toIso8601String(),
        'resolution': resolution?.trim().isEmpty == true ? null : resolution?.trim(),
      }).eq('id', reportId);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to resolve report.');
    }
  }
}

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

