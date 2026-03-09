import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/controllers/vehicle_controller.dart';
import 'package:src/modules/auth/models/vehicle_model.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleState = ref.watch(vehicleNotifierProvider);
    final vehicles = vehicleState.value?.vehicles ?? [];
    final isLoading = vehicleState.value?.isLoading ?? false;
    final errorMessage = vehicleState.value?.errorMessage;
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Vehicles',
          style: context.textTheme.titleLarge,
        ),
      ),
      body: SafeArea(
        child: vehicles.isEmpty
            ? _EmptyState()
            : RefreshIndicator(
                onRefresh: () async {
                  if (currentUser != null) {
                    await ref
                        .read(vehicleNotifierProvider.notifier)
                        .loadVehicles(currentUser.id);
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return _VehicleCard(
                      vehicle: vehicle,
                      onDelete: () => ref
                          .read(vehicleNotifierProvider.notifier)
                          .deleteVehicle(vehicle.id),
                      onSetDefault: currentUser != null
                          ? () => ref
                              .read(vehicleNotifierProvider.notifier)
                              .setDefault(vehicle.id, currentUser.id)
                          : null,
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVehicleSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddVehicleSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddVehicleSheet(
        onSubmitted: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.onDelete,
    this.onSetDefault,
  });

  final VehicleModel vehicle;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(vehicle.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete vehicle?'),
            content: Text(
              'Remove ${vehicle.brand} ${vehicle.model} (${vehicle.plateNumber})?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                    child: Icon(
                      _vehicleTypeIcon(vehicle.type),
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.brand} ${vehicle.model}',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: context.colorScheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle.plateNumber,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.colorScheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (vehicle.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'DEFAULT',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                  ),
                ],
              ),
              if (!vehicle.isDefault && onSetDefault != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onSetDefault,
                    child: const Text('Set as default'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _vehicleTypeIcon(VehicleType type) {
    switch (type) {
      case VehicleType.car:
        return Icons.directions_car;
      case VehicleType.van:
        return Icons.airport_shuttle;
      case VehicleType.motorcycle:
        return Icons.two_wheeler;
      case VehicleType.truck:
        return Icons.local_shipping;
      case VehicleType.electric:
        return Icons.electric_car;
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: context.colorScheme.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              'No vehicles yet',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first vehicle',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddVehicleSheet extends ConsumerStatefulWidget {
  const _AddVehicleSheet({required this.onSubmitted});

  final VoidCallback onSubmitted;

  @override
  ConsumerState<_AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends ConsumerState<_AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  VehicleType _selectedType = VehicleType.car;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(vehicleNotifierProvider.notifier).addVehicle(
          _brandController.text.trim(),
          _modelController.text.trim(),
          _plateController.text.trim(),
          _selectedType,
          _colorController.text.trim(),
        );

    if (mounted) {
      widget.onSubmitted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleState = ref.watch(vehicleNotifierProvider);
    final isLoading = vehicleState.value?.isLoading ?? false;
    final errorMessage = vehicleState.value?.errorMessage;

    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.defaultPadding,
        right: AppConstants.defaultPadding,
        top: AppConstants.defaultPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            AppConstants.defaultPadding,
      ),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Add Vehicle',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  hintText: 'e.g. Toyota',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? AppConstants.validationRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model',
                  hintText: 'e.g. Camry',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? AppConstants.validationRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateController,
                decoration: const InputDecoration(
                  labelText: 'Plate number',
                  hintText: 'e.g. ABC-1234',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? AppConstants.validationRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  hintText: 'e.g. Red (optional)',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<VehicleType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Vehicle type',
                ),
                items: VehicleType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_vehicleTypeLabel(t)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedType = v);
                },
              ),
              if (errorMessage != null && errorMessage.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Add Vehicle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _vehicleTypeLabel(VehicleType type) {
    switch (type) {
      case VehicleType.car:
        return 'Car';
      case VehicleType.van:
        return 'Van';
      case VehicleType.motorcycle:
        return 'Motorcycle';
      case VehicleType.truck:
        return 'Truck';
      case VehicleType.electric:
        return 'Electric';
    }
  }
}
