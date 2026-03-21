import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/navigation/routes/navigation_routes.dart';
import 'package:src/modules/navigation/widgets/count_badge.dart';
import 'package:src/modules/navigation/widgets/location_stats_sheet.dart';
import 'package:src/modules/navigation/widgets/map_icon_button.dart';
import 'package:src/modules/navigation/widgets/parking_marker.dart';
import 'package:src/modules/navigation/widgets/parking_spot_bottom_legend.dart';
import 'package:src/modules/navigation/widgets/user_dot.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/providers/location_provider.dart';

class ParkingMapScreen extends ConsumerStatefulWidget {
  const ParkingMapScreen({super.key, required this.spots});

  final List<ParkingSpotModel> spots;

  @override
  ConsumerState<ParkingMapScreen> createState() => _ParkingMapPageState();
}

class _ParkingMapPageState extends ConsumerState<ParkingMapScreen> {
  final _mapController = MapController();
  ParkingSpotModel? _selectedSpot;

  late final List<ParkingSpotModel> _mappableSpots = widget.spots
      .where((s) => s.latitude != null && s.longitude != null)
      .toList();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(locationProvider.notifier).getCurrentLocation(),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _initialCenter {
    if (_mappableSpots.isNotEmpty) {
      return LatLng(
        _mappableSpots.first.latitude!,
        _mappableSpots.first.longitude!,
      );
    }
    final loc = ref.read(locationProvider).value;
    if (loc != null) return LatLng(loc.latitude, loc.longitude);
    return const LatLng(31.6295, -7.9811); // Marrakesh fallback
  }

  void _onMarkerTap(ParkingSpotModel spot) {
    setState(() => _selectedSpot = spot);

    _mapController.move(
      LatLng(spot.latitude! - 0.002, spot.longitude!),
      _mapController.camera.zoom,
    );

    _openSheet(spot);
  }

  void _openSheet(ParkingSpotModel spot) {
    final navSpot = spot.toSpotModel();

    LocationStatsSheet.show(
      context,
      latitude: navSpot.latitude,
      longitude: navSpot.longitude,
      placeName: navSpot.name,
      imageUrl: navSpot.imageUrl,
      onGo: () {
        AppNavigator.pop(context);
        GoRouter.of(context).pushNamed(
          NavigationRoutes.parkingSpotDetail,
          pathParameters: {'id': spot.id.toString()},
        );
      },
    ).whenComplete(() => setState(() => _selectedSpot = null));
  }

  Future<void> _recenter() async {
    final locationState = ref.read(locationProvider);
    
    if (locationState.isLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Locating you...'), duration: Duration(seconds: 1)),
      );
      return;
    }

    if (locationState.hasError || locationState.value == null) {
      await ref.read(locationProvider.notifier).getCurrentLocation();
    }

    final loc = ref.read(locationProvider).value;
    if (loc != null) {
      _mapController.move(LatLng(loc.latitude, loc.longitude), 14);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to get location. Please check your settings.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final userLatLng = locationState.value != null
        ? LatLng(locationState.value!.latitude, locationState.value!.longitude)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _initialCenter, initialZoom: 14),
            children: [
              // OSM tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourapp.name',
                tileProvider: NetworkTileProvider(),
              ),

              // Parking spot markers
              MarkerLayer(
                markers: _mappableSpots.map((spot) {
                  final isSelected = _selectedSpot?.id == spot.id;
                  return Marker(
                    point: LatLng(spot.latitude!, spot.longitude!),
                    width: isSelected ? 52 : 44,
                    height: isSelected ? 52 : 44,
                    child: GestureDetector(
                      onTap: () => _onMarkerTap(spot),
                      child: ParkingMarker(
                        spot: spot,
                        isSelected: isSelected,
                        colorScheme: colorScheme,
                      ),
                    ),
                  );
                }).toList(),
              ),

              // User location dot
              if (userLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLatLng,
                      width: 24,
                      height: 24,
                      child: UserDot(colorScheme: colorScheme),
                    ),
                  ],
                ),
            ],
          ),

          // ── Top bar ────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  MapIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 10),
                  // Expanded(child: _SearchBar(colorScheme: colorScheme)),
                ],
              ),
            ),
          ),

          // ── FABs (right side) ──────────────────────────────────────
          Positioned(
            right: 12,
            bottom: 120,
            child: Column(
              children: [
                // Spot count badge
                CountBadge(
                  count: _mappableSpots.length,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 10),
                // Re-center on user
                MapIconButton(
                  icon: Icons.my_location_rounded,
                  onTap: _recenter,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),

          // ── Bottom legend ──────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomLegend(
              spots: _mappableSpots,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }
}
