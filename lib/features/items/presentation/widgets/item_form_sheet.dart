import 'dart:io';

import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:circulari/core/di/injection.dart';
import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';
import 'package:circulari/features/items/domain/entities/category.dart';
import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/presentation/bloc/ai_analysis_cubit.dart';
import 'package:circulari/features/items/presentation/bloc/categories_cubit.dart';

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

/// Bottom sheet used for both creating and editing an item.
/// Returns an [ItemFormResult] when the user taps Save, or null if cancelled.
class ItemFormResult {
  final String name;
  final String? description;
  final int quantity;
  final String? categoryId;
  final double? userDefinedValue;
  final String? imagePath;

  const ItemFormResult({
    required this.name,
    this.description,
    required this.quantity,
    this.categoryId,
    this.userDefinedValue,
    this.imagePath,
  });
}

Future<ItemFormResult?> showItemFormSheet(
  BuildContext context, {
  Item? existing,
}) {
  return showModalBottomSheet<ItemFormResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: CirculariColorsTokens.greyscale800,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AiAnalysisCubit>()),
        BlocProvider(create: (_) => sl<CategoriesCubit>()..load()),
      ],
      child: _ItemFormSheet(existing: existing),
    ),
  );
}

class _ItemFormSheet extends StatefulWidget {
  final Item? existing;
  const _ItemFormSheet({this.existing});

  @override
  State<_ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends State<_ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _valueCtrl;

  String? _imagePath;
  String? _selectedCategoryId;
  AiAnalysisResult? _analysis;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _qtyCtrl = TextEditingController(text: (e?.quantity ?? 1).toString());
    _valueCtrl = TextEditingController(
      text: e?.userDefinedValue != null
          ? _brlFormat.format(e!.userDefinedValue)
          : '',
    );
    _selectedCategoryId = e?.category?.id;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _qtyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1280,
    );
    if (file != null && mounted) {
      setState(() => _imagePath = file.path);
      context.read<AiAnalysisCubit>().analyze(file.path);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: CirculariColorsTokens.greyscale800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: CirculariColorsTokens.greyscale50,
              ),
              title: Text(
                'Tirar foto',
                style: TextStyle(color: CirculariColorsTokens.greyscale50),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: CirculariColorsTokens.greyscale50,
              ),
              title: Text(
                'Escolher da galeria',
                style: TextStyle(color: CirculariColorsTokens.greyscale50),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    final value = _parseBrl(_valueCtrl.text);
    final desc = _descCtrl.text.trim();

    Navigator.of(context).pop(
      ItemFormResult(
        name: _nameCtrl.text.trim(),
        description: desc.isEmpty ? null : desc,
        quantity: qty,
        categoryId: _selectedCategoryId,
        userDefinedValue: value,
        imagePath: _imagePath,
      ),
    );
  }

  void _onAnalysisState(BuildContext context, AiAnalysisState state) {
    if (state is AiAnalysisSuccess) {
      final result = state.result;
      if (_nameCtrl.text.isEmpty) _nameCtrl.text = result.name;
      if (_descCtrl.text.isEmpty) _descCtrl.text = result.description;
      if (_valueCtrl.text.isEmpty && result.priceMin > 0) {
        _valueCtrl.text = _brlFormat.format(result.priceMin);
      }
      setState(() {
        _analysis = result;
        if (result.categoryId != null) {
          _selectedCategoryId = result.categoryId;
        }
      });
    } else if (state is AiAnalysisFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível analisar a imagem: ${state.message}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    final typography = context.circulariTheme.typography;

    return BlocListener<AiAnalysisCubit, AiAnalysisState>(
      listener: _onAnalysisState,
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
                      isEditing ? 'Editar item' : 'Novo item',
                      style: typography.body.xLarge.semibold.copyWith(
                        color: CirculariColorsTokens.greyscale50,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                  padding: EdgeInsets.fromLTRB(24, 12, 24, bottom + 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                          builder: (context, state) => _ImagePickerArea(
                            imagePath: _imagePath,
                            existingUrl:
                                widget.existing?.images.firstOrNull?.url,
                            isAnalyzing: state is AiAnalysisLoading,
                            onTap: _showImageSourceDialog,
                          ),
                        ),
                        const SizedBox(height: 20),
                        CirculariTextFormField(
                          controller: _nameCtrl,
                          label: 'Nome *',
                          onDark: true,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'O nome é obrigatório'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CirculariTextFormField(
                          controller: _descCtrl,
                          label: 'Descrição',
                          onDark: true,
                          lines: 2,
                        ),
                        const SizedBox(height: 16),
                        _CategoryDropdown(
                          selectedCategoryId: _selectedCategoryId,
                          onChanged: (id) =>
                              setState(() => _selectedCategoryId = id),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CirculariTextFormField(
                                controller: _qtyCtrl,
                                label: 'Quantidade',
                                onDark: true,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  final n = int.tryParse(v ?? '');
                                  if (n == null || n < 1) return 'Mín. 1';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CirculariTextFormField(
                                controller: _valueCtrl,
                                label: 'Valor',
                                prefixText: 'R\$ ',
                                onDark: true,
                                keyboardType: TextInputType.number,
                                inputFormatters: [_BrlInputFormatter()],
                              ),
                            ),
                          ],
                        ),
                        if (_analysis != null) ...[
                          const SizedBox(height: 12),
                          _PriceInsight(analysis: _analysis!),
                        ],
                        const SizedBox(height: 24),
                        BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                          builder: (context, state) => CirculariButton(
                            onPressed: state is AiAnalysisLoading
                                ? null
                                : _submit,
                            label: isEditing
                                ? 'Salvar alterações'
                                : 'Adicionar item',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final String? selectedCategoryId;
  final ValueChanged<String?> onChanged;

  const _CategoryDropdown({
    required this.selectedCategoryId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) => switch (state) {
        CategoriesLoading() => const SizedBox(
          height: 56,
          child: Center(child: LinearProgressIndicator()),
        ),
        CategoriesSuccess(:final categories) => _buildDropdown(
          context,
          categories,
        ),
        CategoriesFailure() => const SizedBox.shrink(),
        CategoriesInitial() => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildDropdown(BuildContext context, List<Category> categories) {
    // Ensure selectedCategoryId is valid — clear it if it no longer matches.
    final validId = categories.any((c) => c.id == selectedCategoryId)
        ? selectedCategoryId
        : null;

    return CirculariDropdownFormField<String?>(
      label: 'Categoria',
      onDark: true,
      value: validId,
      items: [
        const DropdownMenuItem(value: null, child: Text('Sem categoria')),
        ...categories.map(
          (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _ImagePickerArea extends StatelessWidget {
  final String? imagePath;
  final String? existingUrl;
  final bool isAnalyzing;
  final VoidCallback onTap;

  const _ImagePickerArea({
    required this.imagePath,
    required this.existingUrl,
    required this.isAnalyzing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imagePath != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath!),
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (existingUrl != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          existingUrl!,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _emptyState(context),
        ),
      );
    } else {
      image = _emptyState(context);
    }

    return GestureDetector(
      onTap: isAnalyzing ? null : onTap,
      child: Stack(
        children: [
          image,
          if (isAnalyzing)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: Colors.black45,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'Analisando…',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: CirculariColorsTokens.greyscale900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CirculariColorsTokens.greyscale50, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_a_photo_outlined,
            size: 36,
            color: CirculariColorsTokens.greyscale100,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicionar foto',
            style: context.circulariTheme.typography.body.medium.regular
                .copyWith(color: CirculariColorsTokens.greyscale100),
          ),
        ],
      ),
    );
  }
}

/// Shows the AI price-confidence badge and, when present, the comparable
/// listings the estimate was anchored to (expandable, tappable). The listing
/// links are best-effort (model-authored) — hence the disclaimer.
class _PriceInsight extends StatefulWidget {
  final AiAnalysisResult analysis;
  const _PriceInsight({required this.analysis});

  @override
  State<_PriceInsight> createState() => _PriceInsightState();
}

class _PriceInsightState extends State<_PriceInsight> {
  bool _expanded = false;
  final _priceFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

  ({String label, Color color}) get _confidence =>
      switch (widget.analysis.priceConfidence) {
        PriceConfidence.high => (
          label: 'Alta confiança',
          color: CirculariColorsTokens.freshCore500,
        ),
        PriceConfidence.medium => (
          label: 'Média confiança',
          color: CirculariColorsTokens.solarPulse400,
        ),
        PriceConfidence.low => (
          label: 'Baixa confiança',
          color: CirculariColorsTokens.greyscale400,
        ),
      };

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    final ok =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final conf = _confidence;
    final comps = widget.analysis.priceEvidence;
    final hasComps = comps.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CirculariColorsTokens.greyscale700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ConfidenceBadge(label: conf.label, color: conf.color),
              const Spacer(),
              if (hasComps)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Text(
                        'Baseado em ${comps.length} '
                        '${comps.length == 1 ? 'anúncio' : 'anúncios'}',
                        style: typography.body.small.medium.copyWith(
                          color: CirculariColorsTokens.greyscale200,
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: CirculariColorsTokens.greyscale300,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (!hasComps)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Estimativa sem anúncios de referência.',
                style: typography.body.xSmall.regular.copyWith(
                  color: CirculariColorsTokens.greyscale400,
                ),
              ),
            ),
          if (hasComps && _expanded) ...[
            const SizedBox(height: 8),
            for (final c in comps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openUrl(c.url),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.small.regular.copyWith(
                            color: CirculariColorsTokens.greyscale100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _priceFmt.format(c.price),
                        style: typography.body.small.semibold.copyWith(
                          color: CirculariColorsTokens.greyscale50,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.north_east,
                        size: 14,
                        color: CirculariColorsTokens.greyscale400,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              'Referências aproximadas; os links podem levar a buscas.',
              style: typography.body.xSmall.regular.copyWith(
                color: CirculariColorsTokens.greyscale400,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _ConfidenceBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.circulariTheme.typography.body.xSmall.semibold
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
