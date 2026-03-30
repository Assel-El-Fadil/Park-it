import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:src/modules/auth/repositories/auth_repository.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/core/errors/app_exception.dart';

class OwnerVerificationState {
  final bool isLoading;
  final String? error;
  final Uint8List? idFront;
  final Uint8List? idBack;
  final List<Uint8List> propertyCertificates;

  OwnerVerificationState({
    this.isLoading = false,
    this.error,
    this.idFront,
    this.idBack,
    this.propertyCertificates = const [],
  });

  OwnerVerificationState copyWith({
    bool? isLoading,
    String? error,
    Uint8List? idFront,
    Uint8List? idBack,
    List<Uint8List>? propertyCertificates,
  }) {
    return OwnerVerificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can clear error by not passing it
      idFront: idFront ?? this.idFront,
      idBack: idBack ?? this.idBack,
      propertyCertificates: propertyCertificates ?? this.propertyCertificates,
    );
  }
}

class OwnerVerificationController extends AutoDisposeNotifier<OwnerVerificationState> {
  final ImagePicker _picker = ImagePicker();

  @override
  OwnerVerificationState build() {
    return OwnerVerificationState();
  }

  Future<void> pickIdFront() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        state = state.copyWith(idFront: bytes, error: null);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e');
    }
  }

  Future<void> pickIdBack() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        state = state.copyWith(idBack: bytes, error: null);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e');
    }
  }

  Future<void> pickPropertyCertificate() async {
    try {
      if (state.propertyCertificates.length >= 3) {
        state = state.copyWith(error: 'Maximum 3 property certificates allowed.');
        return;
      }
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        final newList = List<Uint8List>.from(state.propertyCertificates)..add(bytes);
        state = state.copyWith(propertyCertificates: newList, error: null);
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e');
    }
  }

  void removePropertyCertificate(int index) {
    if (index >= 0 && index < state.propertyCertificates.length) {
      final newList = List<Uint8List>.from(state.propertyCertificates)..removeAt(index);
      state = state.copyWith(propertyCertificates: newList);
    }
  }

  Future<bool> submitDocuments() async {
    if (state.idFront == null || state.idBack == null || state.propertyCertificates.isEmpty) {
      state = state.copyWith(error: 'All fields are required. Please upload ID Front, ID Back, and at least 1 Property Certificate.');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (user == null) {
        throw AppException('User not authenticated.');
      }

      final List<Uint8List> docs = [
        state.idFront!,
        state.idBack!,
        ...state.propertyCertificates,
      ];

      await ref.read(authRepositoryProvider).submitIdentityDocuments(user.id, docs);

      // Trigger a state reload in authNotifierProvider so the router picks up the new VerificationStatus
      await ref.read(authNotifierProvider.notifier).checkAuthState();

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final ownerVerificationControllerProvider =
    NotifierProvider.autoDispose<OwnerVerificationController, OwnerVerificationState>(
        OwnerVerificationController.new);
