import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Wraps [child] in a [MaterialApp] + [Scaffold] for widget tests.
/// Compose with [BlocProvider.value] / [MultiBlocProvider] in the call site
/// when you need to inject blocs.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget child) async {
    await pumpWidget(MaterialApp(home: Scaffold(body: child)));
  }
}
