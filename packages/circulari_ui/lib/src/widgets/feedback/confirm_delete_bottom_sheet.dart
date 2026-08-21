import 'package:flutter/material.dart';

import 'package:circulari_ui/src/extensions/build_context_extension.dart';
import 'package:circulari_ui/src/theme/circulari_colors.dart';
import 'package:circulari_ui/src/widgets/buttons/button.dart';

/// Dark destructive-action confirmation sheet (Figma `bt_sheet` component):
/// greyscale800 panel, close X, headline, explanation, and a green
/// keep/cancel button above a red confirm button.
///
/// [show] resolves to `true` when the destructive action is confirmed,
/// `false`/`null` otherwise (cancel button, X, or barrier dismiss).
class ConfirmDeleteBottomSheet extends StatelessWidget {
  final String title;
  final String message;
  final String question;
  final String cancelLabel;
  final String confirmLabel;

  const ConfirmDeleteBottomSheet._({
    required this.title,
    required this.message,
    required this.question,
    required this.cancelLabel,
    required this.confirmLabel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String question = 'Deseja continuar mesmo assim?',
    required String cancelLabel,
    required String confirmLabel,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmDeleteBottomSheet._(
        title: title,
        message: message,
        question: question,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

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
              onPressed: () => Navigator.of(context).pop(false),
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
          const SizedBox(height: 24),
          Text(
            question,
            style: theme.typography.body.large.regular.copyWith(
              height: 1.5,
              letterSpacing: 0.3,
              color: CirculariColorsTokens.greyscale500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CirculariButton(
            label: cancelLabel,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          const SizedBox(height: 12),
          CirculariDangerButton(
            label: confirmLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
