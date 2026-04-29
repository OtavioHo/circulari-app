import 'package:flutter/material.dart';

import '../../extensions/build_context_extension.dart';
import '../../theme/circulari_colors.dart';

class CirculariDataCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? backgroundColor;

  const CirculariDataCard({
    super.key,
    required this.value,
    required this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.circulariTheme.spacing;
    const borderRadius = BorderRadius.all(Radius.circular(12));

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 110, maxWidth: 110),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Color(0x4DA9A9A9),
              offset: Offset(10, 5),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: const RoundedRectangleBorder(borderRadius: borderRadius),
          color: backgroundColor ?? CirculariColorsTokens.greyscale50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: context.circulariTheme.typography.heading1.copyWith(
                    color: CirculariColorsTokens.greyscale900,
                  ),
                ),
                SizedBox(height: spacing.small),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.circulariTheme.typography.body.medium.regular
                      .copyWith(color: CirculariColorsTokens.greyscale600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
