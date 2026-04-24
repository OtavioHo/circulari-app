import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A scaffold body with a pinned collapsible header above a sliver list.
///
/// The header interpolates between [expandedHeight] and [collapsedHeight] as
/// the user scrolls. [headerBuilder] receives the current [shrinkOffset]
/// (0 = fully expanded, grows toward expandedHeight − collapsedHeight as the
/// user scrolls down) so callers can drive opacity, size, or layout transitions.
class CirculariCollapsibleBody extends StatelessWidget {
  final double expandedHeight;
  final double collapsedHeight;
  final Widget Function(BuildContext context, double shrinkOffset)
  headerBuilder;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const CirculariCollapsibleBody({
    super.key,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.headerBuilder,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final gradientEnd = expandedHeight / MediaQuery.sizeOf(context).height;

    return Stack(
      children: [
        Container(color: CirculariColorsTokens.deepMoss),
        SvgPicture.asset(
          'assets/images/background/in_app_background.svg',
          package: 'circulari_ui',
          fit: BoxFit.cover,
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
        SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: _CollapsingHeaderDelegate(
                  expandedHeight: expandedHeight,
                  collapsedHeight: collapsedHeight,
                  builder: headerBuilder,
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
                sliver: SliverPadding(
                  padding: padding ?? EdgeInsets.zero,
                  sliver: SliverPadding(
                    padding: const EdgeInsets.only(top: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(children),
                    ),
                  ),
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
