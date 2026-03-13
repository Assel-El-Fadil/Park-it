import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:src/modules/auth/controllers/auth_controller.dart';

/// Listens to Supabase auth state changes and refreshes auth notifier when
/// user signs in (e.g. after OAuth redirect).
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
