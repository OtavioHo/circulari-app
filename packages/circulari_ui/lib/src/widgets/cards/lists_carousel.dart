import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.circulariTheme.spacing.medium,
          ),
          child: Text(
            "Minhas Listas",
            style: context.circulariTheme.typography.body.xLarge.bold.copyWith(
              color: CirculariColorsTokens.greyscale800,
            ),
          ),
        ),
        SizedBox(height: context.circulariTheme.spacing.medium),
        SizedBox(
          height: CirculariListCard.height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: padding,
            itemCount: itemCount,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}
