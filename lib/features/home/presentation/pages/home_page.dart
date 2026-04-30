import 'package:circulari/features/lists/presentation/utils/list_picture_map.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';

import 'package:circulari/features/items/presentation/bloc/search_items_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_event.dart';
import 'package:circulari/features/items/presentation/bloc/search_items_state.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_bloc.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_event.dart';
import 'package:circulari/features/lists/presentation/bloc/lists_state.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:circulari/features/home/presentation/bloc/dashboard_state.dart';

String _formatBRL(double value) =>
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ').format(value);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: CirculariCollapsibleBody(
        expandedHeight: 250,
        collapsedHeight: 87,
        headerBuilder: (context, shrinkOffset) {
          final typography = context.circulariTheme.typography;
          final spacing = context.circulariTheme.spacing;
          const maxShrink = 250.0 - 87.0;
          final t = (shrinkOffset / maxShrink).clamp(0.0, 1.0);
          final scale = 1.0 - (t);

          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              final totalValueText = switch (state) {
                DashboardSuccess(:final summary) => _formatBRL(
                  summary.totalValue,
                ),
                _ => 'R\$ —',
              };

              return Transform.scale(
                scale: scale,
                alignment: Alignment.center,
                child: Opacity(
                  opacity: (1 - t * 2).clamp(0.0, 1.0),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      spacing.medium,
                      spacing.large,
                      spacing.medium,
                      0,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListenableBuilder(
                            listenable: context.read<AuthStateNotifier>(),
                            builder: (context, _) {
                              final name =
                                  context.read<AuthStateNotifier>().userName ??
                                  '';
                              return Text(
                                'Olá, $name!',
                                style: typography.heading2.copyWith(
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: spacing.medium),
                          Text(
                            'Total de bens listados',
                            style: typography.body.small.regular,
                          ),
                          Text(
                            totalValueText,
                            style: typography.heading1.copyWith(
                              color: CirculariColorsTokens.freshCore500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        displayCardsBuilder: (context, shrinkOffset) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CirculariCardButton(
                        icon: Icons.add,
                        label: 'Crie\n Item/Lista',
                        onTap: () {
                          context.go('/add');
                        },
                      ),
                      const SizedBox(width: 8),
                      CirculariCardButton(
                        icon: Icons.edit,
                        label: 'Gerencie Listas',
                        onTap: () {
                          context.go('/lists');
                        },
                      ),
                      const SizedBox(width: 8),
                      CirculariCardButton(
                        icon: Icons.list,
                        label: 'Minhas listas',
                        onTap: () {
                          context.go('/lists');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
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
              ListsActionFailure(:final lists) => lists.isEmpty
                  ? CirculariEmptyState(
                      icon: Icons.folder_open,
                      title: 'Sem listas ainda',
                      description:
                          'Crie sua primeira lista para começar a organizar seus bens.',
                      ctaLabel: 'Criar lista',
                      onCtaPressed: () => context.go('/add'),
                    )
                  : CirculariListsCarousel(
                      itemCount: lists.length,
                      itemBuilder: (context, index) {
                        final list = lists[index];
                        return CirculariListCard(
                          title: list.name,
                          itemCount: list.itemCount,
                          value: list.totalValue,
                          seed: index,
                          picturePath: assetForSlug(list.picture.slug) ?? '',
                          backgroundColor: Color(
                            int.parse(
                              list.color.hexCode.replaceFirst('#', '0xff'),
                            ),
                          ),
                          onTap: () => context.push(
                            '/lists/${list.id}/items',
                            extra: list,
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
          BlocBuilder<ListsBloc, ListsState>(
            buildWhen: (prev, curr) => _hasListsChanged(prev, curr),
            builder: (context, listsState) {
              if (!_hasLists(listsState)) return const SizedBox.shrink();
              return Column(
                children: [
                  const SizedBox(height: 24),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.circulariTheme.spacing.medium,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Items recentes",
                        style: context.circulariTheme.typography.body.xLarge.bold
                            .copyWith(color: CirculariColorsTokens.greyscale800),
                      ),
                    ),
                  ),
                  _buildRecentItems(context),
                ],
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  static bool _hasLists(ListsState state) => switch (state) {
    ListsSuccess(:final lists) ||
    ListsActionFailure(:final lists) => lists.isNotEmpty,
    _ => false,
  };

  static bool _hasListsChanged(ListsState prev, ListsState curr) =>
      _hasLists(prev) != _hasLists(curr);

  Widget _buildRecentItems(BuildContext context) {
    return BlocBuilder<SearchItemsBloc, SearchItemsState>(
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
              SearchItemsSuccess(:final items) => items.isEmpty
                  ? CirculariEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'Nenhum item cadastrado',
                      description:
                          'Adicione um item para vê-lo aparecer aqui.',
                      ctaLabel: 'Criar item',
                      onCtaPressed: () => context.push('/items/add'),
                    )
                  : Column(
                children: [
                  ...items.map(
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
                        onTap: () =>
                            context.push('/items/${item.id}', extra: item),
                      ),
                    ),
                  ),
                ],
              ),
            },
          );
  }
}
