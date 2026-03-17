import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/navigation/models/spot_model.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/navigation/widgets/location_stats_sheet.dart';
import 'package:src/providers/location_provider.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationScreen> {
  // ── Hardcoded test spot — swap for a real model later ──────────────
  static const _testSpot = SpotModel(
    id: 'jemaa-el-fna',
    name: 'Jemaa el-Fna',
    latitude: 31.6295,
    longitude: -7.9811,
    imageUrl: 'https://picsum.photos/seed/spot1a/800/500',
    description: 'Famous square in the medina of Marrakesh.',
    category: 'Landmark',
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(locationProvider.notifier).getCurrentLocation();
    });
  }

  void _openSheet(SpotModel spot) {
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

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(title: 'Location'),
      body: Center(
        child: locationState.when(
          loading: () => const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator.adaptive(),
              SizedBox(height: 16),
              Text('Fetching your location…'),
            ],
          ),
          error: (e, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Could not get location',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(locationProvider.notifier).getCurrentLocation(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
          data: (loc) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  size: 36,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text('Location ready', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _openSheet(_testSpot),
                icon: const Icon(Icons.place_rounded),
                label: const Text('View place stats'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
