import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

import 'package:circulari/features/lists/domain/entities/list_picture.dart';
import 'package:circulari/features/lists/presentation/utils/list_picture_map.dart';

class PicturePickerSection extends StatelessWidget {
  final List<ListPicture> pictures;
  final ListPicture selected;
  final ValueChanged<ListPicture> onSelect;

  const PicturePickerSection({
    super.key,
    required this.pictures,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagem',
          style: context.circulariTheme.typography.body.large.regular.copyWith(
            color: CirculariColorsTokens.greyscale600,
          ),
        ),
        Text(
          'Escolha uma imagem para identificar sua lista visualmente.',
          style: context.circulariTheme.typography.body.small.regular.copyWith(
            color: CirculariColorsTokens.greyscale500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: pictures.map((picture) {
            final bgColor = colorForSlug(picture.slug);
            final isSelected = picture.slug == selected.slug;
            final assetPath = assetForSlug(picture.slug);
            return GestureDetector(
              onTap: () => onSelect(picture),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? CirculariColorsTokens.freshCore
                        : Colors.transparent,
                    width: 2.5,
                  ),
                  image: assetPath != null
                      ? DecorationImage(
                          image: AssetImage(assetPath),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: bgColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: CirculariColorsTokens.freshCore,
                        size: 20,
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
