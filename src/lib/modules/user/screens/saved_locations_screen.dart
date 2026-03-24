import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/user/repositories/wishlist_repository.dart';

/// Driver: page d'affichage des emplacements enregistres.
/// Cette UI supporte spots + lots, et sera branchee au code d'enregistrement.
class SavedLocationsScreen extends ConsumerStatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  ConsumerState<SavedLocationsScreen> createState() =>
      _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends ConsumerState<SavedLocationsScreen> {
  int? _loadedForUid;
  Future<List<Map<String, dynamic>>>? _future;

  void _ensureFuture(int uid) {
    if (uid <= 0) {
      _loadedForUid = uid;
      _future = Future.value([]);
      return;
    }
    if (_loadedForUid != uid) {
      _loadedForUid = uid;
      _future =
          ref.read(wishlistRepositoryProvider).getWishlistForUser(uid);
    }
  }

  void _invalidateWishlist() {
    _loadedForUid = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final uid = int.tryParse(user?.id ?? '') ?? 0;
    _ensureFuture(uid);
    final future = _future!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved locations',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.textPrimary,
          ),
        ),
        backgroundColor: context.backgroundColor,
        elevation: 0,
      ),
      body: uid <= 0
          ? Center(
              child: Text(
                'Sign in to see your saved parkings.',
                style: context.textTheme.bodyLarge,
              ),
            )
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Text(
                      'Could not load favorites.\n${snapshot.error}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  );
                }
                final rows = snapshot.data ?? [];
                if (rows.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.largePadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: context.colorScheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved parkings yet',
                            style: context.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Save spots from the parking map to see them here.',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    final spot = row['parking_spots'] as Map<String, dynamic>?;
                    final lot = row['parking_lots'] as Map<String, dynamic>?;
                    final topType = (row['entry_type'] ?? row['target_type'] ?? '').toString().toUpperCase();
                    final isLot = lot != null && spot == null;
                    final title = isLot
                        ? (lot['name'] as String? ?? 'Parking lot')
                        : (spot?['title'] as String? ??
                            row['title'] as String? ??
                            row['name'] as String? ??
                            (topType == 'LOT' ? 'Parking lot' : 'Parking spot'));
                    final city = isLot
                        ? (lot['city'] as String? ?? '')
                        : (spot?['city'] as String? ?? row['city'] as String? ?? '');
                    final price = isLot ? null : (spot?['price_per_hour'] ?? row['price_per_hour']);
                    final priceStr = price != null ? '${price} MAD/h' : '';
                    final subtitle = [city, priceStr]
                        .where((e) => e.isNotEmpty)
                        .join(' · ');

                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isLot ? Icons.apartment : Icons.local_parking,
                        ),
                        title: Text(title),
                        subtitle: Text(subtitle),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final id = row['id'] as int?;
                            if (id == null) return;
                            await ref
                                .read(wishlistRepositoryProvider)
                                .removeWishlistEntry(id);
                            if (mounted) _invalidateWishlist();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
