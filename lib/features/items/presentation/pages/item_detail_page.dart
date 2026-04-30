import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_event.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_state.dart';
import 'package:circulari/features/items/presentation/widgets/item_form_sheet.dart';

const _expandedHeight = 260.0;
const _collapsedHeight = 56.0;

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
    final mainImageUrl = item.images.firstOrNull?.url;
    final hasImage = mainImageUrl != null;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CirculariColorsTokens.freshCore,
        foregroundColor: CirculariColorsTokens.greyscale900,
        onPressed: isLoading ? null : () => _onEditTapped(context),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Editar'),
      ),
      body: CirculariCollapsibleBody(
        expandedHeight: _expandedHeight,
        collapsedHeight: _collapsedHeight,
        backgroundBuilder: hasImage
            ? (context, shrinkOffset) =>
                _buildImageBackground(mainImageUrl, shrinkOffset)
            : null,
        headerBuilder: (context, shrinkOffset) =>
            _buildHeader(context, shrinkOffset),
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ..._buildBody(context),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildImageBackground(String url, double shrinkOffset) {
    final progress =
        (shrinkOffset / (_expandedHeight - _collapsedHeight)).clamp(0.0, 1.0);
    return Opacity(
      opacity: (1.0 - progress).clamp(0.0, 1.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withAlpha(100),
                    Colors.black.withAlpha(200),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double shrinkOffset) {
    final progress =
        (shrinkOffset / (_expandedHeight - _collapsedHeight)).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment:
            Alignment.lerp(Alignment.topLeft, Alignment.centerLeft, progress)!,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: TextStyle.lerp(
                circulariTypography.heading2.copyWith(color: Colors.white),
                circulariTypography.heading5.copyWith(color: Colors.white),
                progress,
              ),
            ),
            const SizedBox(height: 12),
            if (item.category != null && progress < 0.6)
              Opacity(
                opacity: (1.0 - progress).clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withAlpha(80)),
                  ),
                  child: Text(
                    item.category!.name,
                    style: circulariTypography.body.small.regular.copyWith(
                      color: CirculariColorsTokens.greyscale100,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    final typography = context.circulariTheme.typography;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.description != null && item.description!.isNotEmpty) ...[
              Text(
                item.description!,
                style: typography.body.medium.regular.copyWith(
                  color: CirculariColorsTokens.greyscale700,
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Detalhes',
              style: typography.body.xLarge.bold.copyWith(
                color: CirculariColorsTokens.greyscale800,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.inventory_2_outlined,
              label: 'Quantidade',
              value: item.quantity.toString(),
            ),
            if (item.userDefinedValue != null) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.attach_money_outlined,
                label: 'Valor',
                value: 'R\$ ${item.userDefinedValue!.toStringAsFixed(2)}',
              ),
            ],
            if (item.listInfo != null) ...[
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.list_alt_outlined,
                label: 'Lista',
                value: item.listInfo!.name,
                accent: _hexColor(item.listInfo!.color),
              ),
            ],
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Adicionado',
              value: _formatDate(item.createdAt),
            ),
            const SizedBox(height: 32),
            Center(
              child: TextButton.icon(
                onPressed: isLoading ? null : () => _confirmDelete(context),
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                label: Text(
                  'Excluir item',
                  style: typography.body.medium.bold.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
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
        title: const Text('Excluir item'),
        content: Text('Excluir "${item.name}"? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<ItemDetailBloc>().add(ItemDetailDeleteRequested(item.id));
    }
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
    final typography = context.circulariTheme.typography;
    return Row(
      children: [
        Icon(icon, size: 20, color: CirculariColorsTokens.greyscale600),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: typography.body.medium.regular.copyWith(
            color: CirculariColorsTokens.greyscale600,
          ),
        ),
        if (accent != null) ...[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            value,
            style: typography.body.medium.regular.copyWith(
              color: CirculariColorsTokens.greyscale800,
            ),
          ),
        ),
      ],
    );
  }
}
