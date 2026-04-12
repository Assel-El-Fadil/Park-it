import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/review/models/review_model.dart';

class ReviewRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Future<ReviewModel> createReview({
    required int reservationId,
    required String reviewerId,
    required int spotId,
    required int rating,
    required String? comment,
  }) async {
    try {
      final row = await _client.from('reviews').insert({
        'reservation_id': reservationId,
        'reviewer_id': reviewerId,
        'spot_id': spotId,
        'rating': rating,
        'comment': comment?.trim().isEmpty == true ? null : comment?.trim(),
      }).select().single();

      return ReviewModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to create review.');
    }
  }

  Future<List<ReviewModel>> getReviewsByReviewer(String reviewerId) async {
    try {
      final rows = await _client
          .from('reviews')
          .select()
          .eq('reviewer_id', reviewerId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load your reviews.');
    }
  }

  Future<List<ReviewModel>> getReviewsBySpotId(int spotId) async {
    try {
      final rows = await _client
          .from('reviews')
          .select('*, users!reviewer_id(first_name, last_name, profile_photo)')
          .eq('spot_id', spotId)
          .eq('is_visible', true)
          .order('created_at', ascending: false);
      
      // Map the response manually since ReviewModel might not expect nested 'users' object directly
      // Or we can just let ReviewModel.fromJson try to parse it, but we need the reviewer name.
      // Wait, let's see if ReviewModel supports reviewerName.
      return (rows as List)
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    } catch (_) {
      throw const AppException('Failed to load spot reviews.');
    }
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

