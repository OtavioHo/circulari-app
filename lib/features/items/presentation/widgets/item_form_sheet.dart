import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/item.dart';
import '../bloc/ai_analysis_cubit.dart';
import '../bloc/categories_cubit.dart';

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

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _qtyCtrl = TextEditingController(text: (e?.quantity ?? 1).toString());
    _valueCtrl = TextEditingController(
      text: e?.userDefinedValue != null
          ? e!.userDefinedValue!.toStringAsFixed(2)
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
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
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
    final value = double.tryParse(_valueCtrl.text.trim());
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

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<AiAnalysisCubit, AiAnalysisState>(
      listener: _onAnalysisState,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit item' : 'New item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                builder: (context, state) => _ImagePickerArea(
                  imagePath: _imagePath,
                  existingUrl: widget.existing?.images.firstOrNull?.url,
                  isAnalyzing: state is AiAnalysisLoading,
                  onTap: _showImageSourceDialog,
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 20),
              BlocBuilder<AiAnalysisCubit, AiAnalysisState>(
                builder: (context, state) => FilledButton(
                  onPressed: state is AiAnalysisLoading ? null : _submit,
                  child: Text(isEditing ? 'Save changes' : 'Add item'),
                ),
              ),
            ],
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
                          'Analysing…',
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 36,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Add photo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
