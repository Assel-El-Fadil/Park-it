import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/review/routes/review_routes.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/rating_stars.dart';

class OwnerReviewsScreen extends StatelessWidget {
  const OwnerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final reviews = <_ReviewCardModel>[
      const _ReviewCardModel(
        id: 'r1',
        spotName: 'Downtown Central Plaza',
        reviewerName: 'John Doe',
        reviewerInitials: 'JD',
        rating: 5,
        timeAgo: '2 days ago',
        text: 'Very easy to find and the security guard was very helpful. Would definitely park here again!',
        hasOwnerReply: false,
      ),
      const _ReviewCardModel(
        id: 'r2',
        spotName: 'Harbor View Garage',
        reviewerName: 'Mina S.',
        reviewerInitials: 'MS',
        rating: 4,
        timeAgo: '1 week ago',
        text: 'Great location. Entry was smooth, but signage could be clearer.',
        hasOwnerReply: true,
      ),
    ];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: FrostedBar(
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Reviews',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Filter',
                      onPressed: () {},
                      icon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AppLayout(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _Pill(label: 'All', selected: true),
                        _Pill(label: 'Unreplied'),
                        _Pill(label: 'Low rating'),
                        _Pill(label: 'Last 30 days'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...reviews.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReviewCard(
                          review: r,
                          onTap: () => context.pushNamed(
                            ReviewRoutes.reviewDetail,
                            pathParameters: {'id': r.id},
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.brightness == Brightness.light
        ? Colors.white
        : theme.colorScheme.surface;
    final border = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.20)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.70);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.light ? 0.05 : 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: selected ? theme.colorScheme.primary : null),
      ),
    );
  }
}

class _ReviewCardModel {
  const _ReviewCardModel({
    required this.id,
    required this.spotName,
    required this.reviewerName,
    required this.reviewerInitials,
    required this.rating,
    required this.timeAgo,
    required this.text,
    required this.hasOwnerReply,
  });

  final String id;
  final String spotName;
  final String reviewerName;
  final String reviewerInitials;
  final int rating;
  final String timeAgo;
  final String text;
  final bool hasOwnerReply;
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review, required this.onTap});

  final _ReviewCardModel review;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  review.reviewerInitials,
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      review.spotName,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(review.timeAgo, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 10),
          RatingStars(rating: review.rating.toDouble(), size: 14),
          const SizedBox(height: 8),
          Text(
            review.text,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ReplyBadge(hasReply: review.hasOwnerReply),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReplyBadge extends StatelessWidget {
  const _ReplyBadge({required this.hasReply});

  final bool hasReply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hasReply ? Colors.green : theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        hasReply ? 'Replied' : 'Needs reply',
        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900, color: color),
      ),
    );
  }
}

