import 'package:flutter/material.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:circulari/app.dart';
import 'package:circulari/core/di/injection.dart';
import 'package:circulari/core/purchases/purchases_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _useAndroidPhotoPicker();
  setupInjection();
  await sl<PurchasesService>().configure();
  runApp(const App());
}

/// Usa o photo picker do sistema no Android em vez do ACTION_GET_CONTENT,
/// que é o que dispensa a permissão READ_MEDIA_IMAGES.
void _useAndroidPhotoPicker() {
  final picker = ImagePickerPlatform.instance;
  if (picker is ImagePickerAndroid) {
    picker.useAndroidPhotoPicker = true;
  }
}
