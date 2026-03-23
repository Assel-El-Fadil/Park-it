import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/modules/owner/data/owner_store.dart';
import 'package:src/modules/owner/models/dynamic_pricing_model.dart';

class OwnerDynamicPricingScreen extends ConsumerStatefulWidget {
  const OwnerDynamicPricingScreen({super.key, required this.spotId});

  final String spotId;

  @override
  ConsumerState<OwnerDynamicPricingScreen> createState() =>
      _OwnerDynamicPricingScreenState();
}

class _OwnerDynamicPricingScreenState
    extends ConsumerState<OwnerDynamicPricingScreen> {
  late final TextEditingController _threeCtrl;
  late final TextEditingController _sixCtrl;
  late final TextEditingController _twelveCtrl;

  bool _enabled = false;
  int? _ruleId;

  @override
  void initState() {
    super.initState();
    _threeCtrl = TextEditingController();
    _sixCtrl = TextEditingController();
    _twelveCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _threeCtrl.dispose();
    _sixCtrl.dispose();
    _twelveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.spotId) ?? -1;

    final spot = ref.watch(
      ownerStoreProvider.select((s) => s.spots.where((p) => p.id == id).firstOrNull),
    );

    final rules = ref.watch(
      ownerStoreProvider.select((s) => s.dynamicPricingBySpotId[id] ?? const []),
    );

    final firstRule = rules.isNotEmpty ? rules.first : null;

    final enabled = spot?.isDynamicPricing == true && (firstRule?.isActive ?? false);

    // Initialize fields once when data becomes available.
    if (_ruleId == null && firstRule != null) {
      _ruleId = firstRule.id;
      _enabled = enabled;
      _threeCtrl.text = (firstRule.threeHours ?? 1).toString();
      _sixCtrl.text = (firstRule.sixHours ?? 1).toString();
      _twelveCtrl.text = (firstRule.twelveHours ?? 1).toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(spot?.title ?? 'Dynamic pricing'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Enable dynamic pricing',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.textPrimary,
                ),
              ),
              value: _enabled,
              onChanged: (v) {
                setState(() => _enabled = v);
              },
            ),
            const SizedBox(height: 12),
            _MultiplierField(
              label: 'Multiplier for up to 3 hours',
              controller: _threeCtrl,
            ),
            const SizedBox(height: 12),
            _MultiplierField(
              label: 'Multiplier for up to 6 hours',
              controller: _sixCtrl,
            ),
            const SizedBox(height: 12),
            _MultiplierField(
              label: 'Multiplier for up to 12 hours',
              controller: _twelveCtrl,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final three = double.tryParse(_threeCtrl.text.trim());
                  final six = double.tryParse(_sixCtrl.text.trim());
                  final twelve = double.tryParse(_twelveCtrl.text.trim());

                  if (three == null || six == null || twelve == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid numbers.')),
                    );
                    return;
                  }

                  final ruleId = _ruleId ?? 1;
                  final rule = DynamicPricingRuleModel(
                    id: ruleId,
                    spotId: id,
                    threeHours: three,
                    sixHours: six,
                    twelveHours: twelve,
                    isActive: _enabled,
                  );

                  ref.read(ownerStoreProvider.notifier).setDynamicPricingRules(
                        spotId: id,
                        rule: rule,
                        enabled: _enabled,
                      );

                  Navigator.of(context).maybePop();
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MultiplierField extends StatelessWidget {
  const _MultiplierField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

