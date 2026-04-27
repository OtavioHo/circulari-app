import 'package:flutter/material.dart';
import 'app.dart';
import 'core/auth/auth_state_notifier.dart';
import 'core/di/injection.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/domain/usecases/get_me_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupInjection();

  // Read the stored token once at startup. Any platform exception (e.g. the
  // Web Crypto OperationError on first run) is silently treated as
  // "unauthenticated" — the user simply lands on the login screen.
  try {
    final storage = sl<TokenStorage>();
    final token = await storage.getAccessToken();
    if (token != null) {
      final authNotifier = sl<AuthStateNotifier>();
      authNotifier.setAuthenticated(true);
      var name = await storage.getUserName();
      if (name == null) {
        final user = await sl<GetMeUsecase>()();
        await storage.saveUserName(user.name);
        name = user.name;
      }
      authNotifier.setUserName(name);
    }
  } catch (e) {
    debugPrint('main: failed to restore auth state — $e');
  }

  runApp(const App());
}
