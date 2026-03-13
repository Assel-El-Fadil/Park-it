import 'package:flutter/material.dart';
import 'package:src/shared/widgets/app_card.dart';
import 'package:src/shared/widgets/app_layout.dart';
import 'package:src/shared/widgets/frosted_bar.dart';
import 'package:src/shared/widgets/primary_button.dart';
import 'package:src/shared/widgets/section_header.dart';

class EditParkingSpaceScreen extends StatefulWidget {
  const EditParkingSpaceScreen({super.key, required this.parkingSpaceId});

  final String parkingSpaceId;

  @override
  State<EditParkingSpaceScreen> createState() => _EditParkingSpaceScreenState();
}

class _EditParkingSpaceScreenState extends State<EditParkingSpaceScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;

  final _amenities = <String, bool>{
    'Covered': true,
    'EV Charging': true,
    '24/7 Security': true,
    'ADA': false,
  };

  @override
  void initState() {
    super.initState();
    // Mock prefill
    _nameCtrl = TextEditingController(text: 'Downtown Central Plaza');
    _addressCtrl = TextEditingController(text: '123 Main St, City Center');
    _descCtrl = TextEditingController(text: 'Premium parking in the heart of downtown.');
    _priceCtrl = TextEditingController(text: '5');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                        onPressed: () {},
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
                        controller: _addressCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Description'),
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
                          labelText: 'Hourly rate',
                          prefixText: '\$ ',
                          suffixText: '/hr',
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
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

