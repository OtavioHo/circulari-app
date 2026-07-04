import 'package:circulari_ui/src/theme/circulari_colors.dart';
import 'package:flutter/material.dart';

/// A back button rendered as a 40x40 rounded, outlined box containing a thin
/// chevron — matching the app's design spec. Defaults to popping the current
/// route; pass [onPressed] to override. The [color] applies to both the border
/// and the chevron so callers can keep each screen's existing tint.
class CirculariBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;

  const CirculariBackButton({
    super.key,
    this.onPressed,
    this.color = CirculariColorsTokens.greyscale700,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: CustomPaint(painter: _BackChevronPainter(color: color)),
        ),
      ),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  final Color color;

  _BackChevronPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinates mirror the 40x40 SVG viewBox path "M22 14 L16 20 L22 26".
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(22, 14)
      ..lineTo(16, 20)
      ..lineTo(22, 26);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BackChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
