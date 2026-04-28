import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/list_color.dart';

class ColorPickerSection extends StatelessWidget {
  final List<ListColor> colors;
  final ListColor selected;
  final ValueChanged<ListColor> onSelect;

  const ColorPickerSection({
    super.key,
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cor',
          style: context.circulariTheme.typography.body.large.regular.copyWith(
            color: CirculariColorsTokens.greyscale600,
          ),
        ),
        Text(
          'Escolha uma cor para identificar sua lista visualmente.',
          style: context.circulariTheme.typography.body.small.regular.copyWith(
            color: CirculariColorsTokens.greyscale500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final hex = color.hexCode.replaceFirst('#', '');
            final value = int.tryParse('FF$hex', radix: 16) ?? 0xFF9E9E9E;
            final dartColor = Color(value);
            final isSelected = color.hexCode == selected.hexCode;
            return GestureDetector(
              onTap: () => onSelect(color),
              child: Tooltip(
                message: color.name,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: dartColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: dartColor.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color:
                              ThemeData.estimateBrightnessForColor(dartColor) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
