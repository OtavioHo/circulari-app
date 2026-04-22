import 'package:flutter/material.dart';
import 'dart:math';
import '../../extensions/build_context_extension.dart';
import '../../theme/circulari_colors.dart';

class CirculariListCard extends StatelessWidget {
  final String title;
  final int itemCount;
  final double value;
  final Color backgroundColor;
  final bool isValueHidden;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onTap;
  final int? seed;

  static const double width = 200.0;
  static const double height = 250.0;

  const CirculariListCard({
    super.key,
    required this.title,
    required this.itemCount,
    required this.value,
    required this.backgroundColor,
    this.isValueHidden = false,
    this.onToggleVisibility,
    this.onTap,
    this.seed,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final waveColor = _darken(backgroundColor, 0.08);
    final effectiveSeed = seed ?? title.hashCode;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: backgroundColor)),
              Positioned.fill(
                child: CustomPaint(
                  painter: _WavePainter(color: waveColor, seed: effectiveSeed),
                ),
              ),
              Positioned(
                bottom: 18,
                left: 16,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.12),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.body.large.medium.copyWith(
                        color: CirculariColorsTokens.greyscale800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$itemCount items',
                      style: typography.body.small.light.copyWith(
                        color: CirculariColorsTokens.greyscale700,
                      ),
                    ),
                    SizedBox(height: context.circulariTheme.spacing.medium),
                    Text(
                      'Valor total',
                      style: typography.body.small.light.copyWith(
                        color: CirculariColorsTokens.greyscale700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isValueHidden ? '••••••' : 'R\$ ${_formatCurrency(value)}',
                            style: typography.body.xLarge.semibold.copyWith(
                              color: CirculariColorsTokens.greyscale900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onToggleVisibility,
                          child: Icon(
                            isValueHidden
                                ? Icons.visibility_off_outlined
                                : Icons.remove_red_eye_outlined,
                            size: 18,
                            color: CirculariColorsTokens.greyscale700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _darken(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - factor).clamp(0.0, 1.0)).toColor();
  }
  
  String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(formatted[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final int seed;

  const _WavePainter({required this.color, required this.seed});

  static const _margin = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final count = 2 + rng.nextInt(2); // 2 or 3 curves

    for (int i = 0; i < count; i++) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20.0 + rng.nextDouble() * 16 // 20–36 px
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(_curve(size, rng), paint);
    }
  }

  Path _curve(Size size, Random rng) {
    final type = rng.nextDouble();

    final Offset start, end, cp1, cp2;

    if (type < 0.55) {
      // Right edge → Bottom edge  (most common — classic corner sweep)
      start = Offset(size.width + _margin, size.height * (0.05 + rng.nextDouble() * 0.55));
      end   = Offset(size.width * (0.15 + rng.nextDouble() * 0.75), size.height + _margin);

      // cp1 goes straight left (perpendicular to right edge),
      // cp2 goes straight up (perpendicular to bottom edge) — gives a round arc.
      final hSpan = (end.dx - start.dx).abs();
      final vSpan = (end.dy - start.dy).abs();
      final h = 0.50 + rng.nextDouble() * 0.25;
      final v = 0.50 + rng.nextDouble() * 0.25;
      cp1 = Offset(start.dx - hSpan * h, start.dy + vSpan * (rng.nextDouble() * 0.12 - 0.06));
      cp2 = Offset(end.dx + hSpan * (rng.nextDouble() * 0.12 - 0.06), end.dy - vSpan * v);

    } else if (type < 0.78) {
      // Top-right → Bottom (flowing S or long sweep)
      start = Offset(size.width * (0.35 + rng.nextDouble() * 0.65), -_margin);
      end   = Offset(size.width * (0.10 + rng.nextDouble() * 0.80), size.height + _margin);

      final vSpan = size.height + 2 * _margin;
      final hDrift = end.dx - start.dx;
      final pull = 0.42 + rng.nextDouble() * 0.18;
      cp1 = Offset(start.dx + hDrift * (rng.nextDouble() * 0.25), start.dy + vSpan * pull);
      cp2 = Offset(end.dx - hDrift * (rng.nextDouble() * 0.25), end.dy - vSpan * pull);

    } else {
      // Top-right → Right (downward loop back to the right edge)
      start = Offset(size.width * (0.5 + rng.nextDouble() * 0.5), -_margin);
      end   = Offset(size.width + _margin, size.height * (0.4 + rng.nextDouble() * 0.5));

      final hSpan = (end.dx - start.dx).abs();
      final vSpan = (end.dy - start.dy).abs();
      final v = 0.50 + rng.nextDouble() * 0.25;
      cp1 = Offset(start.dx + hSpan * (rng.nextDouble() * 0.10), start.dy + vSpan * v);
      cp2 = Offset(end.dx - hSpan * v, end.dy - vSpan * (rng.nextDouble() * 0.10));
    }

    return Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}
