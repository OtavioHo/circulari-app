import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/item.dart';
import '../bloc/items_bloc.dart';
import '../bloc/items_event.dart';
import '../bloc/items_state.dart';
import '../widgets/item_card.dart';
import '../widgets/item_form_sheet.dart';

class ItemsPage extends StatelessWidget {
  final String listId;
  final String listName;

  const ItemsPage({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemsBloc, ItemsState>(
      listener: (context, state) {
        if (state is ItemsActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: _ItemsScaffold(listId: listId, listName: listName),
    );
  }
}

class _ItemsScaffold extends StatelessWidget {
  final String listId;
  final String listName;

  const _ItemsScaffold({required this.listId, required this.listName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listName)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddTapped(context),
        tooltip: 'New item',
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ItemsBloc, ItemsState>(
        builder: (context, state) => switch (state) {
          ItemsInitial() => const SizedBox.shrink(),
          ItemsLoading() => const Center(child: CircularProgressIndicator()),
          ItemsSuccess(:final items) ||
          ItemsActionFailure(:final items) =>
            items.isEmpty
                ? const Center(
                    child: Text('No items yet. Tap + to add one.'),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      return ItemCard(
                        item: item,
                        onEdit: () => _onEditTapped(context, item),
                        onDelete: () =>
                            _onDeleteTapped(context, item.id, item.name),
                      );
                    },
                  ),
          ItemsFailure(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ItemsBloc>()
                        .add(ItemsLoadRequested(listId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }

  Future<void> _onAddTapped(BuildContext context) async {
    final result = await showItemFormSheet(context);
    if (result != null && context.mounted) {
      context.read<ItemsBloc>().add(
            ItemsCreateRequested(
              listId: listId,
              name: result.name,
              description: result.description,
              quantity: result.quantity,
              categoryId: result.categoryId,
              userDefinedValue: result.userDefinedValue,
              imagePath: result.imagePath,
            ),
          );
    }
  }

  Future<void> _onEditTapped(BuildContext context, Item item) async {
    final result = await showItemFormSheet(context, existing: item);
    if (result != null && context.mounted) {
      context.read<ItemsBloc>().add(
            ItemsUpdateRequested(
              item.id,
              name: result.name,
              description: result.description,
              quantity: result.quantity,
              categoryId: result.categoryId,
              userDefinedValue: result.userDefinedValue,
            ),
          );
    }
  }

  Future<void> _onDeleteTapped(
    BuildContext context,
    String itemId,
    String itemName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item'),
        content: Text('Delete "$itemName"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ItemsBloc>().add(ItemsDeleteRequested(itemId));
    }
  }

}
