import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

class CirculariEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String ctaLabel;
  final VoidCallback onCtaPressed;

  const CirculariEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.ctaLabel,
    required this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final spacing = context.circulariTheme.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.medium,
        vertical: spacing.large,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: CirculariColorsTokens.greyscale200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: CirculariColorsTokens.freshCore,
            ),
          ),
          SizedBox(height: spacing.medium),
          Text(
            title,
            textAlign: TextAlign.center,
            style: typography.body.large.semibold.copyWith(
              color: CirculariColorsTokens.greyscale800,
            ),
          ),
          SizedBox(height: spacing.small),
          Text(
            description,
            textAlign: TextAlign.center,
            style: typography.body.medium.regular.copyWith(
              color: CirculariColorsTokens.greyscale600,
            ),
          ),
          SizedBox(height: spacing.large),
          CirculariButton(
            label: ctaLabel,
            onPressed: onCtaPressed,
          ),
        ],
      ),
    );
  }
}
