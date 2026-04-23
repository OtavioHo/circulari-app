import 'dart:io';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
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
    return MultiBlocListener(
      listeners: [
        BlocListener<AiAnalysisCubit, AiAnalysisState>(
          listener: _onAnalysisState,
        ),
        BlocListener<ItemsBloc, ItemsState>(listener: _onItemsState),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('New item')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.imagePath),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _CategoryDropdown(
                  selectedCategoryId: _selectedCategoryId,
                  onChanged: (id) => setState(() => _selectedCategoryId = id),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _qtyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n < 1) return 'Min 1';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _valueCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Value (R\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                  builder: (context, aiState) =>
                      BlocBuilder<ItemsBloc, ItemsState>(
                    builder: (context, itemsState) => FilledButton(
                      onPressed: aiState is AiAnalysisLoading ||
                              itemsState is ItemsLoading
                          ? null
                          : _submit,
                      child: itemsState is ItemsLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
        CategoriesSuccess(:final categories) =>
          _buildDropdown(categories),
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
