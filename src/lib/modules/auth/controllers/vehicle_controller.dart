import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/constants/constants.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/models/vehicle_model.dart';
import 'package:src/modules/auth/repositories/vehicle_repository.dart';
import 'package:uuid/uuid.dart';

class VehicleState {
  final List<VehicleModel> vehicles;
  final bool isLoading;
  final String? errorMessage;

  const VehicleState({
    this.vehicles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  VehicleState copyWith({
    List<VehicleModel>? vehicles,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }
}

const _sentinel = Object();

class VehicleNotifier extends AsyncNotifier<VehicleState> {
  static const _uuid = Uuid();

  @override
  Future<VehicleState> build() async {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return const VehicleState();
    }
    return loadVehicles(currentUser.id);
  }

  Future<VehicleState> loadVehicles(String userId) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const VehicleState(isLoading: true),
    );

    try {
      final vehicleRepository = ref.read(vehicleRepositoryProvider);
      final vehicles = await vehicleRepository.getVehicles(userId);

      state = AsyncValue.data(VehicleState(
        vehicles: vehicles.cast<VehicleModel>(),
        isLoading: false,
        errorMessage: null,
      ));
      return state.value ?? const VehicleState();
    } on AppException catch (e) {
      final newState = VehicleState(
        vehicles: const [],
        isLoading: false,
        errorMessage: e.message,
      );
      state = AsyncValue.data(newState);
      return newState;
    } catch (e) {
      final newState = VehicleState(
        vehicles: const [],
        isLoading: false,
        errorMessage: e.toString(),
      );
      state = AsyncValue.data(newState);
      return newState;
    }
  }

  Future<void> addVehicle(
    String brand,
    String model,
    String plate,
    VehicleType type,
    String color,
  ) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: AppConstants.errorUnauthorized,
        ) ?? VehicleState(errorMessage: AppConstants.errorUnauthorized),
      );
      return;
    }

    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const VehicleState(isLoading: true),
    );

    try {
      final vehicleRepository = ref.read(vehicleRepositoryProvider);
      final vehicle = VehicleModel(
        id: _uuid.v4(),
        ownerId: currentUser.id,
        type: type,
        brand: brand,
        model: model,
        plateNumber: plate,
        color: color.isEmpty ? null : color,
      );

      final addedVehicle = await vehicleRepository.addVehicle(vehicle);

      final vehicles = <VehicleModel>[...(state.value?.vehicles ?? []), addedVehicle];
      state = AsyncValue.data(VehicleState(
        vehicles: vehicles,
        isLoading: false,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ) ?? VehicleState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ) ?? VehicleState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> updateVehicle(VehicleModel vehicle) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const VehicleState(isLoading: true),
    );

    try {
      final vehicleRepository = ref.read(vehicleRepositoryProvider);
      await vehicleRepository.updateVehicle(vehicle);

      final vehicles = (state.value?.vehicles ?? [])
          .map((v) => v.id == vehicle.id ? vehicle : v)
          .toList();
      state = AsyncValue.data(VehicleState(
        vehicles: vehicles,
        isLoading: false,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ) ?? VehicleState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ) ?? VehicleState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> deleteVehicle(String id) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const VehicleState(isLoading: true),
    );

    try {
      final vehicleRepository = ref.read(vehicleRepositoryProvider);
      await vehicleRepository.deleteVehicle(id);

      final vehicles =
          (state.value?.vehicles ?? []).where((v) => v.id != id).toList();
      state = AsyncValue.data(VehicleState(
        vehicles: vehicles,
        isLoading: false,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ) ?? VehicleState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ) ?? VehicleState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> setDefault(String id, String userId) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const VehicleState(isLoading: true),
    );

    try {
      final vehicleRepository = ref.read(vehicleRepositoryProvider);
      await vehicleRepository.setDefault(id, userId);

      final vehicles = (state.value?.vehicles ?? [])
          .map((v) => v.id == id ? v.copyWith(isDefault: true) : v.copyWith(isDefault: false))
          .toList();
      state = AsyncValue.data(VehicleState(
        vehicles: vehicles,
        isLoading: false,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ) ?? VehicleState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ) ?? VehicleState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }
}

final vehicleNotifierProvider = AsyncNotifierProvider<VehicleNotifier, VehicleState>(
  VehicleNotifier.new,
);
