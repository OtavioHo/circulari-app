import 'package:flutter/material.dart';

import '../../domain/entities/list_icon.dart';
import '../utils/list_icon_map.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Icon', style: Theme.of(context).textTheme.titleSmall),
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
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    iconForSlug(icon.slug),
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
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
