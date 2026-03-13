import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/review/routes/review_routes.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/rating_stars.dart';

/// Generic reviews list screen.
///
/// In this project we primarily use it for the owner flow (manage reviews).
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final reviews = const [
      _ReviewRow(id: 'r1', name: 'John Doe', initials: 'JD', rating: 5, timeAgo: '2 days ago'),
      _ReviewRow(id: 'r2', name: 'Mina S.', initials: 'MS', rating: 4, timeAgo: '1 week ago'),
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Reviews', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ),
        body: AppLayout(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = reviews[index];
              return AppCard(
                onTap: () => context.pushNamed(
                  ReviewRoutes.reviewDetail,
                  pathParameters: {'id': r.id},
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
                        r.initials,
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          RatingStars(rating: r.rating.toDouble(), size: 14),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(r.timeAgo, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReviewRow {
  const _ReviewRow({
    required this.id,
    required this.name,
    required this.initials,
    required this.rating,
    required this.timeAgo,
  });

  final String id;
  final String name;
  final String initials;
  final int rating;
  final String timeAgo;
}

