import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CirculariDefaultBackgroundScaffold extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const CirculariDefaultBackgroundScaffold({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: CirculariColorsTokens.deepMoss),
          SvgPicture.asset(
            'assets/images/background/in_app_background.svg',
            package: 'circulari_ui',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.transparent, Colors.black],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
