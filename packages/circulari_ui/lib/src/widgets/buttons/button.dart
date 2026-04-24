import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

class CirculariButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CirculariButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: CirculariColorsTokens.freshCore,
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: typography.body.medium.semibold.copyWith(
          color: CirculariColorsTokens.greyscale900,
        ),
      ),
    );
  }
}
