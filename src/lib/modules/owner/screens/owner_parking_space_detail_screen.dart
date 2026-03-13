import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/rating_stars.dart';
import 'package:src/shared/widgets/section_header.dart';

class OwnerParkingSpaceDetailScreen extends StatelessWidget {
  const OwnerParkingSpaceDetailScreen({super.key, required this.parkingSpaceId});

  final String parkingSpaceId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: AppLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                FrostedBar(
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
                          'Spot Details',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => context.pushNamed(
                          OwnerRoutes.editParkingSpace,
                          pathParameters: {'id': parkingSpaceId},
                        ),
                        icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _HeroImage(theme: theme),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Downtown Central Plaza',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded, size: 16, color: theme.colorScheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  '4.8',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '123 Main St, City Center, Metroville',
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoTile(
                              title: 'Hourly rate',
                              value: '\$5.00/hr',
                              valueColor: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: _InfoTile(
                              title: 'Availability',
                              value: '12 spots',
                              valueColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Reviews'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const RatingStars(rating: 4.8, size: 16),
                          const SizedBox(width: 8),
                          Text('4.8 • 250+', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.goNamed(OwnerRoutes.ownerDashboard),
                            child: const Text('View all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const _ReviewPreviewTile(
                        initials: 'JD',
                        name: 'John Doe',
                        timeAgo: '2 days ago',
                        rating: 5,
                        text: 'Very easy to find and the security guard was very helpful.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest,
          child: const Center(
            child: Icon(Icons.image_outlined, size: 40),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
        color: theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _ReviewPreviewTile extends StatelessWidget {
  const _ReviewPreviewTile({
    required this.initials,
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.text,
  });

  final String initials;
  final String name;
  final String timeAgo;
  final int rating;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              initials,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    Text(timeAgo, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                RatingStars(rating: rating.toDouble(), size: 14),
                const SizedBox(height: 6),
                Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

