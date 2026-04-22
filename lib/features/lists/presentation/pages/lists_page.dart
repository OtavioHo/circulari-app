import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/lists_bloc.dart';
import '../bloc/lists_event.dart';
import '../bloc/lists_state.dart';
import '../widgets/list_card.dart';
import '../widgets/list_name_dialog.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListsBloc, ListsState>(
      listener: (context, state) {
        if (state is ListsActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: const _ListsScaffold(),
    );
  }
}

class _ListsScaffold extends StatelessWidget {
  const _ListsScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onCreateTapped(context),
        tooltip: 'New list',
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ListsBloc, ListsState>(
        builder: (context, state) => switch (state) {
          ListsInitial() => const SizedBox.shrink(),
          ListsLoading() => const Center(child: CircularProgressIndicator()),
          ListsSuccess(:final lists) ||
          ListsActionFailure(:final lists) =>
            lists.isEmpty
                ? const Center(child: Text('No lists yet. Tap + to create one.'))
                : ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (ctx, i) {
                      final list = lists[i];
                      return ListCard(
                        list: list,
                        onTap: () => context.push(
                          '/lists/${list.id}/items?name=${Uri.encodeComponent(list.name)}',
                        ),
                        onDelete: () => _onDeleteTapped(context, list.id, list.name),
                        onRename: () =>
                            _onRenameTapped(context, list.id, list.name),
                      );
                    },
                  ),
          ListsFailure(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ListsBloc>()
                        .add(const ListsLoadRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        },
      ),
    );
  }

  Future<void> _onCreateTapped(BuildContext context) async {
    await context.push('/lists/create');
    if (context.mounted) {
      context.read<ListsBloc>().add(const ListsLoadRequested());
    }
  }

  Future<void> _onRenameTapped(
    BuildContext context,
    String id,
    String currentName,
  ) async {
    final name = await showListNameDialog(
      context,
      title: 'Rename list',
      initialValue: currentName,
    );
    if (name != null && context.mounted) {
      context.read<ListsBloc>().add(ListsRenameRequested(id, name));
    }
  }

  Future<void> _onDeleteTapped(
    BuildContext context,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete list'),
        content: Text('Delete "$name"? This cannot be undone.'),
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
      context.read<ListsBloc>().add(ListsDeleteRequested(id));
    }
  }
}
