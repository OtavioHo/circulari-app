import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/core/di/injection.dart';
import 'package:circulari/core/storage/token_storage.dart';
import 'package:circulari/features/auth/domain/usecases/get_me_usecase.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final storage = sl<TokenStorage>();
    final authNotifier = sl<AuthStateNotifier>();

    try {
      final token = await storage.getAccessToken();
      if (token != null) {
        authNotifier.setAuthenticated(true);
        var name = await storage.getUserName();
        var email = await storage.getUserEmail();
        if (name == null || email == null) {
          final user = await sl<GetMeUsecase>()();
          await Future.wait([
            storage.saveUserName(user.name),
            storage.saveUserEmail(user.email),
          ]);
          name = user.name;
          email = user.email;
        }
        authNotifier.setUserName(name);
        authNotifier.setUserEmail(email);
      }
    } catch (e) {
      debugPrint('SplashPage: failed to restore auth — $e');
    } finally {
      authNotifier.setInitializing(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CirculariAuthScaffold(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
