import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/item.dart';
import '../bloc/item_detail_bloc.dart';
import '../bloc/item_detail_event.dart';
import '../bloc/item_detail_state.dart';
import '../widgets/item_form_sheet.dart';

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItemDetailBloc, ItemDetailState>(
      listener: (context, state) {
        if (state is ItemDetailDeleted) {
          context.pop();
        } else if (state is ItemDetailFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) => switch (state) {
        ItemDetailDeleted() => const SizedBox.shrink(),
        ItemDetailInitial(:final item) ||
        ItemDetailLoading(:final item) ||
        ItemDetailSuccess(:final item) ||
        ItemDetailFailure(:final item) =>
          _ItemDetailScaffold(
            item: item,
            isLoading: state is ItemDetailLoading,
          ),
      },
    );
  }
}

class _ItemDetailScaffold extends StatelessWidget {
  final Item item;
  final bool isLoading;

  const _ItemDetailScaffold({required this.item, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: isLoading ? null : () => _confirmDelete(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isLoading ? null : () => _onEditTapped(context),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Edit'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ItemDetailBody(item: item),
    );
  }

  Future<void> _onEditTapped(BuildContext context) async {
    final result = await showItemFormSheet(context, existing: item);
    if (result == null || !context.mounted) return;
    context.read<ItemDetailBloc>().add(
          ItemDetailUpdateRequested(
            item.id,
            name: result.name,
            description: result.description,
            quantity: result.quantity,
            categoryId: result.categoryId,
            userDefinedValue: result.userDefinedValue,
          ),
        );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item'),
        content: Text('Delete "${item.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context
          .read<ItemDetailBloc>()
          .add(ItemDetailDeleteRequested(item.id));
    }
  }
}

class _ItemDetailBody extends StatelessWidget {
  final Item item;

  const _ItemDetailBody({required this.item});

  @override
  Widget build(BuildContext context) {
    final mainImage = item.images.firstOrNull;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ItemImage(url: mainImage?.url),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.category != null) ...[
                  Chip(label: Text(item.category!.name)),
                  const SizedBox(height: 12),
                ],
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Quantity',
                  value: item.quantity.toString(),
                ),
                if (item.userDefinedValue != null) ...[
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.attach_money_outlined,
                    label: 'Value',
                    value: 'R\$ ${item.userDefinedValue!.toStringAsFixed(2)}',
                  ),
                ],
                if (item.listInfo != null) ...[
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.list_alt_outlined,
                    label: 'List',
                    value: item.listInfo!.name,
                    accent: _hexColor(item.listInfo!.color),
                  ),
                ],
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Added',
                  value: _formatDate(item.createdAt),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  Color? _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return null;
    }
  }
}

class _ItemImage extends StatelessWidget {
  final String? url;

  const _ItemImage({this.url});

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return Image.network(
        url!,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      height: 260,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 64,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accent;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        if (accent != null) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
