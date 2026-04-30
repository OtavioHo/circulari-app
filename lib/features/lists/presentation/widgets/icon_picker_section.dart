import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

import 'package:circulari/features/lists/domain/entities/list_icon.dart';
import 'package:circulari/features/lists/presentation/utils/list_icon_map.dart';

class IconPickerSection extends StatelessWidget {
  final List<ListIcon> icons;
  final ListIcon selected;
  final ValueChanged<ListIcon> onSelect;

  const IconPickerSection({
    super.key,
    required this.icons,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icone',
          style: context.circulariTheme.typography.body.large.regular.copyWith(
            color: CirculariColorsTokens.greyscale600,
          ),
        ),
        Text(
          'Escolha um ícone para identificar sua lista visualmente.',
          style: context.circulariTheme.typography.body.small.regular.copyWith(
            color: CirculariColorsTokens.greyscale500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((icon) {
            final isSelected = icon.slug == selected.slug;
            return Tooltip(
              message: icon.name,
              child: GestureDetector(
                onTap: () => onSelect(icon),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CirculariColorsTokens.freshCore
                        : CirculariColorsTokens.greyscale100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? CirculariColorsTokens.freshCore
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    iconForSlug(icon.slug),
                    color: isSelected
                        ? CirculariColorsTokens.freshCore
                        : CirculariColorsTokens.greyscale500,
                    size: 24,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
