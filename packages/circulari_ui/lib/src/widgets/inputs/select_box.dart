import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

class CirculariSelectOption<T> {
  final String label;
  final T value;

  const CirculariSelectOption({required this.label, required this.value});
}

class CirculariSelectBox<T> extends StatelessWidget {
  final List<CirculariSelectOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  const CirculariSelectBox({
    super.key,
    required this.options,
    required this.onSelected,
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map((option) => _SelectTile<T>(
                option: option,
                isSelected: option.value == selected,
                onTap: () => onSelected(option.value),
              ))
          .toList(),
    );
  }
}

class _SelectTile<T> extends StatelessWidget {
  final CirculariSelectOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.circulariTheme.spacing;
    final typography = context.circulariTheme.typography;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: spacing.small),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.large,
          vertical: spacing.large,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? CirculariColorsTokens.forestVault900
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(color: CirculariColorsTokens.greyscale200),
        ),
        child: Row(
          children: [
            _SelectIndicator(isSelected: isSelected),
            SizedBox(width: spacing.medium),
            Text(
              option.label,
              style: typography.body.large.regular.copyWith(
                color: isSelected
                    ? Colors.white
                    : CirculariColorsTokens.greyscale600,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: CirculariColorsTokens.freshCore500,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      );
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: CirculariColorsTokens.greyscale300, width: 2),
      ),
    );
  }
}
