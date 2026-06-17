import 'package:flutter/material.dart';
import 'package:circulari/app.dart';
import 'package:circulari/core/di/injection.dart';
import 'package:circulari/core/purchases/purchases_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupInjection();
  await sl<PurchasesService>().configure();
  runApp(const App());
}
