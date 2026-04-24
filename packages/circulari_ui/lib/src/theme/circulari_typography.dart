import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CirculariBodyTextStyle {
  final TextStyle base;

  const CirculariBodyTextStyle({required this.base});

  TextStyle get black =>
      GoogleFonts.poppins(textStyle: base, fontWeight: FontWeight.w900);
  TextStyle get extraBold =>
      GoogleFonts.poppins(textStyle: base, fontWeight: FontWeight.w800);
  TextStyle get bold =>
      GoogleFonts.poppins(textStyle: base, fontWeight: FontWeight.w700);
  TextStyle get semibold =>
      GoogleFonts.poppins(textStyle: base, fontWeight: FontWeight.w600);
  TextStyle get medium =>
      GoogleFonts.poppins(textStyle: base, fontWeight: FontWeight.w500);
  TextStyle get regular =>
      GoogleFonts.poppins(textStyle: base, fontWeight: FontWeight.w400);
  TextStyle get light =>
      GoogleFonts.poppins(textStyle: base, fontWeight: FontWeight.w300);
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

  TextStyle get heading1 => GoogleFonts.montserrat(
    textStyle: heading,
    fontSize: 36,
    fontWeight: FontWeight.w700,
  );
  TextStyle get heading2 => GoogleFonts.montserrat(
    textStyle: heading,
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );
  TextStyle get heading3 => GoogleFonts.montserrat(
    textStyle: heading,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
  TextStyle get heading4 => GoogleFonts.montserrat(
    textStyle: heading,
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );
  TextStyle get heading5 => GoogleFonts.montserrat(
    textStyle: heading,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );
  TextStyle get heading6 => GoogleFonts.montserrat(
    textStyle: heading,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}

final circulariTypography = CirculariTypography(
  heading: GoogleFonts.montserrat(),
  bodyBase: GoogleFonts.poppins(),
);
