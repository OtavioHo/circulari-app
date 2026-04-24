import 'package:flutter/material.dart';
import '../../extensions/build_context_extension.dart';
import '../../theme/circulari_colors.dart';

class CirculariListCard extends StatefulWidget {
  final String title;
  final int itemCount;
  final double value;
  final Color backgroundColor;
  final String picturePath;
  final VoidCallback? onTap;
  final int? seed;

  static const double width = 270.0;
  static const double height = 318.0;

  const CirculariListCard({
    super.key,
    required this.title,
    required this.itemCount,
    required this.value,
    required this.backgroundColor,
    required this.picturePath,
    this.onTap,
    this.seed,
  });

  @override
  State<CirculariListCard> createState() => _CirculariListCardState();
}

class _CirculariListCardState extends State<CirculariListCard> {
  bool isValueHidden = false;
  bool _eyeIconTapped = false;

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final effectiveSeed = widget.seed ?? widget.title.hashCode;

    return GestureDetector(
      onTap: () {
        if (_eyeIconTapped) {
          _eyeIconTapped = false;
          return;
        }
        widget.onTap?.call();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: CirculariListCard.width,
          height: CirculariListCard.height,
          child: Stack(
            children: [
              Positioned(
                child: Image.asset(
                  widget.picturePath,
                  width: CirculariListCard.width,
                  height: CirculariListCard.height,
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
                    color: widget.backgroundColor.withAlpha(128),
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
                      'Valor total',
                      style: typography.body.small.medium.copyWith(
                        color: CirculariColorsTokens.greyscale100,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          isValueHidden
                              ? 'R\$ ••••••'
                              : 'R\$ ${_formatCurrency(widget.value)}',
                          style: typography.body.xLarge.semibold.copyWith(
                            color: CirculariColorsTokens.greyscale100,
                            fontSize: 26,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) {
                            _eyeIconTapped = true;
                          },
                          onTapCancel: () {
                            _eyeIconTapped = false;
                          },
                          onTap: () => setState(() {
                            isValueHidden = !isValueHidden;
                          }),
                          child: Icon(
                            isValueHidden
                                ? Icons.visibility_off
                                : Icons.remove_red_eye,
                            size: 18,
                            color: CirculariColorsTokens.greyscale100,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.circulariTheme.spacing.medium),
                    Text(
                      widget.title,
                      style: typography.body.large.medium.copyWith(
                        color: CirculariColorsTokens.greyscale100,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.itemCount} items',
                      style: typography.body.small.medium.copyWith(
                        color: CirculariColorsTokens.greyscale100.withAlpha(
                          120,
                        ),
                      ),
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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (seed % 3) {
      case 0:
        _drawCurve1(canvas, paint);
        break;
      case 1:
        _drawCurve2(canvas, paint);
        break;
      case 2:
        _drawCurve3(canvas, paint);
        break;
    }
  }

  void _drawCurve1(Canvas canvas, Paint paint) {
    const Size size = Size(350, 215);

    canvas.rotate(-0.2);
    canvas.translate(-40, 200);
    canvas.drawPath(_curve1(size), paint);
  }

  void _drawCurve2(Canvas canvas, Paint paint) {
    const Size size = Size(461, 335);

    canvas.rotate(-0.1);
    canvas.translate(-20, 170);
    canvas.drawPath(_curve2(size), paint);
  }

  void _drawCurve3(Canvas canvas, Paint paint) {
    const Size size = Size(443, 395);

    canvas.rotate(-0.2);
    canvas.translate(-100, 200);
    canvas.drawPath(_curve3(size), paint);
  }

  Path _curve1(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.5);
    path.cubicTo(
      size.width * 0.15,
      size.height * 0.34,
      size.width / 4,
      size.height * 0.41,
      size.width * 0.3,
      size.height * 0.55,
    );
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.66,
      size.width * 0.45,
      size.height * 0.69,
      size.width * 0.53,
      size.height * 0.61,
    );
    path.cubicTo(
      size.width * 0.53,
      size.height * 0.61,
      size.width * 0.73,
      size.height * 0.37,
      size.width * 0.73,
      size.height * 0.37,
    );
    path.cubicTo(
      size.width * 0.78,
      size.height * 0.31,
      size.width * 0.78,
      size.height * 0.18,
      size.width * 0.73,
      size.height * 0.11,
    );
    path.cubicTo(
      size.width * 0.68,
      size.height * 0.05,
      size.width * 0.6,
      size.height * 0.06,
      size.width * 0.55,
      size.height * 0.14,
    );
    path.cubicTo(
      size.width * 0.55,
      size.height * 0.14,
      size.width * 0.54,
      size.height * 0.17,
      size.width * 0.54,
      size.height * 0.17,
    );
    path.cubicTo(
      size.width * 0.48,
      size.height * 0.27,
      size.width * 0.51,
      size.height * 0.41,
      size.width * 0.58,
      size.height * 0.47,
    );
    path.cubicTo(
      size.width * 0.58,
      size.height * 0.47,
      size.width * 0.63,
      size.height * 0.51,
      size.width * 0.63,
      size.height * 0.51,
    );
    path.cubicTo(
      size.width * 0.71,
      size.height * 0.57,
      size.width * 0.75,
      size.height * 0.7,
      size.width * 0.72,
      size.height * 0.82,
    );
    path.cubicTo(
      size.width * 0.72,
      size.height * 0.82,
      size.width * 0.68,
      size.height * 1.07,
      size.width * 0.68,
      size.height * 1.07,
    );
    return path;
  }

  Path _curve2(Size size) {
    Path path = Path();
    path.lineTo(-0.08, size.height * 0.02);
    path.cubicTo(
      -0.08,
      size.height * 0.02,
      size.width * 0.11,
      size.height * 0.45,
      size.width * 0.11,
      size.height * 0.45,
    );
    path.cubicTo(
      size.width * 0.14,
      size.height * 0.53,
      size.width * 0.26,
      size.height * 0.51,
      size.width * 0.26,
      size.height * 0.42,
    );
    path.cubicTo(
      size.width * 0.26,
      size.height * 0.35,
      size.width * 0.34,
      size.height * 0.31,
      size.width * 0.4,
      size.height * 0.34,
    );
    path.cubicTo(
      size.width * 0.4,
      size.height * 0.34,
      size.width * 0.7,
      size.height * 0.51,
      size.width * 0.7,
      size.height * 0.51,
    );
    path.cubicTo(
      size.width * 0.82,
      size.height * 0.58,
      size.width * 0.95,
      size.height * 0.47,
      size.width * 0.91,
      size.height * 0.34,
    );
    path.cubicTo(
      size.width * 0.91,
      size.height * 0.34,
      size.width * 0.86,
      size.height * 0.17,
      size.width * 0.86,
      size.height * 0.17,
    );
    path.cubicTo(
      size.width * 0.83,
      size.height * 0.1,
      size.width * 0.75,
      size.height * 0.07,
      size.width * 0.68,
      size.height * 0.1,
    );
    path.cubicTo(
      size.width * 0.68,
      size.height * 0.1,
      size.width * 0.68,
      size.height * 0.1,
      size.width * 0.68,
      size.height * 0.1,
    );
    path.cubicTo(
      size.width * 0.65,
      size.height * 0.11,
      size.width * 0.63,
      size.height * 0.11,
      size.width * 0.6,
      size.height * 0.1,
    );
    path.cubicTo(
      size.width * 0.51,
      size.height * 0.08,
      size.width * 0.43,
      size.height * 0.18,
      size.width * 0.47,
      size.height * 0.27,
    );
    path.cubicTo(
      size.width * 0.47,
      size.height * 0.27,
      size.width * 0.64,
      size.height * 0.61,
      size.width * 0.64,
      size.height * 0.61,
    );
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.72,
      size.width * 0.67,
      size.height * 0.85,
      size.width * 0.58,
      size.height * 0.92,
    );
    path.cubicTo(
      size.width * 0.58,
      size.height * 0.92,
      size.width * 0.47,
      size.height * 1.02,
      size.width * 0.47,
      size.height * 1.02,
    );
    return path;
  }

  Path _curve3(Size size) {
    Path path = Path();
    path.lineTo(0, size.height );
    path.cubicTo(
      size.width * 0.96,
      size.height * 0.43,
      size.width * 0.42,
      size.height * 0.24,
      size.width * 0.42,
      size.height * 0.24,
    );
    path.cubicTo(
      size.width * 0.32,
      size.height / 5,
      size.width / 5,
      size.height * 0.23,
      size.width * 0.13,
      size.height * 0.32,
    );
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.41,
      size.width * 0.02,
      size.height * 0.54,
      size.width * 0.05,
      size.height * 0.66,
    );
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.66,
      size.width * 0.08,
      size.height * 0.82,
      size.width * 0.08,
      size.height * 0.82,
    );
    path.cubicTo(
      size.width * 0.11,
      size.height * 0.96,
      size.width * 0.23,
      size.height * 1.06,
      size.width * 0.36,
      size.height * 1.05,
    );
    path.cubicTo(
      size.width * 0.36,
      size.height * 1.05,
      size.width * 0.71,
      size.height * 1.02,
      size.width * 0.71,
      size.height * 1.02,
    );
    path.cubicTo(
      size.width * 0.78,
      size.height,
      size.width * 0.84,
      size.height * 0.93,
      size.width * 0.82,
      size.height * 0.85,
    );
    path.cubicTo(
      size.width * 0.82,
      size.height * 0.81,
      size.width * 0.82,
      size.height * 0.78,
      size.width * 0.84,
      size.height * 0.75,
    );
    path.cubicTo(
      size.width * 0.84,
      size.height * 0.75,
      size.width * 0.92,
      size.height * 0.59,
      size.width * 0.92,
      size.height * 0.59,
    );
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.53,
      size.width * 0.96,
      size.height * 0.47,
      size.width * 0.95,
      size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.4,
      size.width * 0.93,
      size.height * 0.29,
      size.width * 0.93,
      size.height * 0.29,
    );
    path.cubicTo(
      size.width * 0.89,
      size.height * 0.03,
      size.width * 0.59,
      -0.04,
      size.width * 0.46,
      size.height * 0.17,
    );
    path.cubicTo(
      size.width * 0.46,
      size.height * 0.17,
      size.width * 0.32,
      size.height * 0.39,
      size.width * 0.32,
      size.height * 0.39,
    );
    path.cubicTo(
      size.width * 0.23,
      size.height * 0.54,
      size.width * 0.03,
      size.height * 0.52,
      -0.04,
      size.height * 0.36,
    );
    return path;
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}
