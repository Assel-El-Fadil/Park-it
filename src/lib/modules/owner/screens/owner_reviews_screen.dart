import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/review/routes/review_routes.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/rating_stars.dart';

class OwnerReviewsScreen extends ConsumerStatefulWidget {
  const OwnerReviewsScreen({super.key});

  @override
  ConsumerState<OwnerReviewsScreen> createState() => _OwnerReviewsScreenState();
}

class _OwnerReviewsScreenState extends ConsumerState<OwnerReviewsScreen> {
  int _selectedFilter = 0; // 0 all, 1 unreplied, 2 low rating, 3 last 30 days

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = ref.watch(ownerStoreProvider.select((s) => s.spots));
    final allReviews = ref.watch(
      ownerStoreProvider.select(
        (s) => s.reviewsBySpotId.values.expand((list) => list).toList(),
      ),
    );
    final spotNameById = <int, String>{
      for (final s in spots) s.id: s.title,
    };
    final now = DateTime.now();
    final reviews = allReviews.where((r) {
      switch (_selectedFilter) {
        case 1:
          return (r.ownerReply ?? '').trim().isEmpty;
        case 2:
          return r.rating <= 2;
        case 3:
          return now.difference(r.createdAt).inDays <= 30;
        default:
          return true;
      }
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
                      onPressed: () => Navigator.of(context).maybePop(),
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
                      children: [
                        _Pill(
                          label: 'All',
                          selected: _selectedFilter == 0,
                          onTap: () => setState(() => _selectedFilter = 0),
                        ),
                        _Pill(
                          label: 'Unreplied',
                          selected: _selectedFilter == 1,
                          onTap: () => setState(() => _selectedFilter = 1),
                        ),
                        _Pill(
                          label: 'Low rating',
                          selected: _selectedFilter == 2,
                          onTap: () => setState(() => _selectedFilter = 2),
                        ),
                        _Pill(
                          label: 'Last 30 days',
                          selected: _selectedFilter == 3,
                          onTap: () => setState(() => _selectedFilter = 3),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 32),
                        child: Center(
                          child: Text(
                            'No reviews found.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                    ...reviews.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReviewCard(
                          review: _ReviewCardModel(
                            id: r.id.toString(),
                            spotName: spotNameById[r.spotId] ?? 'Spot #${r.spotId}',
                            reviewerName: r.reviewerName ?? 'User ${r.reviewerId}',
                            reviewerInitials: (r.reviewerName?.isNotEmpty == true)
                                ? r.reviewerName!.substring(0, 1).toUpperCase()
                                : r.reviewerId.substring(0, 2).toUpperCase(),
                            rating: r.rating,
                            timeAgo: DateFormat('MMM d, yyyy').format(r.createdAt),
                            text: (r.comment ?? '').trim().isEmpty ? 'No comment provided.' : r.comment!,
                            hasOwnerReply: (r.ownerReply ?? '').trim().isNotEmpty,
                          ),
                          onTap: () => context.pushNamed(
                            ReviewRoutes.reviewDetail,
                            pathParameters: {'id': r.id.toString()},
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
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.brightness == Brightness.light
        ? Colors.white
        : theme.colorScheme.surface;
    final border = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.20)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.70);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
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

