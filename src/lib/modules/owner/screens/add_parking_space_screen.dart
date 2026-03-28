import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/parking_lot_model.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';
import 'package:src/modules/owner/screens/confirm_location_screen.dart';
import 'package:src/modules/notification/models/notification_model.dart';
import 'package:src/modules/notification/services/notification_service.dart';
import 'package:src/providers/notification_provider.dart';
import 'package:src/providers/GeoCodingNotifier.dart';
import 'package:src/providers/location_provider.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/primary_button.dart';
import 'package:src/shared/widgets/section_header.dart';

class AddParkingSpaceScreen extends ConsumerStatefulWidget {
  const AddParkingSpaceScreen({super.key});

  @override
  ConsumerState<AddParkingSpaceScreen> createState() =>
      _AddParkingSpaceScreenState();
}

class _AddParkingSpaceScreenState extends ConsumerState<AddParkingSpaceScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'MOROCCO');
  final _postalCodeCtrl = TextEditingController();
  final _priceHourCtrl = TextEditingController(text: '6');
  final _priceDayCtrl = TextEditingController();
  final _totalSpotsCtrl = TextEditingController();
  final _latCtrl = TextEditingController(
    text: AppConstants.defaultMapLatitude.toString(),
  );
  final _lngCtrl = TextEditingController(
    text: AppConstants.defaultMapLongitude.toString(),
  );

  bool _isLotMode = false;
  int? _lotId;
  SpotType _spotType = SpotType.outdoor;
  SpotStatus _status = SpotStatus.available;
  bool _dynamicPricing = false;
  List<PlatformFile> _photos = <PlatformFile>[];
  bool _isSubmitting = false;

  final _amenities = <String, bool>{
    'CCTV': true,
    'LIGHTING': false,
    'EV_CHARGER': false,
    'WHEELCHAIR': false,
    'GUARD': false,
    'CAR_WASH': false,
  };

  final _vehicles = <String, bool>{
    'CAR': true,
    'MOTORCYCLE': false,
    'VAN': false,
    'TRUCK': false,
    'ELECTRIC': false,
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _postalCodeCtrl.dispose();
    _priceHourCtrl.dispose();
    _priceDayCtrl.dispose();
    _totalSpotsCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lots = ref.watch(ownerStoreProvider.select((s) => s.lots));

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: AppLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                FrostedBar(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          Icons.arrow_back,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _isLotMode ? 'Add Parking Lot' : 'Add Parking Spot',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Listing type'),
                      const SizedBox(height: 12),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            icon: Icon(Icons.local_parking_outlined),
                            label: Text('Spot'),
                          ),
                          ButtonSegment(
                            value: true,
                            icon: Icon(Icons.garage_outlined),
                            label: Text('Lot'),
                          ),
                        ],
                        selected: {_isLotMode},
                        onSelectionChanged: (v) =>
                            setState(() => _isLotMode = v.first),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Photos (max 5)'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final file in _photos)
                            InputChip(
                              label: Text(
                                file.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _photos.remove(file);
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (_photos.length >= 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Maximum 5 photos allowed.'),
                              ),
                            );
                            return;
                          }
                          final result = await FilePicker.platform.pickFiles(
                            allowMultiple: true,
                            type: FileType.image,
                            withData: true,
                          );
                          if (result == null) return;
                          final picked = result.files;
                          final merged = <PlatformFile>{
                            ..._photos,
                            ...picked,
                          }.toList();
                          if (merged.length > 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Only first 5 photos are kept.'),
                              ),
                            );
                          }
                          setState(() {
                            _photos = merged.take(5).toList();
                          });
                        },
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: const Text('Add photos'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Main details'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: _isLotMode ? 'Lot name' : 'Spot title',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      if (_isLotMode) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _totalSpotsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total spots',
                            hintText: 'e.g. 50',
                          ),
                        ),
                      ],
                      if (!_isLotMode && lots.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int?>(
                          value: _lotId,
                          decoration: const InputDecoration(
                            labelText: 'Parent lot (optional)',
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('No lot'),
                            ),
                            ...lots.map(
                              (lot) => DropdownMenuItem<int?>(
                                value: lot.id,
                                child: Text(lot.name),
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() => _lotId = v),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Address'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _streetCtrl,
                        decoration: const InputDecoration(labelText: 'Street'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _cityCtrl,
                        decoration: const InputDecoration(labelText: 'City'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _countryCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Country',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _postalCodeCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Postal code',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (!_isLotMode)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Spot setup'),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<SpotType>(
                          value: _spotType,
                          decoration: const InputDecoration(
                            labelText: 'Spot type',
                          ),
                          items: SpotType.values
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.toJson()),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _spotType = v ?? _spotType),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<SpotStatus>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: SpotStatus.available,
                              child: Text('AVAILABLE'),
                            ),
                            DropdownMenuItem(
                              value: SpotStatus.archived,
                              child: Text('ARCHIVED'),
                            ),
                            DropdownMenuItem(
                              value: SpotStatus.suspended,
                              child: Text('SUSPENDED'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => _status = v ?? _status),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _priceHourCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price per hour (min 6 MAD)',
                            prefixText: 'MAD ',
                            suffixText: '/h',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _priceDayCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price per day (optional)',
                            prefixText: 'MAD ',
                            suffixText: '/day',
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Dynamic pricing'),
                          value: _dynamicPricing,
                          onChanged: (v) => setState(() => _dynamicPricing = v),
                        ),
                      ],
                    ),
                  ),
                if (!_isLotMode) const SizedBox(height: 12),
                if (!_isLotMode)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Vehicle types'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _vehicles.entries.map((e) {
                            return FilterChip(
                              label: Text(e.key),
                              selected: e.value,
                              onSelected: (value) =>
                                  setState(() => _vehicles[e.key] = value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Amenities'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amenities.entries.map((e) {
                          return FilterChip(
                            label: Text(e.key),
                            selected: e.value,
                            onSelected: (value) =>
                                setState(() => _amenities[e.key] = value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: _isLotMode ? 'Create lot' : 'Publish spot',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          setState(() => _isSubmitting = true);
                          try {
                            final currentUser = ref.read(currentUserProvider);
                            final ownerId = currentUser?.id;

                            if (ownerId == null || ownerId.isEmpty) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please sign in as an owner.'),
                                ),
                              );
                              return;
                            }

                            // Use geocoding to resolve lat/lng from address fields
                            final geocoding = ref.read(
                              geocodingProvider.notifier,
                            );
                            final street = _streetCtrl.text.trim();
                            final city = _cityCtrl.text.trim();
                            final country = _countryCtrl.text.trim();
                            final postal = _postalCodeCtrl.text.trim();

                            if (street.isEmpty ||
                                city.isEmpty ||
                                country.isEmpty ||
                                postal.isEmpty) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Street, city, country and postal code are required.',
                                  ),
                                ),
                              );
                              return;
                            }

                            await geocoding.getFromFields(
                              street: street,
                              city: city,
                              country: country,
                              postalCode: postal,
                            );

                            final geoResult = geocoding.lastKnown();
                            double? lat;
                            double? lng;

                            if (geoResult != null) {
                              lat = geoResult.latitude;
                              lng = geoResult.longitude;
                            } else {
                              // Fallback to manual controller values
                              lat = double.tryParse(_latCtrl.text);
                              lng = double.tryParse(_lngCtrl.text);
                            }

                            if (lat == null || lng == null) {
                              // Fallback to user's GPS location
                              final userLoc = ref.read(locationProvider).value;
                              if (userLoc != null) {
                                lat = userLoc.latitude;
                                lng = userLoc.longitude;
                              }
                            }

                            // Build initial LatLng for map (fallback to Marrakesh)
                            final initialLatLng = (lat != null && lng != null)
                                ? LatLng(lat, lng)
                                : const LatLng(31.6295, -7.9811);

                            // Navigate to map confirmation screen
                            if (!mounted) return;
                            final LatLng? confirmedLatLng =
                                await Navigator.push<LatLng>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConfirmLocationScreen(
                                      initial: initialLatLng,
                                    ),
                                  ),
                                );

                            if (confirmedLatLng == null) {
                              // User cancelled
                              return;
                            }

                            lat = confirmedLatLng.latitude;
                            lng = confirmedLatLng.longitude;

                            final name = _nameCtrl.text.trim();
                            final desc = _descCtrl.text.trim();
                            final totalSpots =
                                int.tryParse(_totalSpotsCtrl.text.trim()) ?? 1;
                            if (_isLotMode && totalSpots <= 0) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a valid number of spots',
                                  ),
                                ),
                              );
                              return;
                            }
                            if (name.isEmpty) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Name is required.'),
                                ),
                              );
                              return;
                            }

                            final amenities = _amenities.entries
                                .where((e) => e.value)
                                .map((e) => Amenity.fromString(e.key))
                                .toList();

                            if (!mounted) return;
                            final uploadedUrls = <String>[];
                            if (_photos.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Uploading photos...')),
                              );
                              final storage = Supabase.instance.client.storage.from('parking_spots');
                              for (final file in _photos) {
                                final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
                                try {
                                  if (file.bytes != null) {
                                    await storage.uploadBinary(fileName, file.bytes!);
                                  } else if (file.path != null) {
                                    await storage.upload(fileName, File(file.path!));
                                  } else {
                                    continue;
                                  }
                                  final url = storage.getPublicUrl(fileName);
                                  uploadedUrls.add(url);
                                } catch (e) {
                                  debugPrint('Failed to upload photo: $e');
                                }
                              }
                            }

                            if (_isLotMode) {
                              await ref
                                  .read(ownerStoreProvider.notifier)
                                  .addLot(
                                    lot: ParkingLotModel(
                                      id: 0,
                                      ownerId: ownerId,
                                      name: name,
                                      description: desc.isEmpty ? null : desc,
                                      latitude: lat,
                                      longitude: lng,
                                      altitude: null,
                                      street: street,
                                      city: city,
                                      country: country,
                                      postalCode: postal,
                                      photos: uploadedUrls.isEmpty ? null : uploadedUrls,
                                      amenities: amenities.isEmpty
                                          ? null
                                          : amenities,
                                      totalSpots: totalSpots,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    ),
                                    totalSpots: totalSpots,
                                    spotType: _spotType,
                                    pricePerHour:
                                        double.tryParse(
                                          _priceHourCtrl.text.trim(),
                                        ) ??
                                        5,
                                    pricePerDay: double.tryParse(
                                      _priceDayCtrl.text.trim(),
                                    ),
                                    isDynamicPricing: _dynamicPricing,
                                    vehicleTypes: _vehicles.entries
                                        .where((e) => e.value)
                                        .map(
                                          (e) => VehicleType.fromString(e.key),
                                        )
                                        .toList(),
                                    amenities: amenities.isEmpty
                                        ? null
                                        : amenities,
                                  );
                            } else {
                              final priceHour =
                                  double.tryParse(_priceHourCtrl.text.trim()) ??
                                  0;
                              if (priceHour < 6) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Minimum price is 6.00 MAD.'),
                                  ),
                                );
                                return;
                              }
                              final priceDay = double.tryParse(
                                _priceDayCtrl.text.trim(),
                              );
                              final vehicles = _vehicles.entries
                                  .where((e) => e.value)
                                  .map((e) => VehicleType.fromString(e.key))
                                  .toList();
                              await ref
                                  .read(ownerStoreProvider.notifier)
                                  .addSpot(
                                    spot: ParkingSpotModel(
                                      id: 0,
                                      ownerId: ownerId,
                                      lotId: _lotId,
                                      title: name,
                                      description: desc.isEmpty ? null : desc,
                                      latitude: lat,
                                      longitude: lng,
                                      altitude: null,
                                      street: street,
                                      city: city,
                                      country: country,
                                      postalCode: postal,
                                      photos: uploadedUrls.isEmpty ? null : uploadedUrls,
                                      pricePerHour: priceHour,
                                      pricePerDay: priceDay,
                                      spotType: _spotType,
                                      vehicleTypes: vehicles.isEmpty
                                          ? null
                                          : vehicles,
                                      amenities: amenities.isEmpty
                                          ? null
                                          : amenities,
                                      status: _status,
                                      averageRating: 0,
                                      totalReviews: 0,
                                      totalBookings: 0,
                                      isDynamicPricing: _dynamicPricing,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    ),
                                  );
                            }
                            if (!mounted) return;

                            try {
                              final notificationService = ref.read(notificationServiceProvider);
                              final spotOrLot = _isLotMode ? 'Parking lot' : 'Parking spot';
                              await notificationService.addNotification(
                                NotificationModel(
                                  userId: ownerId,
                                  type: NotificationType.system,
                                  title: '$spotOrLot Created',
                                  content: 'Your $spotOrLot "$name" has been successfully published and is now live.',
                                  isRead: false,
                                  channel: NotificationChannel.inApp,
                                  sentAt: DateTime.now(),
                                ),
                              );
                            } catch (e) {
                              debugPrint('Failed to send notification: $e');
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isLotMode
                                      ? 'Parking lot created successfully.'
                                      : 'Parking spot published successfully.',
                                ),
                              ),
                            );
                            Navigator.of(context).maybePop();
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save listing: $e'),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
