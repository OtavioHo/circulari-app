import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:circulari_ui/src/extensions/build_context_extension.dart';
import 'package:circulari_ui/src/theme/circulari_colors.dart';

/// Shared shell for the dark modal bottom sheets (Figma `bt_sheet` component):
/// greyscale800 panel with a radius-32 top, a close X, a headline and an
/// explanation, followed by the caller's [children].
///
/// Show it with `showModalBottomSheet(isScrollControlled: true,
/// backgroundColor: Colors.transparent, ...)`.
class CirculariBottomSheetShell extends StatelessWidget {
  final String title;
  final String message;

  /// Called by the close X. Defaults to a plain pop.
  final VoidCallback? onClose;

  /// Content below the message (buttons, extra copy, ...).
  final List<Widget> children;

  const CirculariBottomSheetShell({
    super.key,
    required this.title,
    required this.message,
    this.onClose,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    final media = MediaQuery.of(context);
    // viewPadding keeps the buttons clear of the home indicator; viewInsets
    // covers the software keyboard, which showModalBottomSheet does not avoid
    // on its own and which may still be up when the sheet opens from a form.
    final bottomInset =
        math.max(media.viewPadding.bottom, media.viewInsets.bottom);

    return Container(
      decoration: const BoxDecoration(
        color: CirculariColorsTokens.greyscale800,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 40 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close,
                size: 24,
                color: CirculariColorsTokens.greyscale50,
              ),
            ),
          ),
          Text(
            title,
            style: theme.typography.heading2.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: CirculariColorsTokens.greyscale50,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.typography.body.large.regular.copyWith(
              height: 1.5,
              letterSpacing: 0.3,
              color: CirculariColorsTokens.greyscale500,
            ),
            textAlign: TextAlign.center,
          ),
          ...children,
        ],
      ),
    );
  }
}
