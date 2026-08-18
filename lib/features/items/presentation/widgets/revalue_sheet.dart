import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:circulari/core/di/injection.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/presentation/bloc/revalue_cubit.dart';
import 'package:circulari/features/items/presentation/widgets/ai_hint_input.dart';
import 'package:circulari/features/items/presentation/widgets/price_insight.dart';

final _brl = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

/// "Valor parece errado?" — saved-item revaluation flow: the user describes the
/// correction, the AI re-analyzes from the item's STORED image (no upload) and
/// the new valuation is shown as a preview. Returns the accepted result on
/// Aplicar, or null when dismissed/discarded (the analysis stays counted).
Future<AiAnalysisResult?> showRevalueSheet(BuildContext context, {required Item item}) {
  return showModalBottomSheet<AiAnalysisResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Dismissal is guarded while an analysis is in flight — a dropped sheet
    // would discard a paid analysis (and close the cubit under the request).
    isDismissible: false,
    enableDrag: false,
    backgroundColor: CirculariColorsTokens.greyscale800,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => BlocProvider(
      create: (_) => sl<RevalueCubit>(),
      child: _RevalueSheet(item: item),
    ),
  );
}

class _RevalueSheet extends StatefulWidget {
  final Item item;
  const _RevalueSheet({required this.item});

  @override
  State<_RevalueSheet> createState() => _RevalueSheetState();
}

class _RevalueSheetState extends State<_RevalueSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final hint = _controller.text.trim();
    if (hint.isEmpty) return;
    context.read<RevalueCubit>().revalue(
          itemId: widget.item.id,
          hint: hint,
          // Initial parent only — the cubit chains subsequent corrections to
          // the analysis it just produced.
          parentAnalysisId: widget.item.aiAnalysisId,
        );
  }

  void _onState(BuildContext context, RevalueState state) {
    if (state is RevalueQuotaExceeded) {
      showAiQuotaPaywall(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return BlocConsumer<RevalueCubit, RevalueState>(
      listener: _onState,
      builder: (context, state) {
        final isLoading = state is RevalueLoading;
        return PopScope(
          // Back button must not silently drop an in-flight (paid) analysis.
          canPop: !isLoading,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Reavaliar valor',
                          style: theme.typography.body.xLarge.semibold.copyWith(
                            color: CirculariColorsTokens.greyscale50,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                            isLoading ? null : () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: CirculariColorsTokens.greyscale50,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, bottom + 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: switch (state) {
                          RevalueInitial() ||
                          RevalueQuotaExceeded() =>
                            _buildInput(error: null),
                          RevalueFailure(:final message) =>
                            _buildInput(error: message),
                          RevalueLoading() => _buildLoading(theme),
                          RevaluePreview(:final result) =>
                            _buildPreview(theme, result),
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildInput({required String? error}) {
    return [
      AiHintInput(
        controller: _controller,
        subtitle:
            'Diga o que está errado e a IA reanalisa o valor a partir da foto do item.',
        buttonLabel: 'Reanalisar valor',
        error: error,
        onSubmit: _submit,
      ),
    ];
  }

  List<Widget> _buildLoading(CirculariTheme theme) {
    return [
      SizedBox(height: theme.spacing.medium),
      const Center(child: CircularProgressIndicator()),
      SizedBox(height: theme.spacing.medium),
      Text(
        'Reanalisando… isso pode levar até um minuto.',
        textAlign: TextAlign.center,
        style: theme.typography.body.medium.regular.copyWith(
          color: CirculariColorsTokens.greyscale400,
        ),
      ),
      SizedBox(height: theme.spacing.medium),
    ];
  }

  List<Widget> _buildPreview(CirculariTheme theme, AiAnalysisResult result) {
    return [
      Text(
        result.name,
        style: theme.typography.body.large.semibold.copyWith(
          color: CirculariColorsTokens.greyscale50,
        ),
      ),
      SizedBox(height: theme.spacing.small),
      Text(
        result.hasEstimate
            ? 'Novo valor sugerido: ${_brl.format(result.suggestedPrice)}'
            : 'Não foi possível estimar um valor — o valor atual será mantido; '
                'ajuste manualmente se necessário.',
        style: theme.typography.body.medium.regular.copyWith(
          color: CirculariColorsTokens.greyscale400,
        ),
      ),
      SizedBox(height: theme.spacing.small),
      PriceInsight(analysis: result),
      SizedBox(height: theme.spacing.small),
      Text(
        result.hasEstimate
            ? 'Aplicar substitui nome, descrição, categoria e valor do item. '
                'A análise já foi contabilizada.'
            : 'Aplicar substitui nome, descrição e categoria do item. '
                'A análise já foi contabilizada.',
        style: theme.typography.body.small.regular.copyWith(
          color: CirculariColorsTokens.greyscale500,
        ),
      ),
      SizedBox(height: theme.spacing.medium),
      CirculariButton(
        onPressed: () => Navigator.of(context).pop(result),
        label: 'Aplicar',
      ),
      SizedBox(height: theme.spacing.small),
      TextButton(
        onPressed: () => context.read<RevalueCubit>().reset(),
        child: const Text('Descartar'),
      ),
    ];
  }
}
