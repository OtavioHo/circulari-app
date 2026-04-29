import 'package:flutter/material.dart';

import '../../extensions/build_context_extension.dart';
import '../../theme/circulari_colors.dart';

class CirculariCardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final EdgeInsetsGeometry? padding;

  const CirculariCardButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.iconBackgroundColor,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.circulariTheme.spacing;
    const borderRadius = BorderRadius.all(Radius.circular(12));

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 110),
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
        child: Material(
          elevation: 0,
          borderRadius: borderRadius,
          color: backgroundColor ?? CirculariColorsTokens.greyscale50,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: Padding(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          iconBackgroundColor ??
                          CirculariColorsTokens.greyscale200,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      icon,
                      color: iconColor ?? CirculariColorsTokens.greyscale600,
                    ),
                  ),
                  SizedBox(height: spacing.small),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: context.circulariTheme.typography.body.medium.regular
                        .copyWith(color: CirculariColorsTokens.greyscale900),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
