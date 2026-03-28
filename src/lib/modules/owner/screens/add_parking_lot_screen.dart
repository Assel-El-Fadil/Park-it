import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/repositories/parking_lot_repository.dart';
import 'package:src/modules/owner/repositories/parking_spot_repository.dart';
import 'package:src/modules/owner/screens/confirm_location_screen.dart';
import 'package:src/providers/GeoCodingNotifier.dart';
import 'package:src/providers/location_provider.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/primary_button.dart';
import 'package:src/shared/widgets/section_header.dart';

class AddParkingLotScreen extends ConsumerStatefulWidget {
  const AddParkingLotScreen({super.key});

  @override
  ConsumerState<AddParkingLotScreen> createState() =>
      _AddParkingLotScreenState();
}

class _AddParkingLotScreenState extends ConsumerState<AddParkingLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lotName = TextEditingController();
  final _lotDescription = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController(text: 'Morocco');
  final _postal = TextEditingController();
  final _lat = TextEditingController(text: '33.5731');
  final _lng = TextEditingController(text: '-7.5898');
  final _totalSpots = TextEditingController(text: '10');
  final _spotTitle = TextEditingController();
  final _spotDescription = TextEditingController();
  final _priceHour = TextEditingController(text: '10');
  final _priceDay = TextEditingController();
  final _photos = List.generate(3, (_) => TextEditingController());
  bool _loading = false;
  String _spotType = 'OUTDOOR';

  final _amenities = <String, bool>{
    'CCTV': false,
    'LIGHTING': true,
    'EV_CHARGER': false,
    'WHEELCHAIR': false,
    'GUARD': false,
    'CAR_WASH': false,
  };

  @override
  void dispose() {
    _lotName.dispose();
    _lotDescription.dispose();
    _street.dispose();
    _city.dispose();
    _country.dispose();
    _postal.dispose();
    _lat.dispose();
    _lng.dispose();
    _totalSpots.dispose();
    _spotTitle.dispose();
    _spotDescription.dispose();
    _priceHour.dispose();
    _priceDay.dispose();
    for (final c in _photos) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final owner = ref.read(currentUserProvider);
    final ownerId = int.tryParse(owner?.id ?? '') ?? 0;
    if (ownerId <= 0) return;
    final photos = _photos.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList();
    if (photos.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins 3 photos.')),
      );
      return;
    }

    final amenities = _amenities.entries.where((e) => e.value).map((e) => e.key).toList();

    // Validate min price
    final priceHour = double.tryParse(_priceHour.text.trim()) ?? 0;
    if (priceHour < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum price is 6.00 MAD (Stripe requires at least ≈ \$0.50 USD).'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      // Use geocoding to resolve lat/lng from address
      final geocoding = ref.read(geocodingProvider.notifier);
      await geocoding.getFromFields(
        street: _street.text.trim(),
        city: _city.text.trim(),
        country: _country.text.trim(),
        postalCode: _postal.text.trim(),
      );

      final geoResult = geocoding.lastKnown();
      double? lat = geoResult?.latitude ?? double.tryParse(_lat.text.trim());
      double? lng = geoResult?.longitude ?? double.tryParse(_lng.text.trim());

      if (lat == null || lng == null) {
        // Fallback to user's GPS location
        final userLoc = ref.read(locationProvider).value;
        if (userLoc != null) {
          lat = userLoc.latitude;
          lng = userLoc.longitude;
        }
      }

      // Build initial LatLng for map
      final initialLatLng = (lat != null && lng != null)
          ? LatLng(lat, lng)
          : const LatLng(31.6295, -7.9811);

      // Navigate to map confirmation screen
      if (!mounted) return;
      final LatLng? confirmedLatLng = await Navigator.push<LatLng>(
        context,
        MaterialPageRoute(
          builder: (_) => ConfirmLocationScreen(initial: initialLatLng),
        ),
      );

      if (confirmedLatLng == null) {
        // User cancelled
        return;
      }

      lat = confirmedLatLng.latitude;
      lng = confirmedLatLng.longitude;
      final lotId = await ref.read(parkingLotRepositoryProvider).insertLot(
            ownerId: ownerId,
            name: _lotName.text.trim(),
            description: _lotDescription.text.trim().isEmpty ? null : _lotDescription.text.trim(),
            latitude: lat,
            longitude: lng,
            street: _street.text.trim(),
            city: _city.text.trim(),
            country: _country.text.trim(),
            postalCode: _postal.text.trim(),
            photos: photos,
            amenitiesDb: amenities,
            totalSpots: int.tryParse(_totalSpots.text.trim()),
          );

      await ref.read(parkingSpotRepositoryProvider).insertSpot(
            ownerId: ownerId,
            lotId: lotId,
            title: _spotTitle.text.trim(),
            description: _spotDescription.text.trim().isEmpty ? null : _spotDescription.text.trim(),
            latitude: lat,
            longitude: lng,
            street: _street.text.trim(),
            city: _city.text.trim(),
            country: _country.text.trim(),
            postalCode: _postal.text.trim(),
            photos: photos,
            pricePerHour: double.parse(_priceHour.text.trim()),
            pricePerDay: _priceDay.text.trim().isEmpty ? null : double.tryParse(_priceDay.text.trim()),
            spotTypeDb: _spotType,
            amenitiesDb: amenities,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking complet cree avec succes.')),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                        const Expanded(
                          child: Text('Nouveau parking complet', textAlign: TextAlign.center),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Parking details'),
                        const SizedBox(height: 10),
                        TextFormField(controller: _lotName, decoration: const InputDecoration(labelText: 'Parking name *'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                        const SizedBox(height: 10),
                        TextFormField(controller: _lotDescription, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                        const SizedBox(height: 10),
                        TextFormField(controller: _totalSpots, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total spots (optional)')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Location'),
                        const SizedBox(height: 10),
                        TextFormField(controller: _street, decoration: const InputDecoration(labelText: 'Street *'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                        const SizedBox(height: 10),
                        TextFormField(controller: _city, decoration: const InputDecoration(labelText: 'City *'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                        const SizedBox(height: 10),
                        TextFormField(controller: _country, decoration: const InputDecoration(labelText: 'Country *'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                        const SizedBox(height: 10),
                        TextFormField(controller: _postal, decoration: const InputDecoration(labelText: 'Postal code *'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: TextFormField(controller: _lat, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Latitude *'), validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid number' : null)),
                            const SizedBox(width: 10),
                            Expanded(child: TextFormField(controller: _lng, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Longitude *'), validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid number' : null)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'First spot in this parking'),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _spotType,
                          items: const [
                            DropdownMenuItem(value: 'OUTDOOR', child: Text('OUTDOOR')),
                            DropdownMenuItem(value: 'INDOOR', child: Text('INDOOR')),
                            DropdownMenuItem(value: 'COVERED', child: Text('COVERED')),
                            DropdownMenuItem(value: 'VALET', child: Text('VALET')),
                            DropdownMenuItem(value: 'GARAGE', child: Text('GARAGE')),
                            DropdownMenuItem(value: 'STREET', child: Text('STREET')),
                          ],
                          onChanged: (v) => setState(() => _spotType = v ?? 'OUTDOOR'),
                          decoration: const InputDecoration(labelText: 'Spot type'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(controller: _spotTitle, decoration: const InputDecoration(labelText: 'Spot title *'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                        const SizedBox(height: 10),
                        TextFormField(controller: _spotDescription, maxLines: 2, decoration: const InputDecoration(labelText: 'Spot description')),
                        const SizedBox(height: 10),
                        TextFormField(controller: _priceHour, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price per hour (min 6 MAD) *', prefixText: 'MAD ', suffixText: '/hr'), validator: (v) { final val = double.tryParse(v ?? ''); if (val == null) return 'Invalid number'; if (val < 6) return 'Minimum is 6.00 MAD'; return null; }),
                        const SizedBox(height: 10),
                        TextFormField(controller: _priceDay, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price per day (optional)', prefixText: 'MAD ', suffixText: '/day')),
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
                          children: _amenities.keys.map((k) {
                            return FilterChip(
                              label: Text(k),
                              selected: _amenities[k]!,
                              onSelected: (v) => setState(() => _amenities[k] = v),
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
                        const SectionHeader(title: 'Photos (min 3 URLs)'),
                        const SizedBox(height: 8),
                        for (var i = 0; i < _photos.length; i++) ...[
                          TextFormField(
                            controller: _photos[i],
                            decoration: InputDecoration(labelText: 'Photo URL ${i + 1} *'),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: _loading ? 'Publishing...' : 'Creer le parking complet',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _loading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
