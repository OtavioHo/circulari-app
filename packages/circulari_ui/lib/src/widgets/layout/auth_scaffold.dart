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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final height =
              constraints.maxHeight + MediaQuery.viewInsetsOf(context).bottom;
          return SingleChildScrollView(
            child: SizedBox(
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: CirculariColorsTokens.deepMoss),
                  SvgPicture.asset(
                    'assets/images/background/auth_background.svg',
                    package: 'circulari_ui',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                          Colors.black,
                        ],
                        stops: [0, 0.5, 1],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const Expanded(
                        child: Center(child: FlutterLogo(size: 80)),
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
