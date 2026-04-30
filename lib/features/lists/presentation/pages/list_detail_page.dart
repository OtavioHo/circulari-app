import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:circulari/features/items/domain/entities/item.dart';
import 'package:circulari/features/items/presentation/bloc/items_bloc.dart';
import 'package:circulari/features/items/presentation/bloc/items_event.dart';
import 'package:circulari/features/items/presentation/bloc/items_state.dart';
import 'package:circulari/features/lists/domain/entities/item_list.dart';

const _expandedHeight = 260.0;
const _collapsedHeight = 56.0;

class ListDetailPage extends StatelessWidget {
  final String listId;
  final String listName;
  final String? picturePath;
  final Color? backgroundColor;
  final double? initialTotalValue;
  final int? seed;
  final ItemList? list;

  const ListDetailPage({
    super.key,
    required this.listId,
    required this.listName,
    this.picturePath,
    this.backgroundColor,
    this.initialTotalValue,
    this.seed,
    this.list,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: CirculariColorsTokens.freshCore,
        onPressed: () =>
            context.push('/items/add?listId=$listId', extra: list),
        tooltip: 'Novo Item',
        child: const Icon(Icons.add, color: CirculariColorsTokens.greyscale100),
      ),
      body: BlocConsumer<ItemsBloc, ItemsState>(
        listener: (context, state) {
          if (state is ItemsActionFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final displayTotal = _resolveDisplayTotal(state);
          return CirculariCollapsibleBody(
            expandedHeight: _expandedHeight,
            collapsedHeight: _collapsedHeight,
            backgroundBuilder: picturePath != null && backgroundColor != null
                ? _buildBackground
                : null,
            headerBuilder: (context, shrinkOffset) =>
                _buildHeader(shrinkOffset, displayTotal),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Items',
                  style: context.circulariTheme.typography.body.xLarge.bold
                      .copyWith(color: CirculariColorsTokens.greyscale800),
                ),
              ),
              const SizedBox(height: 8),
              ..._buildChildren(context, state),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  double? _resolveDisplayTotal(ItemsState state) {
    final liveTotal = switch (state) {
      ItemsSuccess(:final items) || ItemsActionFailure(:final items) =>
        items.fold(0.0, (sum, item) => sum + (item.userDefinedValue ?? 0)),
      _ => null,
    };
    return liveTotal ?? initialTotalValue;
  }

  Widget _buildBackground(BuildContext context, double shrinkOffset) {
    final progress = (shrinkOffset / (_expandedHeight - _collapsedHeight))
        .clamp(0.0, 1.0);
    return Opacity(
      opacity: (1.0 - progress).clamp(0.0, 1.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(picturePath!, fit: BoxFit.cover),
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
          Positioned.fill(
            child: CustomPaint(
              painter: _WavePainter(
                color: backgroundColor!.withAlpha(128),
                seed: seed ?? picturePath!.hashCode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double shrinkOffset, double? displayTotal) {
    final progress = (shrinkOffset / (_expandedHeight - _collapsedHeight))
        .clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.lerp(
          Alignment.topLeft,
          Alignment.centerLeft,
          progress,
        )!,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              listName,
              style: TextStyle.lerp(
                circulariTypography.heading2.copyWith(color: Colors.white),
                circulariTypography.heading5.copyWith(color: Colors.white),
                progress,
              ),
            ),
            const SizedBox(height: 24),
            if (displayTotal != null && progress < 0.6)
              Opacity(
                opacity: (1.0 - progress).clamp(0.0, 1.0),
                child: _buildTotalValue(displayTotal),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalValue(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total dos bens listados',
          style: circulariTypography.body.medium.regular.copyWith(
            color: CirculariColorsTokens.greyscale100,
          ),
        ),
        Text(
          'R\$ ${_formatCurrency(total)}',
          style: circulariTypography.heading1.copyWith(
            color: CirculariColorsTokens.freshCore,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildren(BuildContext context, ItemsState state) {
    return switch (state) {
      ItemsInitial() => [],
      ItemsLoading() => [const Center(child: CircularProgressIndicator())],
      ItemsSuccess(:final items) ||
      ItemsActionFailure(:final items) ||
      ItemsQuotaExceeded(:final items) =>
        items.isEmpty
            ? [
                CirculariEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'Esta lista está vazia',
                  description: 'Adicione o primeiro item para começar.',
                  ctaLabel: 'Adicionar item',
                  onCtaPressed: () =>
                      context.push('/items/add?listId=$listId', extra: list),
                ),
              ]
            : [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    itemBuilder: (context, index) =>
                        _buildItemTile(context, items[index]),
                  ),
                ),
              ],
      ItemsFailure(:final message) => [_buildFailureView(context, message)],
    };
  }

  Widget _buildItemTile(BuildContext context, Item item) {
    final listColor = item.listInfo != null
        ? Color(int.parse(item.listInfo!.color.replaceFirst('#', '0xff')))
        : CirculariColorsTokens.greyscale300;

    return GestureDetector(
      onTap: () => context.push('/items/${item.id}', extra: item),
      child: CirculariItemListTile(
        name: item.name,
        quantity: item.quantity,
        price: item.userDefinedValue ?? 0.0,
        listName: item.listInfo?.name ?? '',
        listColor: listColor,
        categoryName: item.category?.name ?? '',
      ),
    );
  }

  Widget _buildFailureView(BuildContext context, String message) {
    return Center(
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
    );
  }

  String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = formatted.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buffer.write('.');
      buffer.write(formatted[i]);
      count++;
    }
    return buffer.toString().split('').reversed.join('');
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  final int seed;

  const _WavePainter({required this.color, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (seed % 3) {
      case 0:
        _drawCurve1(canvas, paint);
      case 1:
        _drawCurve2(canvas, paint);
      default:
        _drawCurve3(canvas, paint);
    }
  }

  void _drawCurve1(Canvas canvas, Paint paint) {
    const Size size = Size(350, 215);
    canvas.rotate(-0.2);
    canvas.translate(-40, 200);
    canvas.drawPath(_curve1(size), paint);
  }

  void _drawCurve2(Canvas canvas, Paint paint) {
    const Size size = Size(461, 335);
    canvas.rotate(-0.1);
    canvas.translate(-20, 170);
    canvas.drawPath(_curve2(size), paint);
  }

  void _drawCurve3(Canvas canvas, Paint paint) {
    const Size size = Size(443, 395);
    canvas.rotate(-0.2);
    canvas.translate(-100, 200);
    canvas.drawPath(_curve3(size), paint);
  }

  Path _curve1(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.5);
    path.cubicTo(
      size.width * 0.15,
      size.height * 0.34,
      size.width / 4,
      size.height * 0.41,
      size.width * 0.3,
      size.height * 0.55,
    );
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.66,
      size.width * 0.45,
      size.height * 0.69,
      size.width * 0.53,
      size.height * 0.61,
    );
    path.cubicTo(
      size.width * 0.53,
      size.height * 0.61,
      size.width * 0.73,
      size.height * 0.37,
      size.width * 0.73,
      size.height * 0.37,
    );
    path.cubicTo(
      size.width * 0.78,
      size.height * 0.31,
      size.width * 0.78,
      size.height * 0.18,
      size.width * 0.73,
      size.height * 0.11,
    );
    path.cubicTo(
      size.width * 0.68,
      size.height * 0.05,
      size.width * 0.6,
      size.height * 0.06,
      size.width * 0.55,
      size.height * 0.14,
    );
    path.cubicTo(
      size.width * 0.55,
      size.height * 0.14,
      size.width * 0.54,
      size.height * 0.17,
      size.width * 0.54,
      size.height * 0.17,
    );
    path.cubicTo(
      size.width * 0.48,
      size.height * 0.27,
      size.width * 0.51,
      size.height * 0.41,
      size.width * 0.58,
      size.height * 0.47,
    );
    path.cubicTo(
      size.width * 0.58,
      size.height * 0.47,
      size.width * 0.63,
      size.height * 0.51,
      size.width * 0.63,
      size.height * 0.51,
    );
    path.cubicTo(
      size.width * 0.71,
      size.height * 0.57,
      size.width * 0.75,
      size.height * 0.7,
      size.width * 0.72,
      size.height * 0.82,
    );
    path.cubicTo(
      size.width * 0.72,
      size.height * 0.82,
      size.width * 0.68,
      size.height * 1.07,
      size.width * 0.68,
      size.height * 1.07,
    );
    return path;
  }

  Path _curve2(Size size) {
    Path path = Path();
    path.lineTo(-0.08, size.height * 0.02);
    path.cubicTo(
      -0.08,
      size.height * 0.02,
      size.width * 0.11,
      size.height * 0.45,
      size.width * 0.11,
      size.height * 0.45,
    );
    path.cubicTo(
      size.width * 0.14,
      size.height * 0.53,
      size.width * 0.26,
      size.height * 0.51,
      size.width * 0.26,
      size.height * 0.42,
    );
    path.cubicTo(
      size.width * 0.26,
      size.height * 0.35,
      size.width * 0.34,
      size.height * 0.31,
      size.width * 0.4,
      size.height * 0.34,
    );
    path.cubicTo(
      size.width * 0.4,
      size.height * 0.34,
      size.width * 0.7,
      size.height * 0.51,
      size.width * 0.7,
      size.height * 0.51,
    );
    path.cubicTo(
      size.width * 0.82,
      size.height * 0.58,
      size.width * 0.95,
      size.height * 0.47,
      size.width * 0.91,
      size.height * 0.34,
    );
    path.cubicTo(
      size.width * 0.91,
      size.height * 0.34,
      size.width * 0.86,
      size.height * 0.17,
      size.width * 0.86,
      size.height * 0.17,
    );
    path.cubicTo(
      size.width * 0.83,
      size.height * 0.1,
      size.width * 0.75,
      size.height * 0.07,
      size.width * 0.68,
      size.height * 0.1,
    );
    path.cubicTo(
      size.width * 0.68,
      size.height * 0.1,
      size.width * 0.68,
      size.height * 0.1,
      size.width * 0.68,
      size.height * 0.1,
    );
    path.cubicTo(
      size.width * 0.65,
      size.height * 0.11,
      size.width * 0.63,
      size.height * 0.11,
      size.width * 0.6,
      size.height * 0.1,
    );
    path.cubicTo(
      size.width * 0.51,
      size.height * 0.08,
      size.width * 0.43,
      size.height * 0.18,
      size.width * 0.47,
      size.height * 0.27,
    );
    path.cubicTo(
      size.width * 0.47,
      size.height * 0.27,
      size.width * 0.64,
      size.height * 0.61,
      size.width * 0.64,
      size.height * 0.61,
    );
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.72,
      size.width * 0.67,
      size.height * 0.85,
      size.width * 0.58,
      size.height * 0.92,
    );
    path.cubicTo(
      size.width * 0.58,
      size.height * 0.92,
      size.width * 0.47,
      size.height * 1.02,
      size.width * 0.47,
      size.height * 1.02,
    );
    return path;
  }

  Path _curve3(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.cubicTo(
      size.width * 0.96,
      size.height * 0.43,
      size.width * 0.42,
      size.height * 0.24,
      size.width * 0.42,
      size.height * 0.24,
    );
    path.cubicTo(
      size.width * 0.32,
      size.height / 5,
      size.width / 5,
      size.height * 0.23,
      size.width * 0.13,
      size.height * 0.32,
    );
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.41,
      size.width * 0.02,
      size.height * 0.54,
      size.width * 0.05,
      size.height * 0.66,
    );
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.66,
      size.width * 0.08,
      size.height * 0.82,
      size.width * 0.08,
      size.height * 0.82,
    );
    path.cubicTo(
      size.width * 0.11,
      size.height * 0.96,
      size.width * 0.23,
      size.height * 1.06,
      size.width * 0.36,
      size.height * 1.05,
    );
    path.cubicTo(
      size.width * 0.36,
      size.height * 1.05,
      size.width * 0.71,
      size.height * 1.02,
      size.width * 0.71,
      size.height * 1.02,
    );
    path.cubicTo(
      size.width * 0.78,
      size.height,
      size.width * 0.84,
      size.height * 0.93,
      size.width * 0.82,
      size.height * 0.85,
    );
    path.cubicTo(
      size.width * 0.82,
      size.height * 0.81,
      size.width * 0.82,
      size.height * 0.78,
      size.width * 0.84,
      size.height * 0.75,
    );
    path.cubicTo(
      size.width * 0.84,
      size.height * 0.75,
      size.width * 0.92,
      size.height * 0.59,
      size.width * 0.92,
      size.height * 0.59,
    );
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.53,
      size.width * 0.96,
      size.height * 0.47,
      size.width * 0.95,
      size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.4,
      size.width * 0.93,
      size.height * 0.29,
      size.width * 0.93,
      size.height * 0.29,
    );
    path.cubicTo(
      size.width * 0.89,
      size.height * 0.03,
      size.width * 0.59,
      -0.04,
      size.width * 0.46,
      size.height * 0.17,
    );
    path.cubicTo(
      size.width * 0.46,
      size.height * 0.17,
      size.width * 0.32,
      size.height * 0.39,
      size.width * 0.32,
      size.height * 0.39,
    );
    path.cubicTo(
      size.width * 0.23,
      size.height * 0.54,
      size.width * 0.03,
      size.height * 0.52,
      -0.04,
      size.height * 0.36,
    );
    return path;
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.seed != seed;
}
