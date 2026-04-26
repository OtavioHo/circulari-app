import 'dart:io';

import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../bloc/ai_analysis_cubit.dart';
import '../bloc/categories_cubit.dart';
import '../bloc/items_bloc.dart';
import '../bloc/items_event.dart';
import '../bloc/items_state.dart';

class AddItemFormPage extends StatefulWidget {
  final String imagePath;
  final String listId;

  const AddItemFormPage({
    super.key,
    required this.imagePath,
    required this.listId,
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
    if (state is AiAnalysisSuccess) {
      final result = state.result;
      if (_nameCtrl.text.isEmpty) _nameCtrl.text = result.name;
      if (_descCtrl.text.isEmpty) _descCtrl.text = result.description;
      if (_valueCtrl.text.isEmpty && result.priceMin > 0) {
        _valueCtrl.text = result.priceMin.toStringAsFixed(2);
      }
      if (result.categoryId != null) {
        setState(() => _selectedCategoryId = result.categoryId);
      }
    } else if (state is AiAnalysisFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not analyse image: ${state.message}')),
      );
    }
  }

  void _onItemsState(BuildContext context, ItemsState state) {
    if (state is ItemsSuccess) {
      Navigator.of(context).pop();
    } else if (state is ItemsActionFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
    final value = double.tryParse(_valueCtrl.text.trim());
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
                  builder: (context, state) => state is AiAnalysisLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: LinearProgressIndicator(),
                        )
                      : const SizedBox(height: 16),
                ),
                CirculariTextFormField(
                  controller: _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                  label: 'Name *',
                ),
                SizedBox(height: theme.spacing.large),
                CirculariTextFormField(
                  controller: _descCtrl,
                  label: 'Descreva o item',
                  lines: 4,
                ),
                SizedBox(height: theme.spacing.large),
                CirculariTextFormField(
                  controller: _valueCtrl,
                  label: 'Preço',
                  description: 'Preço estimado pela IA: R\$5.000,00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                SizedBox(height: theme.spacing.large),
                _CategoryDropdown(
                  selectedCategoryId: _selectedCategoryId,
                  onChanged: (id) => setState(() => _selectedCategoryId = id),
                ),
                SizedBox(height: theme.spacing.large),
                BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                  builder: (context, aiState) =>
                      BlocBuilder<ItemsBloc, ItemsState>(
                        builder: (context, itemsState) => FilledButton(
                          onPressed:
                              aiState is AiAnalysisLoading ||
                                  itemsState is ItemsLoading
                              ? null
                              : _submit,
                          child: itemsState is ItemsLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Add item'),
                        ),
                      ),
                ),
              ],
            ),
          ),
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
        CategoriesSuccess(:final categories) => _buildDropdown(categories),
        CategoriesFailure() => const SizedBox.shrink(),
        CategoriesInitial() => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildDropdown(List<Category> categories) {
    final validId = categories.any((c) => c.id == selectedCategoryId)
        ? selectedCategoryId
        : null;

    return DropdownButtonFormField<String>(
      key: ValueKey(validId),
      initialValue: validId,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('No category')),
        ...categories.map(
          (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
