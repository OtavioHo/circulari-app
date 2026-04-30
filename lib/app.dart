import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/core/di/injection.dart';
import 'package:circulari/core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthStateNotifier>.value(
      value: sl<AuthStateNotifier>(),
      child: MaterialApp.router(
        title: 'Circulari',
        routerConfig: appRouter,
        theme: circulariLightThemeData,
        darkTheme: circulariDarkThemeData,
      ),
    );
  }
}
