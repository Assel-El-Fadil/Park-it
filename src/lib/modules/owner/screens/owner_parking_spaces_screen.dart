import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:src/modules/owner/routes/owner_routes.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/empty_state.dart';
import 'package:src/shared/widgets/frosted_bar.dart';

class OwnerParkingSpacesScreen extends StatelessWidget {
  const OwnerParkingSpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final spots = <_OwnerSpotCardModel>[
      const _OwnerSpotCardModel(
        id: '42',
        title: 'Downtown Central Plaza',
        subtitle: '123 Main St • Covered • EV',
        pricePerHour: 5,
        availabilityLabel: '12 spots',
        rating: 4.8,
      ),
      const _OwnerSpotCardModel(
        id: '07',
        title: 'Harbor View Garage',
        subtitle: '456 Waterfront Ave • Security',
        pricePerHour: 8,
        availabilityLabel: '6 spots',
        rating: 4.6,
      ),
    ];

    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.pushNamed(OwnerRoutes.addParkingSpace),
          icon: const Icon(Icons.add),
          label: const Text('Add spot'),
        ),
        body: CustomScrollView(
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
                          'My Parking Spots',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Search',
                        onPressed: () {},
                        icon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
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
                      if (spots.isEmpty)
                        EmptyState(
                          title: 'No spots yet',
                          subtitle: 'Add your first parking spot to start earning.',
                          icon: Icons.local_parking_outlined,
                          action: FilledButton(
                            onPressed: () => context.pushNamed(OwnerRoutes.addParkingSpace),
                            child: const Text('Add parking spot'),
                          ),
                        )
                      else
                        ...spots.map(
                          (spot) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OwnerSpotCard(
                              spot: spot,
                              onTap: () => context.pushNamed(
                                OwnerRoutes.parkingSpaceDetail,
                                pathParameters: {'id': spot.id},
                              ),
                              onEdit: () => context.pushNamed(
                                OwnerRoutes.editParkingSpace,
                                pathParameters: {'id': spot.id},
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
      ),
    );
  }
}

class _OwnerSpotCardModel {
  const _OwnerSpotCardModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pricePerHour,
    required this.availabilityLabel,
    required this.rating,
  });

  final String id;
  final String title;
  final String subtitle;
  final double pricePerHour;
  final String availabilityLabel;
  final double rating;
}

class _OwnerSpotCard extends StatelessWidget {
  const _OwnerSpotCard({
    required this.spot,
    required this.onTap,
    required this.onEdit,
  });

  final _OwnerSpotCardModel spot;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spot.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      spot.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                tooltip: 'Edit',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Badge(
                icon: Icons.attach_money_rounded,
                label: '\$${spot.pricePerHour.toStringAsFixed(0)}/hr',
              ),
              const SizedBox(width: 8),
              _Badge(
                icon: Icons.event_available_outlined,
                label: spot.availabilityLabel,
                color: Colors.green,
              ),
              const Spacer(),
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
                      spot.rating.toStringAsFixed(1),
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: effectiveColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: effectiveColor),
          ),
        ],
      ),
    );
  }
}

