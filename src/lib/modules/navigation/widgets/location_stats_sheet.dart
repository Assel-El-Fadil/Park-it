import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/navigation/models/spot_model.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/navigation/widgets/compass_card.dart';
import 'package:src/modules/navigation/widgets/error_tile.dart';
import 'package:src/modules/navigation/widgets/image_hero.dart';
import 'package:src/modules/navigation/widgets/plain_header.dart';
import 'package:src/providers/location_provider.dart';
import 'package:src/shared/widgets/hero_stat.dart';
import 'package:src/shared/widgets/stat_card.dart';

class LocationStatsSheet extends ConsumerWidget {
  const LocationStatsSheet({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.placeName,
    this.imageUrl,
    this.onGo,
  });

  final double latitude;
  final double longitude;
  final String placeName;
  final String? imageUrl;
  final VoidCallback? onGo;

  static void showOnMap(BuildContext context, SpotModel spot) {
    LocationStatsSheet.show(
      context,
      latitude: spot.latitude,
      longitude: spot.longitude,
      placeName: spot.name,
      imageUrl: spot.imageUrl,
      onGo: () {
        AppNavigator.pop(context);
        AppNavigator.pushNamed(
          context,
          NavigationRoutes.navigation,
          extra: spot,
        );
      },
    );
  }

  static Future<void> show(
    BuildContext context, {
    required double latitude,
    required double longitude,
    required String placeName,
    String? imageUrl,
    VoidCallback? onGo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationStatsSheet(
        latitude: latitude,
        longitude: longitude,
        placeName: placeName,
        imageUrl: imageUrl,
        onGo: onGo,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final notifier = ref.read(locationProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Image hero or plain header ──────────────────────────
            if (imageUrl != null)
              ImageHero(
                imageUrl: imageUrl!,
                placeName: placeName,
                latitude: latitude,
                longitude: longitude,
                colorScheme: colorScheme,
                theme: theme,
              )
            else
              PlainHeader(
                placeName: placeName,
                latitude: latitude,
                longitude: longitude,
                colorScheme: colorScheme,
                theme: theme,
              ),

            Divider(
              indent: 24,
              endIndent: 24,
              color: colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),

            // ── Stats ───────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: locationState.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                  error: (e, _) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ErrorTile(
                      message: e.toString(),
                      onRetry: notifier.getCurrentLocation,
                    ),
                  ),
                  data: (_) {
                    final distanceLabel =
                        notifier.distanceLabel(latitude, longitude) ?? '—';
                    final bearing = notifier.bearingTo(latitude, longitude);
                    final compass =
                        notifier.compassDirection(latitude, longitude) ?? '—';
                    final eta50 = notifier.etaLabel(
                      latitude,
                      longitude,
                      speedKmh: 50,
                    );
                    final eta100 = notifier.etaLabel(
                      latitude,
                      longitude,
                      speedKmh: 100,
                    );
                    final withinCity = notifier.isWithinRadius(
                      latitude,
                      longitude,
                      5000,
                    );

                    return Column(
                      children: [
                        HeroStat(
                          value: distanceLabel,
                          label: 'Distance',
                          icon: Icons.straighten_rounded,
                          colorScheme: colorScheme,
                          theme: theme,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.explore_rounded,
                                label: 'Bearing',
                                value: bearing != null
                                    ? '${bearing.toStringAsFixed(1)}°'
                                    : '—',
                                theme: theme,
                                colorScheme: colorScheme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.navigation_rounded,
                                label: 'Direction',
                                value: compass,
                                theme: theme,
                                colorScheme: colorScheme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.directions_car_rounded,
                                label: 'ETA (city)',
                                value: eta50 ?? '—',
                                theme: theme,
                                colorScheme: colorScheme,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.speed_rounded,
                                label: 'ETA (highway)',
                                value: eta100 ?? '—',
                                theme: theme,
                                colorScheme: colorScheme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: withinCity
                                    ? Icons.location_city_rounded
                                    : Icons.terrain_rounded,
                                label: 'Range',
                                value: withinCity ? 'Nearby' : 'Far away',
                                theme: theme,
                                colorScheme: colorScheme,
                                highlight: withinCity,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CompassCard(
                                bearing: bearing,
                                colorScheme: colorScheme,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  },
                ),
              ),
            ),

            // ── Action buttons ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                8,
                24,
                MediaQuery.paddingOf(context).bottom + 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: onGo,
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('Go'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
