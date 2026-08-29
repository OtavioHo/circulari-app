import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_event.dart';
import 'package:circulari/features/items/presentation/bloc/item_detail_state.dart';
import 'package:circulari/features/items/presentation/widgets/item_form_sheet.dart';
import 'package:circulari/features/items/presentation/widgets/price_insight.dart';
import 'package:circulari/features/items/presentation/widgets/revalue_sheet.dart';
import 'package:circulari/features/items/presentation/widgets/share_item_button.dart';

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
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Editar',
              textAlign: TextAlign.center,
              style: context.circulariTheme.typography.body.large.semibold
                  .copyWith(
                    color: CirculariColorsTokens.greyscale900,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined),
          ],
        ),
      ),
      body: CirculariCollapsibleBody(
        expandedHeight: _expandedHeight,
        collapsedHeight: _collapsedHeight,
        showBackButton: true,
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
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final mainImageUrl = item.images.firstOrNull?.url;
    // The getter builds a fresh object — read it once per build.
    final aiInsight = item.aiInsight;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (item.category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: CirculariColorsTokens.greyscale700,
                      ),
                    ),
                    child: Text(
                      item.category!.name,
                      style: typography.body.medium.regular.copyWith(
                        color: CirculariColorsTokens.greyscale700,
                      ),
                    ),
                  ),
                const Spacer(),
                ShareItemButton(itemId: item.id, disabled: isLoading),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: isLoading ? null : () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline),
                  color: CirculariColorsTokens.greyscale700,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: CirculariColorsTokens.greyscale700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (item.description != null && item.description!.isNotEmpty) ...[
              Text(
                item.description!,
                style: typography.body.medium.regular.copyWith(
                  color: CirculariColorsTokens.greyscale700,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(
                height: 1,
                thickness: 1,
                color: CirculariColorsTokens.greyscale200,
              ),
              const SizedBox(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalhes',
                  style: typography.body.xLarge.bold.copyWith(
                    color: CirculariColorsTokens.greyscale800,
                  ),
                ),
                if (mainImageUrl != null)
                  TextButton(
                    onPressed: () => _openImage(context, mainImageUrl),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'ver produto',
                      style: typography.body.large.regular.copyWith(
                        color: const Color(0xFF878787),
                        height: 1.2,
                        letterSpacing: 0,
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF878787),
                      ),
                    ),
                  ),
              ],
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
                value: NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$ ',
                ).format(item.userDefinedValue),
              ),
            ],
            // Saved-item revaluation: only offered when there's a stored image
            // for the AI to re-analyze (the backend 422s without one).
            if (item.images.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: isLoading ? null : () => _onRevalueTapped(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Valor parece errado?',
                    style: typography.body.medium.regular.copyWith(
                      color: const Color(0xFF878787),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF878787),
                    ),
                  ),
                ),
              ),
            if (aiInsight != null) ...[
              const SizedBox(height: 12),
              PriceInsight(analysis: aiInsight),
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
          ],
        ),
      ),
    ];
  }

  Future<void> _onRevalueTapped(BuildContext context) async {
    final result = await showRevalueSheet(context, item: item);
    if (result == null || !context.mounted) return;
    // The server copies the price snapshot from the analysis (ai_analysis_id);
    // the accepted fields ride along as a normal update.
    context.read<ItemDetailBloc>().add(
          ItemDetailUpdateRequested(
            item.id,
            name: result.name,
            description: result.description,
            categoryId: result.categoryId,
            userDefinedValue: result.hasEstimate ? result.suggestedPrice : null,
            aiAnalysisId: result.analysisId,
          ),
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
            aiAnalysisId: result.aiAnalysisId,
            imagePath: result.imagePath,
          ),
        );
  }

  void _openImage(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(230),
      builder: (ctx) => Dialog.fullscreen(
        backgroundColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Material(
                    color: Colors.black.withAlpha(120),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: CirculariColorsTokens.greyscale50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await ConfirmDeleteBottomSheet.show(
      context,
      title: 'Tem certeza que deseja excluir o item?',
      message: 'Caso exclua o item, ele será excluído definitivamente.',
      cancelLabel: 'Voltar',
      confirmLabel: 'Sim, excluir item',
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
          style: typography.body.large.regular.copyWith(
            color: CirculariColorsTokens.greyscale800,
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
            style: typography.body.large.regular.copyWith(
              color: CirculariColorsTokens.greyscale800,
            ),
          ),
        ),
      ],
    );
  }
}
