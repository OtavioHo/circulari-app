import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A scaffold body with a pinned collapsible header above a sliver list.
///
/// The header interpolates between [expandedHeight] and [collapsedHeight] as
/// the user scrolls. [headerBuilder] receives the current [shrinkOffset]
/// (0 = fully expanded, grows toward expandedHeight − collapsedHeight as the
/// user scrolls down) so callers can drive opacity, size, or layout transitions.
///
/// [backgroundBuilder] works the same way but its output is rendered in the
/// outer Stack, behind the scroll view. This lets painted content (e.g. a wave
/// decoration) extend visually below the header and appear behind the body card
/// instead of being clipped by the sliver boundary.
class CirculariCollapsibleBody extends StatefulWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(BuildContext context, double shrinkOffset)
  headerBuilder;
  final Widget Function(BuildContext context, double shrinkOffset)?
  backgroundBuilder;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final Widget? appBarTitle;

  const CirculariCollapsibleBody({
    super.key,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.headerBuilder,
    required this.children,
    this.backgroundBuilder,
    this.padding,
    this.appBarTitle,
  });

  @override
  State<CirculariCollapsibleBody> createState() =>
      _CirculariCollapsibleBodyState();
}

class _CirculariCollapsibleBodyState extends State<CirculariCollapsibleBody> {
  final _scrollController = ScrollController();

  // The transparent SliverAppBar above the collapsing header consumes this
  // much scroll offset before the header starts shrinking.
  static const _appBarHeight = 56.0;

  double get _shrinkOffset {
    if (!_scrollController.hasClients) return 0.0;
    return (_scrollController.offset - _appBarHeight)
        .clamp(0.0, widget.expandedHeight - widget.collapsedHeight);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradientEnd =
        widget.expandedHeight / MediaQuery.sizeOf(context).height;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        Container(color: CirculariColorsTokens.deepMoss),
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/images/background/in_app_background.svg',
            package: 'circulari_ui',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
              stops: [0, gradientEnd],
            ),
          ),
        ),
        if (widget.backgroundBuilder != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // Extend 24 px past the header so the background bleeds behind
            // the rounded top edge of the body card.
            height: topPadding + _appBarHeight + widget.expandedHeight + 24,
            child: ListenableBuilder(
              listenable: _scrollController,
              builder: (context, _) =>
                  widget.backgroundBuilder!(context, _shrinkOffset),
            ),
          ),
        SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                flexibleSpace: const SizedBox(),
                expandedHeight: 56,
                collapsedHeight: 56,
                title: widget.appBarTitle,
                actions: [
                  IconButton(
                    icon: CircleAvatar(
                      backgroundColor: CirculariColorsTokens.freshCore,
                      child: const Icon(
                        Icons.person,
                        color: CirculariColorsTokens.greyscale900,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              SliverPersistentHeader(
                delegate: _CollapsingHeaderDelegate(
                  expandedHeight: widget.expandedHeight,
                  collapsedHeight: widget.collapsedHeight,
                  builder: widget.headerBuilder,
                ),
              ),
              DecoratedSliver(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                sliver: SliverMainAxisGroup(
                  slivers: [
                    SliverPadding(
                      padding: widget.padding ?? EdgeInsets.zero,
                      sliver: SliverPadding(
                        padding: const EdgeInsets.only(top: 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(widget.children),
                        ),
                      ),
                    ),
                    const SliverFillRemaining(hasScrollBody: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(BuildContext context, double shrinkOffset) builder;

  const _CollapsingHeaderDelegate({
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.builder,
  });

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => collapsedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return builder(context, shrinkOffset);
  }

  @override
  bool shouldRebuild(_CollapsingHeaderDelegate oldDelegate) =>
      oldDelegate.expandedHeight != expandedHeight ||
      oldDelegate.collapsedHeight != collapsedHeight ||
      oldDelegate.builder != builder;
}
