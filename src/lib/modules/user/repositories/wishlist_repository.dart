import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository();
});

/// Reads `wishlists` joined with `parking_spots` (park-it.sql).
class WishlistRepository {
  SupabaseClient get _client => Supabase.instance.client;

  static const String _table = 'wishlists';

  /// Returns rows with nested `parking_spots` if FK exists in Supabase.
  Future<List<Map<String, dynamic>>> getWishlistForUser(int userId) async {
    final response = await _client
        .from(_table)
        .select('id, user_id, spot_id, added_at, parking_spots(*)')
        .eq('user_id', userId)
        .order('added_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<void> removeWishlistEntry(int wishlistId) async {
    await _client.from(_table).delete().eq('id', wishlistId);
  }
}
