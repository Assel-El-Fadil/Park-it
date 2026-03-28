import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:src/providers/location_provider.dart';

/// A full-screen map for confirming / adjusting a parking spot location.
///
/// Push this screen and `await` the result:
/// ```dart
/// final LatLng? confirmed = await Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (_) => ConfirmLocationScreen(initial: LatLng(31.63, -8.01)),
///   ),
/// );
/// ```
///
/// Returns the confirmed [LatLng] or `null` if the user presses back.
class ConfirmLocationScreen extends ConsumerStatefulWidget {
  const ConfirmLocationScreen({super.key, this.initial});

  /// The initial marker position (from geocoding).
  /// If null, falls back to the user's current GPS location,
  /// then to Marrakesh center as a last resort.
  final LatLng? initial;

  @override
  ConsumerState<ConfirmLocationScreen> createState() =>
      _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends ConsumerState<ConfirmLocationScreen> {
  final _mapController = MapController();
  late LatLng _markerPosition;
  bool _initialized = false;

  // Marrakesh fallback
  static const _defaultCenter = LatLng(31.6295, -7.9811);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng _resolveInitial() {
    // 1. Geocoded coordinates
    if (widget.initial != null) return widget.initial!;

    // 2. User's current GPS location
    final loc = ref.read(locationProvider).value;
    if (loc != null) return LatLng(loc.latitude, loc.longitude);

    // 3. Marrakesh fallback
    return _defaultCenter;
  }

  @override
  Widget build(BuildContext context) {
    // Lazy-init (can't call ref in initState)
    if (!_initialized) {
      _markerPosition = _resolveInitial();
      _initialized = true;
      // Also request current location for the blue dot
      Future.microtask(
        () => ref.read(locationProvider.notifier).getCurrentLocation(),
      );
    }

    final theme = Theme.of(context);
    final locationState = ref.watch(locationProvider);
    final userLatLng = locationState.value != null
        ? LatLng(locationState.value!.latitude, locationState.value!.longitude)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _markerPosition,
              initialZoom: 16,
              onTap: (tapPosition, latLng) {
                setState(() => _markerPosition = latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.parkit.app',
                tileProvider: NetworkTileProvider(),
              ),

              // Draggable spot marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _markerPosition,
                    width: 60,
                    height: 60,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        // Convert screen delta to map offset
                        final camera = _mapController.camera;
                        final currentPixel =
                            camera.latLngToScreenPoint(_markerPosition);
                        final newPixel = currentPixel +
                            Point<double>(
                              details.delta.dx,
                              details.delta.dy,
                            );
                        final newLatLng =
                            camera.pointToLatLng(newPixel);
                        setState(() => _markerPosition = newLatLng);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Drag me',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 40,
                            color: theme.colorScheme.primary,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // User location blue dot
              if (userLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLatLng,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          border:
                              Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Back button ────────────────────────────────────
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Material(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(null),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Text(
                          'Confirm parking spot location',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Re-center FAB ──────────────────────────────────
          Positioned(
            right: 16,
            bottom: 180,
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              elevation: 3,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _mapController.move(_markerPosition, 16);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.my_location_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom bar with coords + confirm button ────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Coordinate display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.pin_drop_outlined,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Latitude: ${_markerPosition.latitude.toStringAsFixed(6)}',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Text(
                                    'Longitude: ${_markerPosition.longitude.toStringAsFixed(6)}',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Drag the marker or tap the map to adjust the location',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(_markerPosition);
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text(
                            'Confirm Location',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
