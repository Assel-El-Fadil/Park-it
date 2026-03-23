import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/review/models/review_model.dart';

class ReviewDetailScreen extends ConsumerStatefulWidget {
  const ReviewDetailScreen({super.key, required this.reviewId});

  final String reviewId;

  @override
  ConsumerState<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends ConsumerState<ReviewDetailScreen> {
  final _replyCtrl = TextEditingController();
  bool _hasReply = false;
  int? _loadedReviewId;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewId = int.tryParse(widget.reviewId) ?? -1;

    final review = ref.watch(
      ownerStoreProvider.select((s) {
        return s.reviewsBySpotId.values
            .expand((list) => list)
            .where((r) => r.id == reviewId)
            .firstOrNull;
      }),
    );

    // Only initialize when switching to a different review.
    if (review != null && _loadedReviewId != review.id) {
      _loadedReviewId = review.id;
      final reply = review.ownerReply ?? '';
      _replyCtrl.text = reply;
      _hasReply = reply.trim().isNotEmpty;
    }

    final rating = review?.rating ?? 0;
    final comment = review?.comment ?? '';
    final initials = (review?.reviewerId ?? 0)
        .toString()
        .padLeft(2, '0')
        .substring(0, 2);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Customer feedback',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            initials,
                            style: context.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reviewer',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colorScheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Spot ID: ${review?.spotId ?? '-'}',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < rating ? Icons.star : Icons.star_border,
                              size: 16,
                              color: context.colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      comment,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Owner reply',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_hasReply) ...[
                      Text(
                        _replyCtrl.text,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _hasReply = false),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit reply'),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: _replyCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Write a short, helpful reply…',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final text = _replyCtrl.text.trim();
                            if (text.isEmpty) return;
                            if (review == null) return;

                            ref
                                .read(ownerStoreProvider.notifier)
                                .updateReviewOwnerReply(
                                  reviewId: review.id,
                                  ownerReply: text,
                                );

                            setState(() => _hasReply = true);
                          },
                          icon: const Icon(Icons.send),
                          label: const Text('Post reply'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
