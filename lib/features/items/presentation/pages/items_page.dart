import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/items_bloc.dart';
import '../bloc/items_event.dart';
import '../bloc/items_state.dart';
import '../widgets/item_form_sheet.dart';

class ItemsPage extends StatelessWidget {
  final String listId;
  final String listName;

  const ItemsPage({super.key, required this.listId, required this.listName});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemsBloc, ItemsState>(
      listener: (context, state) {
        if (state is ItemsActionFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
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
          ItemsSuccess(:final items) || ItemsActionFailure(:final items) =>
            items.isEmpty
                ? const Center(child: Text('No items yet. Tap + to add one.'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      return CirculariItemListTile(
                        name: item.name,
                        quantity: item.quantity,
                        price: item.userDefinedValue ?? 0.0,
                        listName: item.listInfo?.name ?? '',
                        listColor: item.listInfo != null
                            ? Color(
                                int.parse(
                                  item.listInfo!.color.replaceFirst(
                                    '#',
                                    '0xff',
                                  ),
                                ),
                              )
                            : CirculariColorsTokens.greyscale300,
                        categoryName: item.category?.name ?? '',
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
                  onPressed: () =>
                      context.read<ItemsBloc>().add(ItemsLoadRequested(listId)),
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
}
