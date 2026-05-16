import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:unihub/features/auth/services/auth_service.dart';

/// Exposes Firebase auth state as a [ChangeNotifier] for use with [Provider].
///
/// Screens can listen to [currentUser] to reactively update based on
/// sign-in / sign-out events without needing to call [authStateChanges()]
/// directly. The router uses [currentUser] to decide which route to display.
class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;

  User? _currentUser;
  bool _isLoading = true;

  AuthNotifier({AuthService? authService})
      : _authService = authService ?? AuthService() {
    // Start listening to the Firebase auth stream
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// The currently authenticated Firebase user, or `null` if signed out.
  User? get currentUser => _currentUser;

  /// `true` while the initial auth state is being determined.
  bool get isLoading => _isLoading;

  /// `true` if a user is currently signed in.
  bool get isAuthenticated => _currentUser != null;
}
