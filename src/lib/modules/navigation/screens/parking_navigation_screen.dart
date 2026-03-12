import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:src/modules/navigation/services/navigation_service.dart';
import 'package:src/modules/payment/models/payment_model.dart';
import 'package:src/shared/widgets/custom_appbar.dart';

class ParkingNavigationScreen extends ConsumerStatefulWidget {
  final ParkingBooking booking;
  final LatLng parkingLocation;

  const ParkingNavigationScreen({
    super.key,
    required this.booking,
    required this.parkingLocation,
  });

  @override
  ConsumerState<ParkingNavigationScreen> createState() =>
      _ParkingNavigationScreenState();
}

class _ParkingNavigationScreenState
    extends ConsumerState<ParkingNavigationScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Position? _currentPosition;
  bool _isLoading = true;
  double _distanceKm = 0;
  int _estimatedMinutes = 0;
  String _parkingAddress = '';

  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }

  Future<void> _initializeNavigation() async {
    // Get current location
    final position = await NavigationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _calculateDistance();
      _getParkingAddress();
      _setupMarkers();
      _animateToShowBothLocations();
    }
  }

  void _calculateDistance() {
    if (_currentPosition != null) {
      _distanceKm = NavigationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        widget.parkingLocation.latitude,
        widget.parkingLocation.longitude,
      );
      _estimatedMinutes = NavigationService.estimateDrivingTime(_distanceKm);
    }
  }

  Future<void> _getParkingAddress() async {
    final address = await NavigationService.getAddressFromLatLng(
      widget.parkingLocation,
    );
    setState(() {
      _parkingAddress = address;
    });
  }

  void _setupMarkers() {
    setState(() {
      // Current location marker
      if (_currentPosition != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      }

      // Parking location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('parking_location'),
          position: widget.parkingLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: widget.booking.parkingName,
            snippet: _parkingAddress,
          ),
        ),
      );
    });
  }

  void _animateToShowBothLocations() {
    if (_mapController != null && _currentPosition != null) {
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          _currentPosition!.latitude < widget.parkingLocation.latitude
              ? _currentPosition!.latitude
              : widget.parkingLocation.latitude,
          _currentPosition!.longitude < widget.parkingLocation.longitude
              ? _currentPosition!.longitude
              : widget.parkingLocation.longitude,
        ),
        northeast: LatLng(
          _currentPosition!.latitude > widget.parkingLocation.latitude
              ? _currentPosition!.latitude
              : widget.parkingLocation.latitude,
          _currentPosition!.longitude > widget.parkingLocation.longitude
              ? _currentPosition!.longitude
              : widget.parkingLocation.longitude,
        ),
      );

      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Navigate to Parking',
        automaticallyImplyLeading: true,
        centerTitle: true,
        showBottomBorder: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.parkingLocation,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _animateToShowBothLocations();
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  trafficEnabled: true,
                ),

                // Distance & ETA Card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.directions_car_rounded,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.booking.parkingName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _parkingAddress,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              theme,
                              Icons.distance_rounded,
                              '${_distanceKm.toStringAsFixed(1)} km',
                              'Distance',
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey[300],
                            ),
                            _buildStatItem(
                              theme,
                              Icons.timer_rounded,
                              NavigationService.formatDuration(
                                _estimatedMinutes,
                              ),
                              'Est. Time',
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.grey[300],
                            ),
                            _buildStatItem(
                              theme,
                              Icons.local_parking_rounded,
                              'Spot #${widget.booking.id ?? 'A12'}',
                              'Parking',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Navigate Button
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    onPressed: () => _startNavigation(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.navigation_rounded),
                        SizedBox(width: 8),
                        Text(
                          'Start Navigation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Future<void> _startNavigation(BuildContext context) async {
    await NavigationService.navigateToParking(
      context,
      widget.parkingLocation.latitude,
      widget.parkingLocation.longitude,
      widget.booking.parkingName,
    );
  }
}
