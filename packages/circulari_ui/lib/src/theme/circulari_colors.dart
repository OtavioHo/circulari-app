import 'dart:ui';

class CirculariColors {
  final Color primary;
  final Color secondary;

  const CirculariColors({required this.primary, required this.secondary});
}

const CirculariColors lightColors = CirculariColors(
  primary: Color(0xFF6200EE),
  secondary: Color(0xFF03DAC6),
);

const CirculariColors darkColors = CirculariColors(
  primary: Color(0xFFBB86FC),
  secondary: Color(0xFF03DAC6),
);