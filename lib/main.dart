import 'package:flutter/material.dart';
import 'app.dart';
import 'core/auth/auth_state_notifier.dart';
import 'core/di/injection.dart';
import 'core/storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupInjection();

  // Read the stored token once at startup. Any platform exception (e.g. the
  // Web Crypto OperationError on first run) is silently treated as
  // "unauthenticated" — the user simply lands on the login screen.
  try {
    final token = await sl<TokenStorage>().getAccessToken();
    if (token != null) sl<AuthStateNotifier>().setAuthenticated(true);
  } catch (e) {
    debugPrint('main: failed to restore auth state — $e');
  }

  runApp(const App());
}
