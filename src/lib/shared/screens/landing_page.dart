import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/notification/routes/notification_routes.dart';
import 'package:src/modules/payment/routes/payment_routes.dart';
import 'package:src/modules/reservation/routes/reservation_routes.dart';
import 'package:src/shared/widgets/common_bottom_nav.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      AppNavigator.pushNamed(
        context,
        NavigationRoutes.parkingResults,
        extra: query,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Park-it',
        automaticallyImplyLeading: false,
        centerTitle: false,
        showBottomBorder: true,
        isTransparent: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              AppNavigator.pushNamed(context, AppRoutes.settings);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More',
            onSelected: (value) {
              switch (value) {
                case 'notifications':
                  AppNavigator.pushNamed(
                    context,
                    NotificationRoutes.notifications,
                  );
                  break;
                case 'profile':
                  context.push('/profile');
                  break;
                case 'reservations':
                  AppNavigator.pushNamed(
                    context,
                    ReservationRoutes.reservations,
                  );
                  break;
                case 'payments':
                  AppNavigator.pushNamed(context, PaymentRoutes.myPayments);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'notifications',
                child: ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Notifications'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'reservations',
                child: ListTile(
                  leading: Icon(Icons.receipt_long_outlined),
                  title: Text('My Reservations'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'payments',
                child: ListTile(
                  leading: Icon(Icons.credit_card_outlined),
                  title: Text('Payments'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const CommonBottomNav(currentIndex: 0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: theme.scaffoldBackgroundColor),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'PARKING JUST GOT A LOT SIMPLER',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Book the Best Spaces & Save Up to 50%',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Search Bar
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Search input field
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: theme.colorScheme.primary,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onSubmitted: (_) => _onSearch(),
                                          style: theme.textTheme.bodyLarge,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Search address, place or event...',
                                            hintStyle: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            filled: false,
                                            isDense: false,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 20,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Compact search button
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FilledButton.icon(
                                          onPressed: _onSearch,
                                          icon: const Icon(
                                            Icons.search,
                                            size: 18,
                                          ),
                                          label: const Text('Search'),
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            minimumSize: const Size(0, 40),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Quick suggestion chips
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children:
                                        [
                                              'Casablanca',
                                              'Fes',
                                              'Tetouan',
                                              'Tanger',
                                              'Rabat',
                                            ]
                                            .map(
                                              (label) => Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: ActionChip(
                                                  label: Text(
                                                    label,
                                                    style: theme
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                  onPressed: () {
                                                    _searchController.text =
                                                        label;
                                                    _onSearch();
                                                  },
                                                  side: BorderSide(
                                                    color: theme
                                                        .colorScheme
                                                        .outline
                                                        .withOpacity(0.25),
                                                  ),
                                                  backgroundColor: theme
                                                      .colorScheme
                                                      .surfaceVariant
                                                      .withOpacity(0.5),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                      ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
