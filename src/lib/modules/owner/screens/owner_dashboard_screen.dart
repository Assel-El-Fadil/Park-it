import 'package:flutter/material.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/primary_button.dart';
import 'package:src/shared/widgets/section_header.dart';

import 'package:src/modules/owner/screens/add_parking_space_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                        'Owner Dashboard',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () {},
                      icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AppLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _StatsRow(
                    items: const [
                      _StatItem(label: 'This month', value: '\$1,240', icon: Icons.payments_outlined),
                      _StatItem(label: 'Active bookings', value: '3', icon: Icons.event_available_outlined),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatsRow(
                    items: [
                      const _StatItem(label: 'Avg rating', value: '4.8', icon: Icons.star_outline_rounded),
                      _StatItem(
                        label: 'Occupancy',
                        value: '68%',
                        icon: Icons.pie_chart_outline_rounded,
                        valueColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: 'Quick actions',
                    actionText: 'View all',
                    onActionTap: () {},
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Add a new parking spot',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create a listing with photos, price and availability.',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: 'Add parking spot',
                          icon: Icons.add_circle_outline_rounded,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddParkingSpaceScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Recent activity'),
                  const SizedBox(height: 10),
                  AppCard(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      children: const [
                        _ActivityTile(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Booking confirmed',
                          subtitle: 'Central Plaza • Today, 10:00 AM',
                        ),
                        Divider(height: 1),
                        _ActivityTile(
                          icon: Icons.rate_review_outlined,
                          title: 'New review received',
                          subtitle: 'Metro Station North • 2h ago',
                        ),
                        Divider(height: 1),
                        _ActivityTile(
                          icon: Icons.flag_outlined,
                          title: 'Report opened',
                          subtitle: 'Noise complaint • Yesterday',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(item: items[0])),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(item: items[1])),
      ],
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: item.valueColor ?? theme.colorScheme.onSurface,
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

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {},
    );
  }
}

