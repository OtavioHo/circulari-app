import 'package:flutter/material.dart';

import 'package:circulari_ui/src/widgets/buttons/button.dart';
import 'package:circulari_ui/src/widgets/feedback/bottom_sheet_shell.dart';

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
    return CirculariBottomSheetShell(
      title: 'Limite do plano atingido',
      message: 'Conheça outros planos que combinam mais com você.',
      children: [
        const SizedBox(height: 24),
        CirculariButton(
          label: 'Ver planos',
          onPressed: () {
            Navigator.of(context).pop();
            onUpgrade?.call();
          },
        ),
      ],
    );
  }
}
