import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/auth/repositories/auth_repository.dart';
import 'package:src/modules/auth/services/session_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Custom auth state for the app – renamed from [AuthState] to avoid
/// collision with the [AuthState] type exported by package:gotrue via
/// package:supabase_flutter.
class AppAuthState {
  final bool isLoading;
  final UserModel? currentUser;
  final String? errorMessage;
  final bool isAuthenticated;

  const AppAuthState({
    this.isLoading = false,
    this.currentUser,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AppAuthState copyWith({
    bool? isLoading,
    UserModel? currentUser,
    Object? errorMessage = _sentinel,
    bool? isAuthenticated,
  }) {
    return AppAuthState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

const _sentinel = Object();

class AuthNotifier extends AsyncNotifier<AppAuthState> {
  @override
  Future<AppAuthState> build() async {
    return checkAuthState();
  }

  Future<AppAuthState> checkAuthState() async {
    final sessionService = ref.read(sessionServiceProvider);
    final isLoggedIn = await sessionService.isLoggedIn();

    if (!isLoggedIn) {
      return const AppAuthState();
    }

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.getCurrentUser();

      if (user == null) {
        return const AppAuthState();
      }

      return AppAuthState(
        currentUser: user,
        isAuthenticated: true,
      );
    } catch (_) {
      return const AppAuthState();
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    UserRole role,
  ) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signUp(
        email,
        password,
        firstName,
        lastName,
        role,
      );

      state = AsyncValue.data(AppAuthState(
        currentUser: user,
        isAuthenticated: true,
        isLoading: false,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ) ?? AppAuthState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ) ?? AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithOAuth(provider);
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: null) ??
            const AppAuthState(isLoading: false),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ) ?? AppAuthState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ) ?? AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> signIn(String email, String password) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signIn(email, password);

      state = AsyncValue.data(AppAuthState(
        currentUser: user,
        isAuthenticated: true,
        isLoading: false,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ) ?? AppAuthState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ) ?? AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> signOut() async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();

      state = const AsyncValue.data(AppAuthState());
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ) ?? AppAuthState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ) ?? AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> updateProfile(UserModel user) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.updateProfile(user);

      state = AsyncValue.data(AppAuthState(
        currentUser: user,
        isAuthenticated: true,
        isLoading: false,
        errorMessage: null,
      ));
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ) ?? AppAuthState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ) ?? AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AppAuthState>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<UserModel?>((ref) =>
    ref.watch(authNotifierProvider).value?.currentUser);

final isAuthenticatedProvider = Provider<bool>((ref) =>
    ref.watch(authNotifierProvider).value?.isAuthenticated ?? false);
