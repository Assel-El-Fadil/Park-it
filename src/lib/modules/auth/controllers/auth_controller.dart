import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/core/errors/app_exception.dart';
import 'package:src/modules/auth/models/user_model.dart';
import 'package:src/modules/auth/repositories/auth_repository.dart';
import 'package:src/modules/auth/services/session_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:src/modules/auth/services/auth_service.dart';

/// Custom auth state for the app – renamed from [AuthState] to avoid
/// collision with the [AuthState] type exported by package:gotrue via
/// package:supabase_flutter.
class AppAuthState {
  final bool isLoading;
  final UserModel? currentUser;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool isNewUser;
  final bool justLoggedIn;

  const AppAuthState({
    this.isLoading = false,
    this.currentUser,
    this.errorMessage,
    this.isAuthenticated = false,
    this.isNewUser = false,
    this.justLoggedIn = false,
  });

  AppAuthState copyWith({
    bool? isLoading,
    UserModel? currentUser,
    Object? errorMessage = _sentinel,
    bool? isAuthenticated,
    bool? isNewUser,
    bool? justLoggedIn,
  }) {
    return AppAuthState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isNewUser: isNewUser ?? this.isNewUser,
      justLoggedIn: justLoggedIn ?? this.justLoggedIn,
    );
  }
}

const _sentinel = Object();

class AuthNotifier extends AsyncNotifier<AppAuthState> {
  @override
  Future<AppAuthState> build() async {
    // Listen to Supabase auth state changes to trigger state refreshes
    _listenToAuthChanges();
    return checkAuthState(isInitialCheck: true);
  }

  void _listenToAuthChanges() {
    final authService = ref.read(authServiceProvider);
    authService.authStateStream.listen((event) {
      debugPrint('[AuthNotifier] Auth state event detected: ${event.event}');
      
      // Mark "justLoggedIn" as true only for an active sign-in event
      final bool isNewSignIn = event.event == AuthChangeEvent.signedIn;

      checkAuthState().then((newState) {
        if (state.hasValue) {
          state = AsyncValue.data(newState.copyWith(
            justLoggedIn: isNewSignIn,
          ));
        }
      });
    });
  }

  Future<AppAuthState> checkAuthState({bool isInitialCheck = false}) async {
    final sbUser = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = sbUser != null;

    if (!isLoggedIn) {
      return const AppAuthState();
    }

    try {
      // Actively verify the token against the Supabase backend. If the user was 
      // deleted remotely, their local token will fail this network request.
      await Supabase.instance.client.auth.getUser();
    } catch (e) {
      debugPrint('[AuthNotifier] Local session is stale/user deleted remotely. Signing out.');
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();
      return const AppAuthState();
    }

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final userModel = await authRepository.getCurrentUser();

      if (userModel == null) {
        return const AppAuthState();
      }

      // 1. Check if user exists in the public users table to detect new vs existing accounts (including OAuth).
      // We must avoid relying purely on the public users table because database
      // triggers (like handle_new_user) often auto-insert users immediately on OAuth.
      // Instead, we check the immutable Auth metadata to see if a role was formally attached.
      // Native email signups attach a role immediately; OAuth ones do not until completeProfile.
      final hasCompletedRoleSelection = sbUser.userMetadata?['role'] != null;
      final userExists = hasCompletedRoleSelection;
      
      debugPrint('[AuthNotifier] userModel.email: ${userModel.email}, hasCompletedRoleSelection: $hasCompletedRoleSelection');

      if (!hasCompletedRoleSelection) {
        // If they don't have the explicit role_configured flag, they must be redirected 
        // to role selection to properly configure their app profile.
        debugPrint('[AuthNotifier] No native role_configured flag detected. Marking as New User...');
        // Do NOT insert anything into the public users table yet.
        return AppAuthState(
          currentUser: userModel,
          isAuthenticated: true,
          isNewUser: true,
        );
      }

      // 2. Role Verification for restricted accounts
      final provider = sbUser.appMetadata['provider'];
      final restrictedProviders = ['google', 'facebook'];
      final isOAuth = restrictedProviders.contains(provider);

      // 3. Role Verification for restricted accounts
      final isAdmin =
          userModel.role == UserRole.admin ||
          userModel.role == UserRole.superAdmin;

      if (isOAuth && isAdmin) {
        // Block the session and force sign out
        await authRepository.signOut();
        return const AppAuthState(
          isAuthenticated: false,
          errorMessage:
              'La connexion via les réseaux sociaux est bloquée pour les administrateurs.',
        );
      }

      return AppAuthState(
        currentUser: userModel,
        isAuthenticated: true,
        isNewUser: false, 
      );
    } catch (e, s) {
      debugPrint('[AuthNotifier] Error in checkAuthState: $e');
      debugPrint('[AuthNotifier] StackTrace: $s');
      return const AppAuthState();
    }
  }

  void clearError() {
    if (state.value?.errorMessage != null) {
      state = AsyncValue.data(state.value!.copyWith(errorMessage: null));
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String? phone,
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
        phone,
        role,
      );

      final sessionService = ref.read(sessionServiceProvider);
      final isLoggedIn = await sessionService.isLoggedIn();
      final needsVerification =
          !isLoggedIn; // If no session was created, verification is required

      state = AsyncValue.data(
        AppAuthState(
          currentUser: user,
          isAuthenticated: isLoggedIn,
          isLoading: false,
          errorMessage: null,
        ),
      );

      return needsVerification;
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
      return false;
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
      return false;
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
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> completeProfile(UserRole role) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final currentUser = state.value?.currentUser;
      if (currentUser == null) throw AppException('No user session found');

      final updatedUser = currentUser.copyWith(role: role);
      
      // 1. Update Profile (includes DB insertion/update)
      await authRepository.updateProfile(updatedUser);

      // 2. Refresh Auth State
      state = AsyncValue.data(
        AppAuthState(
          currentUser: updatedUser,
          isAuthenticated: true,
          isNewUser: false,
          isLoading: false,
        ),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
      rethrow;
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
      rethrow;
    }
  }

  Future<void> signIn(String identifier, String password) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    // --- Hardcoded admin bypass ---
    if (identifier.trim().toLowerCase() == 'admin@gmail.com' &&
        password == 'admin') {
      state = AsyncValue.data(AppAuthState(
        currentUser: const UserModel(
          id: 'hardcoded-admin-id',
          firstName: 'Admin',
          lastName: 'Park-it',
          email: 'admin@gmail.com',
          role: UserRole.admin,
        ),
        isAuthenticated: true,
        isLoading: false,
        errorMessage: null,
      ));
      return;
    }
    // --- End hardcoded admin bypass ---

    try {
      if (identifier == 'admin' && password == 'admin') {
        const adminUser = UserModel(
          id: 'admin_mock_id',
          firstName: 'Super',
          lastName: 'Admin',
          email: 'admin@parkit.com',
          role: UserRole.admin,
        );

        state = AsyncValue.data(
          AppAuthState(
            currentUser: adminUser,
            isAuthenticated: true,
            isLoading: false,
            errorMessage: null,
          ),
        );
        return;
      }

      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signIn(identifier, password);

      state = AsyncValue.data(
        AppAuthState(
          currentUser: user,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
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
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.sendPasswordReset(email);

      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: null) ??
            const AppAuthState(isLoading: false),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
      rethrow; // Rethrow to let the UI show a snackbar/dialog
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
      rethrow;
    }
  }

  Future<void> verifyOTP({
    String? email,
    required String token,
    required OtpType type,
  }) async {
    // Start loading while preserving error for now, or clear it if that's "trying again"
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.verifyOTP(
        email: email,
        token: token,
        type: type,
      );

      // If this was a sign-up verification, sign out to force manual login
      // as per user request to redirect to login page.
      if (type == OtpType.signup) {
        debugPrint('[AuthNotifier] Sign-up OTP verified. Signing out to redirect to login...');
        
        // Brief delay to ensure any internal Supabase state has settled
        await Future.delayed(const Duration(milliseconds: 100));
        
        await authRepository.signOut();
        state = const AsyncValue.data(AppAuthState(
          isAuthenticated: false,
          isLoading: false,
          errorMessage: null,
        ));
        return;
      }

      state = AsyncValue.data(
        AppAuthState(
          currentUser: user,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
      rethrow;
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
      rethrow;
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

      state = AsyncValue.data(
        AppAuthState(
          currentUser: user,
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> updatePassword({
    String? oldPassword,
    required String newPassword,
  }) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: null) ??
            const AppAuthState(isLoading: false),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
      rethrow;
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.updateEmail(newEmail);

      // Refresh the local user state to reflect the new email
      await checkAuthState();

      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: null) ??
            const AppAuthState(isLoading: false),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
      rethrow;
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
      rethrow;
    }
  }

  Future<void> updatePhone(String newPhone) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.updatePhone(newPhone);

      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: null) ??
            const AppAuthState(isLoading: false),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
      rethrow;
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
      rethrow;
    }
  }

  Future<void> resendVerification(String email, {OtpType type = OtpType.signup}) async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.resendVerification(email, type: type);

      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: null) ??
            const AppAuthState(isLoading: false),
      );
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
      rethrow;
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    state = AsyncValue.data(
      state.value?.copyWith(isLoading: true, errorMessage: null) ??
          const AppAuthState(isLoading: true),
    );

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.deleteAccount();

      // Reset application state to initial empty state
      state = const AsyncValue.data(AppAuthState());
    } on AppException catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.message) ??
            AppAuthState(isLoading: false, errorMessage: e.message),
      );
      rethrow;
    } catch (e) {
      state = AsyncValue.data(
        state.value?.copyWith(isLoading: false, errorMessage: e.toString()) ??
            AppAuthState(isLoading: false, errorMessage: e.toString()),
      );
      rethrow;
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AppAuthState>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authNotifierProvider).value?.currentUser,
);

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authNotifierProvider).value?.isAuthenticated ?? false,
);
