import 'package:flutter/material.dart';
import 'list_card.dart';

class CirculariListsCarousel extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EdgeInsetsGeometry padding;

  const CirculariListsCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CirculariListCard.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
