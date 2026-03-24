import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/owner/repositories/parking_spot_repository.dart';

/// Ajoute une ligne `parking_spots` avec `lot_id` renseigné.
class AddSpotToLotScreen extends ConsumerStatefulWidget {
  const AddSpotToLotScreen({super.key, required this.lotId});

  final int lotId;

  @override
  ConsumerState<AddSpotToLotScreen> createState() => _AddSpotToLotScreenState();
}

class _AddSpotToLotScreenState extends ConsumerState<AddSpotToLotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController(text: 'Morocco');
  final _postal = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _price = TextEditingController(text: '10');
  String _spotType = 'OUTDOOR';
  bool _loading = false;

  static const _types = [
    'OUTDOOR',
    'INDOOR',
    'COVERED',
    'VALET',
    'GARAGE',
    'STREET',
  ];

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _street.dispose();
    _city.dispose();
    _country.dispose();
    _postal.dispose();
    _lat.dispose();
    _lng.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit({bool addAnother = false}) async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    final ownerId = int.tryParse(user?.id ?? '') ?? 0;
    if (ownerId <= 0) return;

    setState(() => _loading = true);
    try {
      await ref.read(parkingSpotRepositoryProvider).insertSpot(
            ownerId: ownerId,
            lotId: widget.lotId,
            title: _title.text.trim(),
            description:
                _desc.text.trim().isEmpty ? null : _desc.text.trim(),
            latitude: double.tryParse(_lat.text.trim()) ?? 0,
            longitude: double.tryParse(_lng.text.trim()) ?? 0,
            street: _street.text.trim(),
            city: _city.text.trim(),
            country: _country.text.trim(),
            postalCode: _postal.text.trim(),
            pricePerHour: double.tryParse(_price.text.trim()) ?? 0,
            spotTypeDb: _spotType,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place ajoutée au parking.')),
      );
      if (addAnother) {
        _title.clear();
        _desc.clear();
        _price.text = '10';
      } else {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lotId <= 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Identifiant de parking invalide.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Place dans le lot #${widget.lotId}'),
        backgroundColor: context.backgroundColor,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            DropdownButtonFormField<String>(
              value: _spotType,
              decoration: const InputDecoration(labelText: 'Type de place'),
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _spotType = v ?? 'OUTDOOR'),
            ),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Titre *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            TextFormField(
              controller: _desc,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            TextFormField(
              controller: _street,
              decoration: const InputDecoration(labelText: 'Rue *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            TextFormField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'Ville *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            TextFormField(
              controller: _country,
              decoration: const InputDecoration(labelText: 'Pays *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            TextFormField(
              controller: _postal,
              decoration: const InputDecoration(labelText: 'Code postal *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lat,
                    decoration: const InputDecoration(labelText: 'Latitude *'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lng,
                    decoration: const InputDecoration(labelText: 'Longitude *'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(
                labelText: 'Prix / heure (MAD) *',
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : () => _submit(addAnother: false),
              child: const Text('Enregistrer et fermer'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _loading ? null : () => _submit(addAnother: true),
              child: const Text('Enregistrer et ajouter une autre place'),
            ),
          ],
        ),
      ),
    );
  }
}
