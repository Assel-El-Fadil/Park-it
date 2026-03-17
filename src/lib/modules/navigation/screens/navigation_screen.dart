import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/navigation/widgets/bottom_info_strip.dart';
import 'package:src/modules/navigation/widgets/destination_pin.dart';
import 'package:src/modules/navigation/widgets/map_icon_button.dart';
import 'package:src/modules/navigation/widgets/user_dot.dart';
import 'package:src/providers/location_provider.dart';
import 'package:src/providers/route_provider.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({
    super.key,
    required this.destLat,
    required this.destLng,
    required this.placeName,
  });

  final double destLat;
  final double destLng;
  final String placeName;

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationScreen> {
  final _mapController = MapController();
  bool _followUser = true;

  @override
  void initState() {
    super.initState();
    ref.read(locationProvider.notifier).startTracking();
  }

  @override
  void dispose() {
    ref.read(locationProvider.notifier).stopTracking();
    _mapController.dispose();
    super.dispose();
  }

  void _fetchRoute() {
    final loc = ref.read(locationProvider).value;
    if (loc == null) return;

    ref
        .read(routeProvider.notifier)
        .fetchRoute(
          originLat: loc.latitude,
          originLng: loc.longitude,
          destLat: widget.destLat,
          destLng: widget.destLng,
        );
  }

  void _moveCamera(LatLng target, {double? bearing}) {
    _mapController.moveAndRotate(target, 17, bearing ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final routeState = ref.watch(routeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Follow user as they move
    ref.listen(locationProvider, (_, next) {
      if (!_followUser) return;
      final loc = next.value;
      if (loc == null) return;
      final bearing = ref
          .read(locationProvider.notifier)
          .bearingTo(widget.destLat, widget.destLng);
      _moveCamera(LatLng(loc.latitude, loc.longitude), bearing: bearing);
    });

    // Fetch route once location is first available
    ref.listen(locationProvider, (prev, next) {
      if (prev?.value == null && next.value != null) {
        _fetchRoute();
      }
    });

    final userLatLng = locationState.value != null
        ? LatLng(locationState.value!.latitude, locationState.value!.longitude)
        : LatLng(widget.destLat, widget.destLng);

    final polylinePoints = routeState.value?.points ?? [];

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLatLng,
              initialZoom: 15,
              onMapEvent: (event) {
                // Stop following when user manually drags
                if (event is MapEventMoveStart &&
                    event.source == MapEventSource.dragStart) {
                  if (_followUser) setState(() => _followUser = false);
                }
              },
            ),
            children: [
              // OSM tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: AppConstants.appName,
                tileProvider: NetworkTileProvider(),
              ),

              // Route polyline
              if (polylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: polylinePoints,
                      color: colorScheme.primary,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),

              // Destination marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(widget.destLat, widget.destLng),
                    width: 48,
                    height: 48,
                    child: DestinationPin(colorScheme: colorScheme),
                  ),
                ],
              ),

              // User location dot (manual — flutter_map has no built-in)
              if (locationState.hasValue)
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

          // ── Top bar ───────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  MapIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    colorScheme: colorScheme,
                  ),
                  const Spacer(),
                  if (!_followUser)
                    MapIconButton(
                      icon: Icons.my_location_rounded,
                      onTap: () {
                        setState(() => _followUser = true);
                        final loc = locationState.value;
                        if (loc != null) {
                          _moveCamera(LatLng(loc.latitude, loc.longitude));
                        }
                      },
                      colorScheme: colorScheme,
                    ),
                ],
              ),
            ),
          ),

          // ── Bottom strip ──────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomInfoStrip(
              routeState: routeState,
              placeName: widget.placeName,
              onReroute: _fetchRoute,
              colorScheme: colorScheme,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}
