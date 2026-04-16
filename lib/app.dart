import 'package:flutter/material.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'core/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Circulari',
      routerConfig: appRouter,
      theme: circulariLightThemeData,
      darkTheme: circulariDarkThemeData,
    );
  }
}
