import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:src/core/config/routes/app_routes.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';
import 'package:src/modules/auth/routes/auth_routes.dart';

/// Listens to Supabase auth state changes and refreshes auth notifier when
/// user signs in (e.g. after OAuth redirect) or handles password recovery.
class AuthStateListener extends ConsumerStatefulWidget {
  const AuthStateListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthStateListener> createState() => _AuthStateListenerState();
}

class _AuthStateListenerState extends ConsumerState<AuthStateListener> {
  StreamSubscription<AuthState>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.signedIn && data.session != null) {
          ref.invalidate(authNotifierProvider);
        }
        // When user clicks the password reset link in their email,
        // Supabase fires a passwordRecovery event. Redirect to the reset screen.
        if (data.event == AuthChangeEvent.passwordRecovery) {
          appRouter.go(AuthRoutes.resetPasswordPath);
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
