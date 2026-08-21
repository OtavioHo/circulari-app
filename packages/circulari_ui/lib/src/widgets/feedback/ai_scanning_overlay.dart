import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:circulari_ui/src/extensions/build_context_extension.dart';
import 'package:circulari_ui/src/theme/circulari_colors.dart';

const _lime = CirculariColorsTokens.pulseLime;
const _darkGreen = CirculariColorsTokens.forestVault900;

/// Full-screen dimming overlay shown while the AI reads an item photo,
/// per the Figma "Pulse Illustration" loading frame: concentric
/// discs and blurred lime glows around a sparkle core, with floating
/// particles and expanding pulse ripples.
///
/// Host pages layer it over their scaffold (e.g. inside a [Stack]) while the
/// analysis state is loading.
class AiScanningOverlay extends StatefulWidget {
  final String title;
  final String subtitle;

  const AiScanningOverlay({
    super.key,
    this.title = 'Estamos circulando\na internet',
    this.subtitle = 'Pesquisando os valores de\nprodutos similares....',
  });

  @override
  State<AiScanningOverlay> createState() => _AiScanningOverlayState();
}

class _AiScanningOverlayState extends State<AiScanningOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;

    return ColoredBox(
      // The Figma frame fill is forestVault900 at 60%, but that assumes a dark
      // page behind it; over the white form it washes out, so the scrim is
      // heavier to keep the mock's near-dark look.
      color: _darkGreen.withValues(alpha: 0.92),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              // The boundary keeps the per-frame pulse repaint off the
              // route-level layer (scrim + text repaint once, not at 60fps);
              // the painter repaints itself via `repaint: controller`.
              child: RepaintBoundary(
                child: CustomPaint(painter: _PulsePainter(_controller)),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: theme.typography.body.xLarge.bold.copyWith(
                fontSize: 28,
                height: 1.3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: theme.typography.body.large.medium.copyWith(
                height: 1.6,
                color: CirculariColorsTokens.vitalGlow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Paints the 200x200 pulse illustration, driven directly by the repeating
/// 0..1 [animation] phase (no per-frame widget rebuild).
class _PulsePainter extends CustomPainter {
  final Animation<double> animation;

  _PulsePainter(this.animation) : super(repaint: animation);

  // Fixed particle spots from the Figma layer positions (x, y, diameter).
  static const _particles = [
    (180.0, 30.0, 6.0),
    (28.0, 62.0, 5.0),
    (162.0, 142.0, 5.0),
    (56.0, 156.0, 4.0),
    (100.0, 16.0, 4.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final center = size.center(Offset.zero);
    // Slow breathing multiplier shared by the glow and the core.
    final breath = 0.5 + 0.5 * math.sin(t * 2 * math.pi);

    // Soft lime glows (Figma waves/rings collapsed into two washes). A radial
    // gradient fading over the blur distance approximates the Figma layer
    // blur without a per-frame Gaussian pass.
    _glow(canvas, center, 170, 0.028 + 0.017 * breath, 60);
    _glow(canvas, center, 115, 0.045 + 0.020 * breath, 35);

    // Stepped translucent discs.
    _disc(canvas, center, 100, 0.04);
    _disc(canvas, center, 80.8, 0.08);
    _disc(canvas, center, 59.2, 0.15);

    // Two staggered expanding ripples fading out over the discs.
    for (final phase in [t, (t + 0.5) % 1.0]) {
      final radius = 38.5 + phase * 70;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = _lime.withValues(alpha: 0.22 * (1 - phase)),
      );
    }

    // Core with the sparkle glyph, gently scaling.
    final coreRadius = 38.5 * (1 + 0.05 * breath);
    canvas.drawCircle(center, coreRadius, Paint()..color = _lime);
    _sparkle(canvas, center);

    // Floating, twinkling particles.
    for (final (i, (x, y, d)) in _particles.indexed) {
      final phase = t * 2 * math.pi + i * 1.7;
      final offset = Offset(x + 3 * math.sin(phase), y + 4 * math.cos(phase));
      final paint = Paint()
        ..color = _lime.withValues(alpha: 0.35 + 0.25 * math.sin(phase * 1.3))
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
      canvas.drawCircle(offset, d / 2, paint);
    }
  }

  void _glow(
    Canvas canvas,
    Offset center,
    double radius,
    double alpha,
    double blur,
  ) {
    final outer = radius + blur;
    canvas.drawCircle(
      center,
      outer,
      Paint()
        ..shader = RadialGradient(
          stops: [0, radius / outer, 1],
          colors: [
            _lime.withValues(alpha: alpha),
            _lime.withValues(alpha: alpha),
            _lime.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: outer)),
    );
  }

  void _disc(Canvas canvas, Offset center, double radius, double alpha) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.white.withValues(alpha: alpha),
    );
  }

  /// Four-point star (plus a small companion) approximating the Figma icon.
  void _sparkle(Canvas canvas, Offset center) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round
      ..color = _darkGreen;
    canvas.drawPath(_star(center.translate(-2, 2), 14), paint);
    canvas.drawPath(
      _star(center.translate(13, -11), 5),
      Paint()
        ..style = PaintingStyle.fill
        ..color = _darkGreen,
    );
  }

  Path _star(Offset c, double r) {
    final waist = r * 0.28;
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx + waist * 0.4, c.dy - waist, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx + waist * 0.4, c.dy + waist, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx - waist * 0.4, c.dy + waist, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx - waist * 0.4, c.dy - waist, c.dx, c.dy - r)
      ..close();
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) =>
      oldDelegate.animation != animation;
}
