import 'package:circulari_ui/src/extensions/build_context_extension.dart';
import 'package:circulari_ui/src/theme/circulari_colors.dart';
import 'package:circulari_ui/src/widgets/buttons/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CirculariInAppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const CirculariInAppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.onBackPressed,
    this.showBackButton = true,
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
        automaticallyImplyLeading: false,
        leadingWidth: 68,
        leading: showBackButton
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CirculariBackButton(
                    color: CirculariColorsTokens.greyscale700,
                    onPressed:
                        onBackPressed ?? () => Navigator.of(context).pop(),
                  ),
                ),
              )
            : null,
        actions: actions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
