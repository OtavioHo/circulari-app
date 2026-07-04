import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

class CirculariDropdownFormField<T> extends StatelessWidget {
  final String label;
  final String? description;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool aiGenerated;

  /// Renders the field with light borders/text so it contrasts on a dark
  /// (e.g. greyscale800) background.
  final bool onDark;

  const CirculariDropdownFormField({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.description,
    this.hintText,
    this.value,
    this.validator,
    this.aiGenerated = false,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = onDark
        ? CirculariColorsTokens.greyscale50
        : CirculariColorsTokens.greyscale900;
    final textColor = onDark
        ? CirculariColorsTokens.greyscale50
        : CirculariColorsTokens.greyscale800;
    final labelColor = onDark
        ? CirculariColorsTokens.greyscale100
        : CirculariColorsTokens.greyscale600;
    final descriptionColor = onDark
        ? CirculariColorsTokens.greyscale400
        : CirculariColorsTokens.greyscale500;
    final menuColor = onDark
        ? CirculariColorsTokens.greyscale800
        : CirculariColorsTokens.greyscale50;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.circulariTheme.typography.body.large.regular.copyWith(
            color: labelColor,
          ),
        ),
        if (description != null) ...[
          SizedBox(height: context.circulariTheme.spacing.small),
          Text(
            description!,
            style: context.circulariTheme.typography.body.small.regular
                .copyWith(color: descriptionColor),
          ),
        ],
        SizedBox(height: context.circulariTheme.spacing.small),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: menuColor),
          child: DropdownButtonFormField<T>(
            key: ValueKey(value),
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            iconEnabledColor: textColor,
            hint: hintText != null ? Text(hintText!) : null,
            style: context.circulariTheme.typography.body.large.regular
                .copyWith(color: textColor),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(18),
              suffixIcon: aiGenerated
                  ? Icon(
                      Icons.auto_awesome,
                      color: onDark
                          ? CirculariColorsTokens.greyscale100
                          : CirculariColorsTokens.greyscale600,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: CirculariColorsTokens.solarPulse,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: CirculariColorsTokens.solarPulse,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
