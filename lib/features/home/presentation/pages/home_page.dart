import 'package:app/features/lists/presentation/utils/list_picture_map.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../items/presentation/bloc/search_items_bloc.dart';
import '../../../items/presentation/bloc/search_items_event.dart';
import '../../../items/presentation/bloc/search_items_state.dart';
import '../../../lists/presentation/bloc/lists_bloc.dart';
import '../../../lists/presentation/bloc/lists_event.dart';
import '../../../lists/presentation/bloc/lists_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CirculariCollapsibleBody(
      expandedHeight: 200,
      collapsedHeight: 87,
      headerBuilder: (context, shrinkOffset) {
        final typography = context.circulariTheme.typography;
        final spacing = context.circulariTheme.spacing;
        const maxShrink = 200.0 - 87.0;
        final t = (shrinkOffset / maxShrink).clamp(0.0, 1.0);

        return Stack(
          children: [
            Opacity(
              opacity: (1 - t * 2).clamp(0.0, 1.0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.medium,
                  spacing.large,
                  spacing.medium,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo',
                      style: typography.heading2.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: spacing.medium),
                    Text(
                      'Total de bens listados',
                      style: typography.body.medium.regular,
                    ),
                    Text(
                      'R\$ 123.456,78',
                      style: typography.heading1.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: ((t - 0.5) * 2).clamp(0.0, 1.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.medium,
                    0,
                    spacing.medium,
                    spacing.medium,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total de bens listados',
                        style: typography.body.medium.regular,
                      ),
                      Text(
                        'R\$ 123.456,78',
                        style: typography.heading1.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      children: [
        BlocBuilder<ListsBloc, ListsState>(
          builder: (context, state) => switch (state) {
            ListsInitial() || ListsLoading() => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            ListsSuccess(:final lists) ||
            ListsActionFailure(:final lists) => CirculariListsCarousel(
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                return CirculariListCard(
                  title: list.name,
                  itemCount: list.itemCount,
                  value: list.totalValue,
                  picturePath: assetForSlug(list.picture.slug) ?? '',
                  backgroundColor: Color(
                    int.parse(list.color.hexCode.replaceFirst('#', '0xff')),
                  ),
                  onTap: () => context.push(
                    '/lists/${list.id}/items?name=${Uri.encodeComponent(list.name)}',
                  ),
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
                    onPressed: () => context.read<ListsBloc>().add(
                      const ListsLoadRequested(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.circulariTheme.spacing.medium,
          ),
          child: Text(
            "Items recentes",
            style: context.circulariTheme.typography.body.xLarge.bold.copyWith(
              color: CirculariColorsTokens.greyscale800,
            ),
          ),
        ),
        BlocBuilder<SearchItemsBloc, SearchItemsState>(
          builder: (context, state) => switch (state) {
            SearchItemsInitial() || SearchItemsLoading() => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
            SearchItemsFailure(:final message) => Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<SearchItemsBloc>().add(
                        const SearchItemsLoadRequested(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
            SearchItemsSuccess(:final items) => Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CirculariItemListTile(
                        name: item.name,
                        quantity: item.quantity,
                        price: item.userDefinedValue ?? 0,
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
                      ),
                    ),
                  )
                  .toList(),
            ),
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
