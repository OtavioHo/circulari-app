import 'dart:io';

import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/presentation/bloc/ai_analysis_cubit.dart';
import 'package:circulari/features/items/presentation/bloc/categories_cubit.dart';
import 'package:circulari/features/items/presentation/widgets/ai_correction_bar.dart';
import 'package:circulari/features/items/presentation/widgets/price_insight.dart';
import 'package:circulari/features/items/presentation/bloc/items_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/items_event.dart';
import 'package:circulari/features/items/presentation/bloc/items_state.dart';
import 'package:circulari/features/lists/domain/entities/item_list.dart';

final _brlFormat = NumberFormat('#,##0.00', 'pt_BR');

/// Parses a BRL-masked string (e.g. "1.234,56") into a double.
double? _parseBrl(String text) {
  final normalized = text.replaceAll('.', '').replaceAll(',', '.').trim();
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

/// Masks digit input as Brazilian currency (thousands with ".", decimals
/// with ","), treating the typed digits as cents.
class _BrlInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final value = int.parse(digits) / 100;
    final formatted = _brlFormat.format(value);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Verbatim copy of every AI-driven form value, taken right before a refine so
/// Desfazer can restore the exact pre-correction state.
class _FormSnapshot {
  final String name;
  final String description;
  final String value;
  final String? categoryId;
  final bool nameAi;
  final bool descAi;
  final bool valueAi;
  final bool categoryAi;
  final String? aiPriceDescription;

  const _FormSnapshot({
    required this.name,
    required this.description,
    required this.value,
    required this.categoryId,
    required this.nameAi,
    required this.descAi,
    required this.valueAi,
    required this.categoryAi,
    required this.aiPriceDescription,
  });
}

class AddItemFormPage extends StatefulWidget {
  final String imagePath;
  final String listId;
  final ItemList? list;

  const AddItemFormPage({
    super.key,
    required this.imagePath,
    required this.listId,
    this.list,
  });

  @override
  State<AddItemFormPage> createState() => _AddItemFormPageState();
}

class _AddItemFormPageState extends State<AddItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _valueCtrl;
  String? _selectedCategoryId;
  bool _nameAiGenerated = false;
  bool _descAiGenerated = false;
  bool _valueAiGenerated = false;
  bool _categoryAiGenerated = false;
  String? _aiPriceDescription;
  AiAnalysisResult? _analysis;

  // Snapshot lifecycle mirrors the cubit's undo target: _pendingSnapshot is
  // captured when a refine starts and only promoted to _undoSnapshot when that
  // refine SUCCEEDS — a failed second refine must not clobber the undo of the
  // first one.
  _FormSnapshot? _pendingSnapshot;
  _FormSnapshot? _undoSnapshot;
  double? _undoFromPrice;
  bool _conflictDismissed = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _qtyCtrl = TextEditingController(text: '1');
    _valueCtrl = TextEditingController();
    context.read<AiAnalysisCubit>().analyze(widget.imagePath);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _onAnalysisState(BuildContext context, AiAnalysisState state) {
    if (state is AiAnalysisRefining) {
      // Snapshot the exact pre-correction form; promoted to the undo slot only
      // if the refine succeeds.
      _pendingSnapshot = _FormSnapshot(
        name: _nameCtrl.text,
        description: _descCtrl.text,
        value: _valueCtrl.text,
        categoryId: _selectedCategoryId,
        nameAi: _nameAiGenerated,
        descAi: _descAiGenerated,
        valueAi: _valueAiGenerated,
        categoryAi: _categoryAiGenerated,
        aiPriceDescription: _aiPriceDescription,
      );
      setState(() => _conflictDismissed = false);
    } else if (state is AiAnalysisRefineSuccess) {
      _undoSnapshot = _pendingSnapshot;
      _pendingSnapshot = null;
      _undoFromPrice = state.previous.suggestedPrice;
      setState(() => _applyAnalysis(state.result, overwrite: true));
    } else if (state is AiAnalysisSuccess) {
      setState(() => _applyAnalysis(state.result, overwrite: false));
    } else if (state is AiAnalysisRestored) {
      // Undo (form already restored from the snapshot) or a blocked refine
      // (form never changed) — only the displayed analysis rolls back; the
      // form must not be re-filled.
      _pendingSnapshot = null;
      setState(() => _analysis = state.result);
    } else if (state is AiAnalysisQuotaExceeded) {
      PaywallBottomSheet.show(
        context,
        resourceName: 'análises de IA',
        onUpgrade: () => context.push('/paywall'),
      );
    } else if (state is AiAnalysisRefineFailure) {
      _pendingSnapshot = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is AiAnalysisFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível analisar a imagem: ${state.message}')),
      );
    }
  }

  /// Applies an analysis to the form. [overwrite] replaces AI-driven fields
  /// (a correction result); otherwise only still-empty fields are filled (the
  /// initial analysis). Must run inside setState.
  void _applyAnalysis(AiAnalysisResult result, {required bool overwrite}) {
    _analysis = result;
    if (overwrite || _nameCtrl.text.isEmpty) {
      _nameCtrl.text = result.name;
      _nameAiGenerated = true;
    }
    if (overwrite || _descCtrl.text.isEmpty) {
      _descCtrl.text = result.description;
      _descAiGenerated = true;
    }
    if (result.suggestedPrice > 0) {
      if (overwrite || _valueCtrl.text.isEmpty) {
        _valueCtrl.text = _brlFormat.format(result.suggestedPrice);
        _valueAiGenerated = true;
        _aiPriceDescription =
            'Faixa de mercado: R\$ ${_brlFormat.format(result.priceMin)} – '
            'R\$ ${_brlFormat.format(result.priceMax)}';
      }
    } else if (overwrite) {
      // The corrected identity couldn't be priced — clearing beats keeping the
      // previous identity's price labeled as AI-generated for this one.
      _valueCtrl.text = '';
      _valueAiGenerated = false;
      _aiPriceDescription = null;
    }
    // Null keeps the current (possibly manual) category — a correction result
    // without a category is no reason to uncategorize the item.
    if (result.categoryId != null) {
      _selectedCategoryId = result.categoryId;
      _categoryAiGenerated = true;
    }
  }

  void _refine(String hint) {
    // The hint sheet awaits a modal route; the page may have been removed
    // underneath it (session-expiry redirect) by the time this runs.
    if (!mounted) return;
    context.read<AiAnalysisCubit>().refine(hint);
  }

  void _undo() {
    final snapshot = _undoSnapshot;
    if (snapshot == null) return;
    _undoSnapshot = null;
    _undoFromPrice = null;
    setState(() {
      _nameCtrl.text = snapshot.name;
      _descCtrl.text = snapshot.description;
      _valueCtrl.text = snapshot.value;
      _selectedCategoryId = snapshot.categoryId;
      _nameAiGenerated = snapshot.nameAi;
      _descAiGenerated = snapshot.descAi;
      _valueAiGenerated = snapshot.valueAi;
      _categoryAiGenerated = snapshot.categoryAi;
      _aiPriceDescription = snapshot.aiPriceDescription;
    });
    context.read<AiAnalysisCubit>().undo();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Análise anterior restaurada. A reanálise já foi contabilizada.'),
      ),
    );
  }

  void _onItemsState(BuildContext context, ItemsState state) {
    if (state is ItemsCreateSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item criado com sucesso!')),
      );
      // Rebuild a proper back stack instead of replacing it: root at the
      // shell, then the list, then the new item. Using context.go here would
      // discard the shell and make the list page the stack root, leaving it
      // with no back button (and the OS back button would close the app).
      context.go('/home');
      context.push('/lists/${widget.listId}/items', extra: widget.list);
      context.push('/items/${state.created.id}', extra: state.created);
    } else if (state is ItemsQuotaExceeded) {
      PaywallBottomSheet.show(
        context,
        resourceName: 'itens',
        onUpgrade: () => context.push('/paywall'),
      );
    } else if (state is ItemsActionFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    final value = _parseBrl(_valueCtrl.text);
    final desc = _descCtrl.text.trim();

    context.read<ItemsBloc>().add(
      ItemsCreateRequested(
        listId: widget.listId,
        name: _nameCtrl.text.trim(),
        description: desc.isEmpty ? null : desc,
        quantity: qty,
        categoryId: _selectedCategoryId,
        userDefinedValue: value,
        imagePath: widget.imagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    return MultiBlocListener(
      listeners: [
        BlocListener<AiAnalysisCubit, AiAnalysisState>(
          listener: _onAnalysisState,
        ),
        BlocListener<ItemsBloc, ItemsState>(listener: _onItemsState),
      ],
      child: CirculariInAppScaffold(
        title: 'Criar item',
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<ItemsBloc, ItemsState>(
            buildWhen: (prev, curr) =>
                prev is ItemsCreateInProgress || curr is ItemsCreateInProgress,
            builder: (context, itemsState) => AbsorbPointer(
              absorbing: itemsState is ItemsCreateInProgress,
              child: Form(
                key: _formKey,
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Especificações do item',
                  style: theme.typography.heading3.copyWith(
                    color: CirculariColorsTokens.greyscale900,
                  ),
                ),
                Text(
                  'Para entendermos melhor, preencha as informações básicas do item.',
                  style: theme.typography.body.large.regular.copyWith(
                    color: CirculariColorsTokens.greyscale500,
                  ),
                ),
                SizedBox(height: theme.spacing.medium),
                Text(
                  'Foto do item',
                  style: theme.typography.body.large.semibold.copyWith(
                    color: CirculariColorsTokens.greyscale500,
                  ),
                ),
                SizedBox(height: theme.spacing.medium),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.imagePath),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: theme.spacing.medium),
                Text(
                  'Descrição do item',
                  style: theme.typography.body.large.semibold.copyWith(
                    color: CirculariColorsTokens.greyscale500,
                  ),
                ),
                BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                  builder: (context, state) {
                    if (state is AiAnalysisLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(),
                      );
                    }
                    if (state is AiAnalysisRefining) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LinearProgressIndicator(),
                            const SizedBox(height: 4),
                            Text(
                              'Reanalisando…',
                              style: theme.typography.body.small.regular
                                  .copyWith(
                                    color: CirculariColorsTokens.greyscale500,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox(height: 16);
                  },
                ),
                CirculariTextFormField(
                  controller: _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'O nome é obrigatório'
                      : null,
                  label: 'Nome *',
                  aiGenerated: _nameAiGenerated,
                  onChanged: (_) =>
                      setState(() => _nameAiGenerated = false),
                ),
                SizedBox(height: theme.spacing.large),
                CirculariTextFormField(
                  controller: _descCtrl,
                  label: 'Descreva o item',
                  aiGenerated: _descAiGenerated,
                  lines: 4,
                  onChanged: (_) =>
                      setState(() => _descAiGenerated = false),
                ),
                SizedBox(height: theme.spacing.large),
                CirculariTextFormField(
                  controller: _valueCtrl,
                  label: 'Preço',
                  prefixText: 'R\$ ',
                  description: _aiPriceDescription,
                  aiGenerated: _valueAiGenerated,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_BrlInputFormatter()],
                  onChanged: (_) =>
                      setState(() => _valueAiGenerated = false),
                ),
                if (_analysis != null) ...[
                  SizedBox(height: theme.spacing.small),
                  PriceInsight(analysis: _analysis!),
                ],
                BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                  builder: (context, aiState) {
                    // Exhaustive over the sealed hierarchy: adding a state is a
                    // compile error here, not a silently vanished bar.
                    final analysis = switch (aiState) {
                      AiAnalysisSuccess(:final result) => result,
                      AiAnalysisRefineSuccess(:final result) => result,
                      AiAnalysisRestored(:final result) => result,
                      AiAnalysisRefining(:final previous) => previous,
                      AiAnalysisRefineFailure(:final previous) => previous,
                      AiAnalysisInitial() => null,
                      AiAnalysisLoading() => null,
                      AiAnalysisFailure() => null,
                      AiAnalysisQuotaExceeded() => null,
                    };
                    if (analysis == null) return const SizedBox.shrink();
                    final isRefining = aiState is AiAnalysisRefining;
                    // Undo of the last successful refine stays reachable even
                    // after a later refine fails (RefineFailure keeps showing
                    // the banner).
                    final canUndo = _undoSnapshot != null && !isRefining;
                    final showConflict = canUndo &&
                        analysis.conflictsWithImage &&
                        !_conflictDismissed;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showConflict)
                          _ConflictBanner(
                            note:
                                analysis.conflictNote ??
                                'A foto parece diferente da sua correção.',
                            onKeep: () =>
                                setState(() => _conflictDismissed = true),
                            onUndo: _undo,
                          )
                        else if (canUndo)
                          _DeltaBanner(
                            from: _undoFromPrice ?? analysis.suggestedPrice,
                            to: analysis.suggestedPrice,
                            onUndo: _undo,
                          ),
                        SizedBox(height: theme.spacing.medium),
                        AiCorrectionBar(
                          analysis: analysis,
                          isRefining: isRefining,
                          onCorrect: _refine,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: theme.spacing.large),
                BlocBuilder<CategoriesCubit, CategoriesState>(
                  builder: (context, state) => switch (state) {
                    CategoriesLoading() => const SizedBox(
                      height: 56,
                      child: Center(child: LinearProgressIndicator()),
                    ),
                    CategoriesSuccess(:final categories) =>
                      CirculariDropdownFormField<String?>(
                        label: 'Categoria',
                        aiGenerated: _categoryAiGenerated,
                        value:
                            categories.any((c) => c.id == _selectedCategoryId)
                            ? _selectedCategoryId
                            : null,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Sem categoria'),
                          ),
                          ...categories.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (id) => setState(() {
                          _selectedCategoryId = id;
                          _categoryAiGenerated = false;
                        }),
                      ),
                    CategoriesFailure() => const SizedBox.shrink(),
                    CategoriesInitial() => const SizedBox.shrink(),
                  },
                ),
                SizedBox(height: theme.spacing.large),
                BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                  builder: (context, aiState) =>
                      BlocBuilder<ItemsBloc, ItemsState>(
                        builder: (context, itemsState) => CirculariButton(
                          onPressed:
                              aiState is AiAnalysisLoading ||
                                  aiState is AiAnalysisRefining ||
                                  itemsState is ItemsCreateInProgress
                              ? null
                              : _submit,
                          label: 'Criar Item',
                          isLoading:
                              aiState is AiAnalysisLoading ||
                              aiState is AiAnalysisRefining ||
                              itemsState is ItemsCreateInProgress,
                        ),
                      ),
                ),
                SizedBox(height: theme.spacing.medium),
              ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Post-correction summary: old → new suggested price, with Desfazer. The
/// executed analysis stays counted regardless (copy on the undo snackbar).
class _DeltaBanner extends StatelessWidget {
  final double from;
  final double to;
  final VoidCallback onUndo;

  const _DeltaBanner({
    required this.from,
    required this.to,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    // to == 0 means the corrected identity couldn't be priced (the form's
    // value field was cleared) — a "→ R$ 0,00" delta would be misleading.
    final text = from != to && to > 0
        ? 'Valor atualizado: R\$ ${_brlFormat.format(from)} → '
              'R\$ ${_brlFormat.format(to)}'
        : 'Análise atualizada.';
    return Container(
      margin: EdgeInsets.only(top: theme.spacing.small),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: CirculariColorsTokens.freshCore50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CirculariColorsTokens.freshCore200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.typography.body.medium.medium.copyWith(
                color: CirculariColorsTokens.freshCore900,
              ),
            ),
          ),
          TextButton(
            onPressed: onUndo,
            child: const Text('Desfazer'),
          ),
        ],
      ),
    );
  }
}

/// Soft warning when the AI thinks the photo contradicts the correction. The
/// user's word stands — Manter dismisses, Desfazer rolls everything back.
class _ConflictBanner extends StatelessWidget {
  final String note;
  final VoidCallback onKeep;
  final VoidCallback onUndo;

  const _ConflictBanner({
    required this.note,
    required this.onKeep,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    return Container(
      margin: EdgeInsets.only(top: theme.spacing.small),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: CirculariColorsTokens.solarPulse50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CirculariColorsTokens.solarPulse200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: CirculariColorsTokens.solarPulse700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note,
                  style: theme.typography.body.medium.medium.copyWith(
                    color: CirculariColorsTokens.solarPulse800,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: onKeep, child: const Text('Manter')),
              TextButton(onPressed: onUndo, child: const Text('Desfazer')),
            ],
          ),
        ],
      ),
    );
  }
}
