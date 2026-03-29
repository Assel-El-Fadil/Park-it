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
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        ref.invalidate(authNotifierProvider);
        _syncOAuthProfile(data.session!);
      }

      if (data.event == AuthChangeEvent.passwordRecovery) {
        AppNavigator.goNamedNoContext(AuthRoutes.resetPassword);
      }
    });
  }

  Future<void> _syncOAuthProfile(Session session) async {
    final user = session.user;

    if (user.appMetadata['provider'] == 'email') return;

    final meta = user.userMetadata;
    if (meta == null) return;

    final firstName =
        meta['given_name'] ?? // Google
        meta['first_name'] ?? // Facebook
        (meta['full_name'] as String?)?.split(' ').first;

    final lastName =
        meta['family_name'] ?? // Google
        meta['last_name'] ?? // Facebook
        (meta['full_name'] as String?)?.split(' ').skip(1).join(' ');

    if (firstName == null && lastName == null) return;

    try {
      await Supabase.instance.client
          .from('users')
          .update({
            if (firstName != null) 'first_name': firstName,
            if (lastName != null) 'last_name': lastName,
          })
          .eq('id', user.id);

      debugPrint(
        '[AuthStateListener] OAuth profile synced: $firstName $lastName',
      );
    } catch (e) {
      debugPrint('[AuthStateListener] Failed to sync OAuth profile: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
