import 'dart:ui';

class CirculariColorsTokens {
  CirculariColorsTokens._();

  // Solar Pulse — warm amber primary
  static const Color solarPulse = Color(0xFFF29F3D);
  static const Color solarPulse50  = Color(0xFFFFF6EC);
  static const Color solarPulse100 = Color(0xFFFFE2C1);
  static const Color solarPulse200 = Color(0xFFFFCF96);
  static const Color solarPulse300 = Color(0xFFFFBB6B);
  static const Color solarPulse400 = Color(0xFFF29F3D);
  static const Color solarPulse500 = Color(0xFFD0842A);
  static const Color solarPulse600 = Color(0xFFAE6A1A);
  static const Color solarPulse700 = Color(0xFF8C520E);
  static const Color solarPulse800 = Color(0xFF6A3C05);
  static const Color solarPulse900 = Color(0xFF6A3C05);

  // Fresh Core — medium green primary
  static const Color freshCore = Color(0xFF9BCB3C);
  static const Color freshCore50  = Color(0xFFF9FFEE);
  static const Color freshCore100 = Color(0xFFEDFFC9);
  static const Color freshCore200 = Color(0xFFE0FFA3);
  static const Color freshCore300 = Color(0xFFD1FC7C);
  static const Color freshCore400 = Color(0xFFB9ED52);
  static const Color freshCore500 = Color(0xFF9BCB3C);
  static const Color freshCore600 = Color(0xFF7EA929);
  static const Color freshCore700 = Color(0xFF62871A);
  static const Color freshCore800 = Color(0xFF48650E);
  static const Color freshCore900 = Color(0xFF2E4306);

  // Vital Glow — yellow-lime primary
  static const Color vitalGlow = Color(0xFFEFF669);
  static const Color vitalGlow50  = Color(0xFFFEFFF0);
  static const Color vitalGlow100 = Color(0xFFFCFFC4);
  static const Color vitalGlow200 = Color(0xFFFAFF99);
  static const Color vitalGlow300 = Color(0xFFEFF669);
  static const Color vitalGlow400 = Color(0xFFD2D955);
  static const Color vitalGlow500 = Color(0xFFB6BC44);
  static const Color vitalGlow600 = Color(0xFF999F34);
  static const Color vitalGlow700 = Color(0xFF7D8126);
  static const Color vitalGlow800 = Color(0xFF61641A);
  static const Color vitalGlow900 = Color(0xFF444710);

  // Deep Moss — muted olive-green secondary
  static const Color deepMoss = Color(0xFF3B3F34);
  static const Color deepMoss50  = Color(0xFFF5F6F5);
  static const Color deepMoss100 = Color(0xFFF1F4EC);
  static const Color deepMoss200 = Color(0xFFDADED2);
  static const Color deepMoss300 = Color(0xFFC2C7B9);
  static const Color deepMoss400 = Color(0xFFABB0A1);
  static const Color deepMoss500 = Color(0xFF949A8A);
  static const Color deepMoss600 = Color(0xFF7D8373);
  static const Color deepMoss700 = Color(0xFF676C5D);
  static const Color deepMoss800 = Color(0xFF515648);
  static const Color deepMoss900 = Color(0xFF3B3F34);

  // Forest Vault — dark teal-green secondary
  static const Color forestVault = Color(0xFF0B2319);
  static const Color forestVault50  = Color(0xFFFAFFFD);
  static const Color forestVault100 = Color(0xFFEEFFF8);
  static const Color forestVault200 = Color(0xFFE1FDF1);
  static const Color forestVault300 = Color(0xFFCFF6E6);
  static const Color forestVault400 = Color(0xFFBEEFDB);
  static const Color forestVault500 = Color(0xFF93CDB5);
  static const Color forestVault600 = Color(0xFF6DAB91);
  static const Color forestVault700 = Color(0xFF4C8970);
  static const Color forestVault800 = Color(0xFF1B4534);
  static const Color forestVault900 = Color(0xFF0B2319);

  // Greyscale — grayscale secondary
  static const Color greyscale50  = Color(0xFFFBFBFB);
  static const Color greyscale100 = Color(0xFFF6F6F6);
  static const Color greyscale200 = Color(0xFFEBEBEB);
  static const Color greyscale300 = Color(0xFFDBDBDB);
  static const Color greyscale400 = Color(0xFFAFAFAF);
  static const Color greyscale500 = Color(0xFF808080);
  static const Color greyscale600 = Color(0xFF636363);
  static const Color greyscale700 = Color(0xFF232323);
  static const Color greyscale800 = Color(0xFF111111);
  static const Color greyscale900 = Color(0xFF000000);
}

class CirculariColors {
  final Color surface;
  final Color onSurface;

  const CirculariColors({required this.surface, required this.onSurface});
}

const CirculariColors lightColors = CirculariColors(
  surface: Color(0xFF6200EE),
  onSurface: Color(0xFF03DAC6),
);

const CirculariColors darkColors = CirculariColors(
  surface: Color(0xFF121212),
  onSurface: Color(0xFFFFFFFF),
);