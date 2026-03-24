import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/review/models/review_model.dart';
import 'package:src/modules/review/repositories/review_repository.dart';
import 'package:src/modules/review/routes/review_routes.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/rating_stars.dart';

/// Generic reviews list screen.
///
/// In this project we primarily use it for the owner flow (manage reviews).
final userReviewsProvider = FutureProvider<List<ReviewModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  final userId = int.tryParse(user?.id ?? '');
  if (userId == null) return const <ReviewModel>[];
  return ref.read(reviewRepositoryProvider).getReviewsByReviewer(userId);
});

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviewsAsync = ref.watch(userReviewsProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Reviews', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ),
        body: reviewsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (reviews) => AppLayout(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = reviews[index];
                final initials = r.reviewerId.padLeft(2, '0').substring(0, 2);
                return AppCard(
                  onTap: () => context.pushNamed(
                    ReviewRoutes.reviewDetail,
                    pathParameters: {'id': r.id.toString()},
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Spot #${r.spotId}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            RatingStars(rating: r.rating.toDouble(), size: 14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM d').format(r.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

