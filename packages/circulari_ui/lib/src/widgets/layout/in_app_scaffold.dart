import 'package:circulari_ui/src/extensions/build_context_extension.dart';
import 'package:circulari_ui/src/theme/circulari_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CirculariInAppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final VoidCallback? onBackPressed;

  const CirculariInAppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;

    return Scaffold(
      backgroundColor: CirculariColorsTokens.greyscale200,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: typography.heading6.copyWith(
            color: CirculariColorsTokens.greyscale700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: CirculariColorsTokens.greyscale700,
          ),
          onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        ),
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
