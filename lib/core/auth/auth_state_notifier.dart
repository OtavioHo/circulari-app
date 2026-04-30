import 'package:flutter/foundation.dart';

/// Holds the current authentication state and notifies GoRouter when it changes.
/// Updated by [AuthBloc] listeners after login, register, and logout.
class AuthStateNotifier extends ChangeNotifier {
  bool _isAuthenticated;
  String? _userName;
  String? _userEmail;
  bool _isInitializing = true;

  AuthStateNotifier(this._isAuthenticated);

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isInitializing => _isInitializing;

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

  void setUserEmail(String? email) {
    if (_userEmail == email) return;
    _userEmail = email;
    notifyListeners();
  }

  void setInitializing(bool value) {
    if (_isInitializing == value) return;
    _isInitializing = value;
    notifyListeners();
  }
}
