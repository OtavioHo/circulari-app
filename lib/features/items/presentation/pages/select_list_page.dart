import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../lists/presentation/bloc/lists_bloc.dart';
import '../../../lists/presentation/bloc/lists_state.dart';

class SelectListPage extends StatelessWidget {
  const SelectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CirculariInAppScaffold(
      onBackPressed: () => context.pop(),
      title: 'Selecionar lista',
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<ListsBloc, ListsState>(
          builder: (context, state) => switch (state) {
            ListsInitial() || ListsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            ListsSuccess(:final lists) ||
            ListsActionFailure(:final lists) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escolha uma lista',
                  style: context.circulariTheme.typography.heading3.copyWith(
                    color: CirculariColorsTokens.greyscale900,
                  ),
                ),
                Text(
                  'Selecione a lista onde o item será adicionado.',
                  style: context.circulariTheme.typography.body.medium.regular
                      .copyWith(color: CirculariColorsTokens.greyscale500),
                ),
                SizedBox(height: context.circulariTheme.spacing.xLarge),
                if (lists.isEmpty)
                  const Text('Nenhuma lista ainda.')
                else
                  CirculariSelectBox<String>(
                    options: [
                      for (final list in lists)
                        CirculariSelectOption(
                          label: list.name,
                          value: list.id,
                        ),
                    ],
                    selected: null,
                    onSelected: (value) =>
                        context.push('/items/add?listId=$value'),
                  ),
              ],
            ),
            ListsFailure(:final message) => Center(child: Text(message)),
          },
        ),
      ),
    );
  }
}
