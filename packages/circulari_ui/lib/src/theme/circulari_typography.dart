import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CirculariBodyTextStyle {
  final TextStyle base;

  const CirculariBodyTextStyle({required this.base});

  TextStyle get bold => base.copyWith(fontWeight: FontWeight.w700);
  TextStyle get semibold => base.copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => base.copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => base.copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => base.copyWith(fontWeight: FontWeight.w300);
}

class CirculariTypographyBody {
  final TextStyle base;
  const CirculariTypographyBody({required this.base});

  CirculariBodyTextStyle get xLarge =>
      CirculariBodyTextStyle(base: base.copyWith(fontSize: 18));

  CirculariBodyTextStyle get large =>
      CirculariBodyTextStyle(base: base.copyWith(fontSize: 16));

  CirculariBodyTextStyle get medium =>
      CirculariBodyTextStyle(base: base.copyWith(fontSize: 14));

  CirculariBodyTextStyle get small =>
      CirculariBodyTextStyle(base: base.copyWith(fontSize: 12));

  CirculariBodyTextStyle get xSmall =>
      CirculariBodyTextStyle(base: base.copyWith(fontSize: 10));
}

class CirculariTypography {
  final TextStyle heading;
  final TextStyle bodyBase;

  const CirculariTypography({required this.heading, required this.bodyBase});

  CirculariTypographyBody get body => CirculariTypographyBody(base: bodyBase);

  TextStyle get heading1 =>
      heading.copyWith(fontSize: 36, fontWeight: FontWeight.w700);
  TextStyle get heading2 =>
      heading.copyWith(fontSize: 30, fontWeight: FontWeight.w600);
  TextStyle get heading3 =>
      heading.copyWith(fontSize: 24, fontWeight: FontWeight.w600);
  TextStyle get heading4 =>
      heading.copyWith(fontSize: 20, fontWeight: FontWeight.w500);
  TextStyle get heading5 =>
      heading.copyWith(fontSize: 18, fontWeight: FontWeight.w500);
  TextStyle get heading6 =>
      heading.copyWith(fontSize: 16, fontWeight: FontWeight.w500);
}

final circulariTypography = CirculariTypography(
  heading: GoogleFonts.montserrat(),
  bodyBase: GoogleFonts.poppins(),
);
