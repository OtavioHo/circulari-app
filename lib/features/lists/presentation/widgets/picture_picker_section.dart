import 'package:flutter/material.dart';

import '../../domain/entities/list_picture.dart';
import '../utils/list_picture_map.dart';


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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Picture', style: Theme.of(context).textTheme.titleSmall),
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
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.onSurface
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
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 20,
                      )
                    else
                      const SizedBox.shrink(),
                    const SizedBox(height: 2),
                    Text(
                      picture.slug,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(blurRadius: 2, color: Colors.black54),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
