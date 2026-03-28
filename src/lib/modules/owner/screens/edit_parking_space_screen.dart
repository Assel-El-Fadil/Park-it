import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/primary_button.dart';
import 'package:src/shared/widgets/section_header.dart';
import 'package:src/core/enums/app_enums.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/parking_spot_model.dart';

class EditParkingSpaceScreen extends ConsumerStatefulWidget {
  const EditParkingSpaceScreen({super.key, required this.parkingSpaceId});

  final String parkingSpaceId;

  @override
  ConsumerState<EditParkingSpaceScreen> createState() =>
      _EditParkingSpaceScreenState();
}

class _EditParkingSpaceScreenState
    extends ConsumerState<EditParkingSpaceScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _postalCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _priceDayCtrl;

  final _amenities = <String, bool>{
    'CCTV': true,
    'LIGHTING': true,
    'EV_CHARGER': false,
    'WHEELCHAIR': false,
    'GUARD': true,
    'CAR_WASH': false,
  };

  bool _isDynamicPricing = false;
  SpotType _spotType = SpotType.outdoor;
  SpotStatus _status = SpotStatus.available;
  int? _loadedSpotId;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: '');
    _streetCtrl = TextEditingController(text: '');
    _cityCtrl = TextEditingController(text: '');
    _countryCtrl = TextEditingController(text: '');
    _postalCtrl = TextEditingController(text: '');
    _descCtrl = TextEditingController(text: '');
    _priceCtrl = TextEditingController(text: '5');
    _priceDayCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _postalCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _priceDayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spotId = int.tryParse(widget.parkingSpaceId) ?? -1;

    final spot = ref.watch(
      ownerStoreProvider.select(
        (s) => s.spots.where((p) => p.id == spotId).firstOrNull,
      ),
    );

    if (spot != null && _loadedSpotId != spot.id) {
      _loadedSpotId = spot.id;
      _nameCtrl.text = spot.title;
      _streetCtrl.text = spot.street ?? '';
      _cityCtrl.text = spot.city ?? '';
      _countryCtrl.text = spot.country ?? '';
      _postalCtrl.text = spot.postalCode ?? '';
      _descCtrl.text = spot.description ?? '';
      _priceCtrl.text = spot.pricePerHour.toString();
      _priceDayCtrl.text = spot.pricePerDay?.toString() ?? '';
      _spotType = spot.spotType;
      _status = spot.status;

      _amenities['CCTV'] = spot.amenities?.contains(Amenity.cctv) == true;
      _amenities['LIGHTING'] = spot.amenities?.contains(Amenity.lighting) == true;
      _amenities['EV_CHARGER'] = spot.amenities?.contains(Amenity.evCharger) == true;
      _amenities['WHEELCHAIR'] = spot.amenities?.contains(Amenity.wheelchair) == true;
      _amenities['GUARD'] = spot.amenities?.contains(Amenity.guard) == true;
      _amenities['CAR_WASH'] = spot.amenities?.contains(Amenity.carWash) == true;
      _isDynamicPricing = spot.isDynamicPricing;
    }

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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Edit Spot',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Archive',
                        onPressed: spot == null
                            ? null
                            : () {
                                ref
                                    .read(ownerStoreProvider.notifier)
                                    .archiveSpot(spotId: spot.id);
                                if (!mounted) return;
                                Navigator.of(context).maybePop();
                              },
                        icon: Icon(Icons.archive_outlined, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Listing details'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Spot name',
                          prefixIcon: Icon(Icons.local_parking_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _streetCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Street',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
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
                              controller: _postalCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Postal code',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<SpotType>(
                        value: _spotType,
                        decoration: const InputDecoration(labelText: 'Spot type'),
                        items: SpotType.values
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toJson()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _spotType = v ?? _spotType),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<SpotStatus>(
                        value: _status,
                        decoration: const InputDecoration(labelText: 'Status'),
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
                        onChanged: (v) => setState(() => _status = v ?? _status),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Dynamic pricing'),
                        value: _isDynamicPricing,
                        onChanged: (v) => setState(() => _isDynamicPricing = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Pricing'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Hourly rate (min 6 MAD)',
                          prefixText: 'MAD ',
                          suffixText: '/hr',
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
                            onSelected: (value) => setState(() => _amenities[e.key] = value),
                            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.14),
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Save changes',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () {
                    if (spot == null) return;

                    final title = _nameCtrl.text.trim();
                    final description = _descCtrl.text.trim();
                    final pricePerHour =
                        double.tryParse(_priceCtrl.text.trim()) ?? 0;
                    final pricePerDay = double.tryParse(_priceDayCtrl.text.trim());

                    if (title.isEmpty) return;
                    if (pricePerHour < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Minimum price is 6.00 MAD (Stripe requires at least ≈ \$0.50 USD).',
                          ),
                        ),
                      );
                      return;
                    }

                    final spotType = _spotType;

                    final amenities = <Amenity>[];
                    if (_amenities['CCTV'] == true) amenities.add(Amenity.cctv);
                    if (_amenities['LIGHTING'] == true) amenities.add(Amenity.lighting);
                    if (_amenities['EV_CHARGER'] == true) {
                      amenities.add(Amenity.evCharger);
                    }
                    if (_amenities['WHEELCHAIR'] == true) {
                      amenities.add(Amenity.wheelchair);
                    }
                    if (_amenities['GUARD'] == true) amenities.add(Amenity.guard);
                    if (_amenities['CAR_WASH'] == true) {
                      amenities.add(Amenity.carWash);
                    }

                    final updated = ParkingSpotModel(
                      id: spot.id,
                      ownerId: spot.ownerId,
                      lotId: spot.lotId,
                      title: title,
                      description: description.isEmpty ? null : description,
                      latitude: spot.latitude,
                      longitude: spot.longitude,
                      altitude: spot.altitude,
                      street: _streetCtrl.text.trim(),
                      city: _cityCtrl.text.trim(),
                      country: _countryCtrl.text.trim(),
                      postalCode: _postalCtrl.text.trim(),
                      photos: spot.photos,
                      pricePerHour: pricePerHour,
                      pricePerDay: pricePerDay,
                      spotType: spotType,
                      vehicleTypes: spot.vehicleTypes,
                      amenities: amenities.isEmpty ? null : amenities,
                      status: _status,
                      averageRating: spot.averageRating,
                      totalReviews: spot.totalReviews,
                      totalBookings: spot.totalBookings,
                      isDynamicPricing: _isDynamicPricing,
                      createdAt: spot.createdAt,
                      updatedAt: DateTime.now(),
                    );

                    ref.read(ownerStoreProvider.notifier).updateSpot(updated);
                    if (!mounted) return;
                    Navigator.of(context).maybePop();
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

