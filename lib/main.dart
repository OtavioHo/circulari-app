import 'package:flutter/material.dart';
import 'package:circulari/app.dart';
import 'package:circulari/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupInjection();
  runApp(const App());
}
