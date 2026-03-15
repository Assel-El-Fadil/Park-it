import 'package:flutter/material.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';

class ReviewDetailScreen extends StatefulWidget {
  const ReviewDetailScreen({super.key, required this.reviewId});

  final String reviewId;

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  final _replyCtrl = TextEditingController();
  bool _hasReply = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            'JD',
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
                                'John Doe',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colorScheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Spot: Downtown Central Plaza • 2 days ago',
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
                              i < 5 ? Icons.star : Icons.star_border,
                              size: 16,
                              color: context.colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Very easy to find and the security guard was very helpful. Would definitely park here again!',
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
                          onPressed: () => setState(() => _hasReply = true),
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
