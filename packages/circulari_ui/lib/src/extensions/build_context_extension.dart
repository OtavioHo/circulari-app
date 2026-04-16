import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

extension CirculariThemeContext on BuildContext {
  CirculariTheme get circulariTheme =>
      Theme.of(this).extension<CirculariTheme>()!;
}
