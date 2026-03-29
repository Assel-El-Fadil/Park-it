import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:src/modules/auth/controllers/auth_controller.dart';

/// A [Listenable] that notifies GoRouter when the authentication state changes.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Listen to the auth state and notify GoRouter on any change
    _ref.listen(
      authNotifierProvider,
      (previous, next) {
        debugPrint('[RouterNotifier] Auth state changed, notifying GoRouter');
        notifyListeners();
      },
    );
  }
}
