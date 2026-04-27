import 'package:flutter/foundation.dart';

/// Holds the current authentication state and notifies GoRouter when it changes.
/// Updated by [AuthBloc] listeners after login, register, and logout.
class AuthStateNotifier extends ChangeNotifier {
  bool _isAuthenticated;
  String? _userName;

  AuthStateNotifier(this._isAuthenticated);

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;

  void setAuthenticated(bool value) {
    if (_isAuthenticated == value) return;
    _isAuthenticated = value;
    notifyListeners();
  }

  void setUserName(String? name) {
    if (_userName == name) return;
    _userName = name;
    notifyListeners();
  }
}
