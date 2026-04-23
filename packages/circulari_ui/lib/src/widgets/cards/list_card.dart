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
  final String picturePath;
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
    required this.picturePath,
    this.isValueHidden = false,
    this.onToggleVisibility,
    this.onTap,
    this.seed,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
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
              Positioned(
                child: Image.asset(
                  picturePath,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withAlpha(255)],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _WavePainter(
                    color: backgroundColor.withAlpha(128),
                    seed: effectiveSeed,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: typography.body.large.medium.copyWith(
                        color: CirculariColorsTokens.greyscale100,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$itemCount items',
                      style: typography.body.small.light.copyWith(
                        color: CirculariColorsTokens.greyscale100,
                      ),
                    ),
                    SizedBox(height: context.circulariTheme.spacing.medium),
                    Text(
                      'Valor total',
                      style: typography.body.small.light.copyWith(
                        color: CirculariColorsTokens.greyscale100,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isValueHidden
                                ? '••••••'
                                : 'R\$ ${_formatCurrency(value)}',
                            style: typography.body.xLarge.semibold.copyWith(
                              color: CirculariColorsTokens.greyscale100,
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
                            color: CirculariColorsTokens.greyscale100,
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

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.translate(-40, 125);
    canvas.rotate(-0.35);

    canvas.drawPath(_curve(size, rng), paint);
  }

  Path _curve(Size size, Random rng) {
    return Path()
      ..moveTo(0, size.height * 0.5)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.2,
        size.width * 0.3,
        size.height * 0.7,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.1,
        size.width * 0.9,
        size.height * 0.9,
        size.width * 0.5,
        size.height * 0.6,
      )
      ..cubicTo(
        size.width * 0.4,
        size.height * 0.3,
        size.width * 0.9,
        size.height * 0.2,
        size.width * 0.85,
        size.height * 0.5,
      )
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.8,
        size.width,
        size.height * 0.3,
        size.width * 2,
        size.height * 0.5,
      );
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}
