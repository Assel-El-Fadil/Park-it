import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final ownerId = currentUser?.id ?? '';

    final spots = ref.watch(
      ownerStoreProvider.select(
        (s) => s.spots.where((p) => p.ownerId == ownerId && p.lotId == null).toList(),
      ),
    );

    final lots = ref.watch(
      ownerStoreProvider.select(
        (s) => s.lots.where((l) => l.ownerId == ownerId).toList(),
      ),
    );

    final lotSpots = ref.watch(
      ownerStoreProvider.select(
        (s) => s.spots.where((p) => p.ownerId == ownerId && p.lotId != null).toList(),
      ),
    );

    final totalSpots = spots.length;
    final totalBookings = spots.fold<int>(0, (sum, s) => sum + s.totalBookings);
    final totalReviews = spots.fold<int>(0, (sum, s) => sum + s.totalReviews);
    final averageRating = spots.isEmpty
        ? 0.0
        : spots.fold<double>(0, (sum, s) => sum + s.averageRating) /
              spots.length;
    final dynamicPricingEnabled = spots.any((s) => s.isDynamicPricing);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications.')),
            ),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Overview',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your parking spots and keep track of performance.',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _KpiGrid(
                items: [
                  _KpiItem(
                    label: 'Standalone spots',
                    value: '$totalSpots',
                    icon: Icons.local_parking_outlined,
                  ),
                  _KpiItem(
                    label: 'Parking lots',
                    value: '${lots.length}',
                    icon: Icons.garage_outlined,
                  ),
                  _KpiItem(
                    label: 'Lot spots',
                    value: '${lotSpots.length}',
                    icon: Icons.grid_view_outlined,
                  ),
                  _KpiItem(
                    label: 'Total bookings',
                    value: '$totalBookings',
                    icon: Icons.calendar_month_outlined,
                  ),
                  _KpiItem(
                    label: 'Average rating',
                    value: averageRating.toStringAsFixed(1),
                    icon: Icons.star_outline_rounded,
                  ),
                  _KpiItem(
                    label: 'Total reviews',
                    value: '$totalReviews',
                    icon: Icons.rate_review_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoBanner(
                title: 'Dynamic pricing',
                subtitle: dynamicPricingEnabled
                    ? 'Enabled for some spots.'
                    : 'Disabled. You can enable it per spot.',
                icon: Icons.bolt_outlined,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.pushNamed(OwnerRoutes.addParkingSpace),
                  icon: const Icon(Icons.add),
                  label: const Text('Add spot or lot'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed(OwnerRoutes.ownerBookings),
                  icon: const Icon(Icons.event_available_outlined),
                  label: const Text('Bookings'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () => context.pushNamed(OwnerRoutes.ownerEarnings),
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: const Text('Earnings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiItem {
  const _KpiItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.items});

  final List<_KpiItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      childAspectRatio: 1.35,
      children: items.map((e) => _KpiCard(item: e)).toList(),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.item});

  final _KpiItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: AppColors.primary),
          const Spacer(),
          Text(
            item.value,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colorScheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colorScheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
