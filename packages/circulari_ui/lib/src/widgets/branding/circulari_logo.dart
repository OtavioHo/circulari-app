import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CirculariLogoOrientation { horizontal, vertical }

class CirculariLogo extends StatelessWidget {
  final CirculariLogoOrientation orientation;
  final double size;
  final Color? nameColor;

  const CirculariLogo.horizontal({
    super.key,
    this.size = 64,
    this.nameColor,
  }) : orientation = CirculariLogoOrientation.horizontal;

  const CirculariLogo.vertical({
    super.key,
    this.size = 96,
    this.nameColor,
  }) : orientation = CirculariLogoOrientation.vertical;

  @override
  Widget build(BuildContext context) {
    final mark = SvgPicture.asset(
      'assets/images/logo/circulari_logo.svg',
      package: 'circulari_ui',
      width: size,
      height: size,
    );

    final color = nameColor ?? CirculariColorsTokens.greyscale50;
    final name = Text(
      'Circulari',
      style: context.circulariTheme.typography.heading.copyWith(
        fontSize: size * 0.5,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.5,
      ),
    );

    return switch (orientation) {
      CirculariLogoOrientation.horizontal => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          mark,
          SizedBox(width: size * 0.18),
          Flexible(child: name),
        ],
      ),
      CirculariLogoOrientation.vertical => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(height: size * 0.18),
          name,
        ],
      ),
    };
  }
}
