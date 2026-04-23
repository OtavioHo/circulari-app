import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CirculariAuthScaffold extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const CirculariAuthScaffold({
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
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent, Colors.black],
              stops: const [0, 0.5, 1],
            ).createShader(bounds),
            blendMode: BlendMode.darken,
            child: SvgPicture.asset(
              'assets/images/background/background.svg',
              package: 'circulari_ui',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black, Colors.transparent],
                    stops: const [0, 1],
                  ).createShader(bounds),
                  blendMode: BlendMode.darken,
                  child: Container(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: CirculariColorsTokens.greyscale800,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: child,
              )
            ],
          ),
        ],
      ),
    );
  }
}
