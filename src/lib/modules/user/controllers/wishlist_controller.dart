import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/user/repositories/wishlist_repository.dart';
import 'dart:async';

/// Provider to check if a spot is saved for the current user.
final isSpotSavedProvider = 
    FutureProvider.family<bool, int>((ref, spotId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  return ref.read(wishlistRepositoryProvider).isSpotSaved(user.id, spotId);
});

/// Notifier to toggle wishlist status.
/// Using AsyncNotifier to match AuthNotifier style in this project.
class WishlistNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> toggleWishlist(int spotId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncValue.loading();
    
    try {
      final repo = ref.read(wishlistRepositoryProvider);
      final isSaved = await repo.isSpotSaved(user.id, spotId);
      
      if (isSaved) {
        await repo.removeWishlistEntryBySpot(user.id, spotId);
      } else {
        await repo.addWishlistEntry(user.id, spotId);
      }
      
      // Invalidate the check provider so UI updates
      ref.invalidate(isSpotSavedProvider(spotId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final wishlistNotifierProvider = 
    AsyncNotifierProvider<WishlistNotifier, void>(
  WishlistNotifier.new,
);
