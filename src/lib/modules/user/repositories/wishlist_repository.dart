import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository();
});

/// Reads `wishlists` joined with `parking_spots` (park-it.sql).
class WishlistRepository {
  SupabaseClient get _client => Supabase.instance.client;

  static const String _table = 'wishlists';

  /// Returns rows with nested `parking_spots`.
  Future<List<Map<String, dynamic>>> getWishlistForUser(String userId) async {
    final response = await _client
        .from(_table)
        .select('*, parking_spots(*)')
        .eq('user_id', userId)
        .order('added_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<bool> isSpotSaved(String userId, int spotId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('spot_id', spotId)
        .maybeSingle();
    
    return response != null;
  }

  Future<void> addWishlistEntry(String userId, int spotId) async {
    await _client.from(_table).insert({
      'user_id': userId,
      'spot_id': spotId,
    });
  }

  Future<void> removeWishlistEntry(int wishlistId) async {
    await _client.from(_table).delete().eq('id', wishlistId);
  }

  Future<void> removeWishlistEntryBySpot(String userId, int spotId) async {
    await _client.from(_table).delete().eq('user_id', userId).eq('spot_id', spotId);
  }
}
