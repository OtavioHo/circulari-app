import 'package:flutter/material.dart';

import 'package:circulari_ui/src/extensions/build_context_extension.dart';
import 'package:circulari_ui/src/theme/circulari_colors.dart';

class PaywallBottomSheet extends StatelessWidget {
  final String? resourceName;

  const PaywallBottomSheet._({this.resourceName});

  static Future<void> show(
    BuildContext context, {
    String? resourceName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallBottomSheet._(resourceName: resourceName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    final resource = resourceName ?? 'items';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: CirculariColorsTokens.greyscale300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: CirculariColorsTokens.solarPulse100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 32,
              color: CirculariColorsTokens.solarPulse500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Limite do plano gratuito atingido',
            style: theme.typography.heading3.copyWith(
              color: CirculariColorsTokens.greyscale900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Você chegou ao limite de $resource do seu plano gratuito. Faça upgrade para o Premium e use sem limites.',
            style: theme.typography.body.medium.regular.copyWith(
              color: CirculariColorsTokens.greyscale500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: CirculariColorsTokens.freshCore,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: navigate to upgrade/paywall screen when implemented
              },
              child: Text(
                'Fazer upgrade para Premium',
                style: theme.typography.body.medium.semibold.copyWith(
                  color: CirculariColorsTokens.greyscale900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Agora não',
              style: theme.typography.body.medium.regular.copyWith(
                color: CirculariColorsTokens.greyscale500,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
