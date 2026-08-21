import 'package:circulari_ui/src/theme/circulari_colors.dart';
import 'package:flutter/material.dart';

/// A 40x40 rounded, outlined app-bar action button holding an icon — the
/// same box style as [CirculariBackButton]. The [color] applies to both the
/// border and the icon so callers can keep each screen's existing tint.
class CirculariAppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const CirculariAppBarIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color = CirculariColorsTokens.greyscale700,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
