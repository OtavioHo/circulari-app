import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

class CirculariTheme extends ThemeExtension<CirculariTheme> {
  final CirculariColors colors;
  final CirculariTypography typography;
  final CirculariSpacing spacing;

  const CirculariTheme({
    required this.colors,
    required this.typography,
    required this.spacing,
  });

  @override
  CirculariTheme copyWith({
    CirculariColors? colors,
    CirculariTypography? typography,
    CirculariSpacing? spacing,
  }) {
    return CirculariTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  CirculariTheme lerp(ThemeExtension<CirculariTheme>? other, double t) {
    return this;
  }
}

const CirculariTheme circulariLightTheme =  CirculariTheme(
  colors: lightColors,
  spacing: CirculariSpacing(),
  typography: circulariTypography,
);

const CirculariTheme circulariDarkTheme = CirculariTheme(
  colors: darkColors,
  spacing: CirculariSpacing(small: 8, medium: 16, large: 24),
  typography: circulariTypography,
);

final ThemeData circulariLightThemeData = ThemeData(
  brightness: Brightness.light,
  extensions: [
    circulariLightTheme,
  ],
);

final ThemeData circulariDarkThemeData = ThemeData(
  brightness: Brightness.dark,
  extensions: [
    circulariDarkTheme,
  ],
);