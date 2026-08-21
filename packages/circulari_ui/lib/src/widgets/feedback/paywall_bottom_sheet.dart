import 'package:flutter/material.dart';

import 'package:circulari_ui/src/extensions/build_context_extension.dart';
import 'package:circulari_ui/src/theme/circulari_colors.dart';
import 'package:circulari_ui/src/widgets/buttons/button.dart';

class PaywallBottomSheet extends StatelessWidget {
  /// Called when the user taps "Ver planos". The host app navigates to its
  /// paywall route; this package stays decoupled from routing.
  final VoidCallback? onUpgrade;

  const PaywallBottomSheet._({this.onUpgrade});

  static Future<void> show(BuildContext context, {VoidCallback? onUpgrade}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallBottomSheet._(onUpgrade: onUpgrade),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    // viewPadding (not padding) survives inside the modal sheet's MediaQuery
    // and keeps the button clear of the home indicator.
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
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close,
                size: 24,
                color: CirculariColorsTokens.greyscale50,
              ),
            ),
          ),
          Text(
            'Limite do plano atingido',
            style: theme.typography.heading2.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.2,
              color: CirculariColorsTokens.greyscale50,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Conheça outros planos que combinam mais com você.',
            style: theme.typography.body.large.regular.copyWith(
              height: 1.5,
              letterSpacing: 0.3,
              color: CirculariColorsTokens.greyscale500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CirculariButton(
            label: 'Ver planos',
            onPressed: () {
              Navigator.of(context).pop();
              onUpgrade?.call();
            },
          ),
        ],
      ),
    );
  }
}
