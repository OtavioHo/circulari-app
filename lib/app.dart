import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/auth/auth_state_notifier.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthStateNotifier>.value(
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
