import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Shared correction-hint input used by the "Outro…" sheet and the revalue
/// sheet. The field config — label, placeholder, and the 200-char backend
/// cap — lives here so the two entry points can't drift apart.
class AiHintInput extends StatelessWidget {
  final TextEditingController controller;
  final String subtitle;
  final String buttonLabel;
  final String? error;

  /// Invoked only when the trimmed text is non-empty.
  final VoidCallback onSubmit;

  const AiHintInput({
    super.key,
    required this.controller,
    required this.subtitle,
    required this.buttonLabel,
    required this.onSubmit,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          subtitle,
          style: theme.typography.body.medium.regular.copyWith(
            color: CirculariColorsTokens.greyscale400,
          ),
        ),
        SizedBox(height: theme.spacing.medium),
        CirculariTextFormField(
          controller: controller,
          label: 'Correção',
          hintText: 'ex: é um iPhone 15 de 256GB',
          onDark: true,
          lines: 2,
          // Backend caps the hint at 200 chars.
          inputFormatters: [LengthLimitingTextInputFormatter(200)],
        ),
        if (error != null) ...[
          SizedBox(height: theme.spacing.small),
          Text(
            error!,
            style: theme.typography.body.small.regular.copyWith(
              color: CirculariColorsTokens.solarPulse300,
            ),
          ),
        ],
        SizedBox(height: theme.spacing.medium),
        // The controller already owns the text state — no mirrored _hasText
        // field; only the button rebuilds per keystroke.
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, _) => CirculariButton(
            onPressed: value.text.trim().isEmpty ? null : onSubmit,
            label: buttonLabel,
          ),
        ),
      ],
    );
  }
}

/// Single owner of the AI-quota paywall invocation (resource label + route),
/// previously copy-pasted per call site.
void showAiQuotaPaywall(BuildContext context) {
  PaywallBottomSheet.show(
    context,
    resourceName: 'análises de IA',
    onUpgrade: () => context.push('/paywall'),
  );
}
