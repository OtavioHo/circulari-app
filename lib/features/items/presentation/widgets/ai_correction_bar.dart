import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';

/// "Não é isso?" — correction affordance under the AI result: one chip per
/// alternative identification plus "Outro…" for free text. Tapping either
/// re-runs the analysis with the correction as a hint.
class AiCorrectionBar extends StatelessWidget {
  final AiAnalysisResult analysis;

  /// Disables the chips while a refine is in flight.
  final bool isRefining;

  /// Called with the correction text (a chip's name or the sheet's free text).
  final ValueChanged<String> onCorrect;

  const AiCorrectionBar({
    super.key,
    required this.analysis,
    required this.isRefining,
    required this.onCorrect,
  });

  Future<void> _openHintSheet(BuildContext context) async {
    final hint = await showCorrectionHintSheet(context);
    if (hint != null && hint.trim().isNotEmpty) onCorrect(hint.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Não é isso?',
          style: theme.typography.body.medium.semibold.copyWith(
            color: CirculariColorsTokens.greyscale600,
          ),
        ),
        SizedBox(height: theme.spacing.small),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final alternative in analysis.alternatives)
              _CorrectionChip(
                // The chip text doubles as the hint: "é um(a) X" reads
                // naturally in the prompt and stays unambiguous.
                label: alternative,
                enabled: !isRefining,
                onTap: () => onCorrect(alternative),
              ),
            _CorrectionChip(
              label: 'Outro…',
              enabled: !isRefining,
              onTap: () => _openHintSheet(context),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.small),
        Text(
          analysis.freeRetryAvailable
              ? '1 correção gratuita disponível'
              : 'A próxima correção usa 1 análise do seu plano',
          style: theme.typography.body.small.regular.copyWith(
            color: CirculariColorsTokens.greyscale500,
          ),
        ),
      ],
    );
  }
}

class _CorrectionChip extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _CorrectionChip({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    return Material(
      color: enabled
          ? CirculariColorsTokens.greyscale100
          : CirculariColorsTokens.greyscale50,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CirculariColorsTokens.greyscale300),
          ),
          child: Text(
            label,
            style: theme.typography.body.medium.medium.copyWith(
              color: enabled
                  ? CirculariColorsTokens.greyscale700
                  : CirculariColorsTokens.greyscale400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Free-text correction entry ("Outro…"). Returns the hint or null when
/// dismissed. Max 200 chars — the backend cap.
Future<String?> showCorrectionHintSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: CirculariColorsTokens.greyscale800,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _CorrectionHintSheet(),
  );
}

class _CorrectionHintSheet extends StatefulWidget {
  const _CorrectionHintSheet();

  @override
  State<_CorrectionHintSheet> createState() => _CorrectionHintSheetState();
}

class _CorrectionHintSheetState extends State<_CorrectionHintSheet> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final hint = _controller.text.trim();
    if (hint.isEmpty) return;
    Navigator.of(context).pop(hint);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Corrigir identificação',
            style: theme.typography.body.xLarge.semibold.copyWith(
              color: CirculariColorsTokens.greyscale50,
            ),
          ),
          SizedBox(height: theme.spacing.small),
          Text(
            'Diga o que está errado e a IA reanalisa o valor.',
            style: theme.typography.body.medium.regular.copyWith(
              color: CirculariColorsTokens.greyscale400,
            ),
          ),
          SizedBox(height: theme.spacing.medium),
          CirculariTextFormField(
            controller: _controller,
            label: 'Correção',
            hintText: 'ex: é um iPhone 15 de 256GB',
            onDark: true,
            lines: 2,
            // Backend caps the hint at 200 chars.
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
          ),
          SizedBox(height: theme.spacing.medium),
          CirculariButton(
            onPressed: _hasText ? _submit : null,
            label: 'Corrigir análise',
          ),
        ],
      ),
    );
  }
}
