import 'package:flutter/material.dart';
import 'package:circulari_ui/src/extensions/build_context_extension.dart';
import 'package:circulari_ui/src/theme/circulari_colors.dart';

class CirculariItemListTile extends StatelessWidget {
  final String name;
  final int quantity;
  final double price;
  final VoidCallback? onTap;
  final String listName;
  final Color listColor;
  final String categoryName;

  const CirculariItemListTile({
    super.key,
    required this.name,
    required this.price,
    required this.listName,
    required this.listColor,
    required this.categoryName,
    this.quantity = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;

    return Card(
      color: CirculariColorsTokens.greyscale100,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: listColor,
                child: Icon(
                  Icons.ac_unit_outlined,
                  color: CirculariColorsTokens.greyscale900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: typography.body.medium.semibold.copyWith(
                        color: CirculariColorsTokens.greyscale800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      categoryName,
                      style: typography.body.small.regular.copyWith(
                        color: CirculariColorsTokens.greyscale400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    listName,
                    style: typography.body.small.regular.copyWith(
                      color: CirculariColorsTokens.greyscale400,
                    ),
                  ),
                  Text(
                    'R\$ ${price.toStringAsFixed(2)}',
                    style: typography.body.medium.semibold.copyWith(
                      color: CirculariColorsTokens.greyscale800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
