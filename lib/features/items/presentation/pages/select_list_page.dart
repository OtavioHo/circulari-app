import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../lists/presentation/bloc/lists_bloc.dart';
import '../../../lists/presentation/bloc/lists_state.dart';

class SelectListPage extends StatelessWidget {
  const SelectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a list')),
      body: BlocBuilder<ListsBloc, ListsState>(
        builder: (context, state) => switch (state) {
          ListsInitial() || ListsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          ListsSuccess(:final lists) ||
          ListsActionFailure(:final lists) =>
            lists.isEmpty
                ? const Center(child: Text('No lists yet.'))
                : ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return ListTile(
                        title: Text(list.name),
                        subtitle: Text('${list.itemCount} items'),
                        onTap: () =>
                            context.push('/items/add?listId=${list.id}'),
                      );
                    },
                  ),
          ListsFailure(:final message) => Center(child: Text(message)),
        },
      ),
    );
  }
}
