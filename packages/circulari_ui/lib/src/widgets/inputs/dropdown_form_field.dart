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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.circulariTheme.typography.body.large.regular.copyWith(
            color: CirculariColorsTokens.greyscale600,
          ),
        ),
        if (description != null) ...[
          SizedBox(height: context.circulariTheme.spacing.small),
          Text(
            description!,
            style: context.circulariTheme.typography.body.small.regular
                .copyWith(color: CirculariColorsTokens.greyscale500),
          ),
        ],
        SizedBox(height: context.circulariTheme.spacing.small),
        Theme(
          data: Theme.of(
            context,
          ).copyWith(canvasColor: CirculariColorsTokens.greyscale50),
          child: DropdownButtonFormField<T>(
            key: ValueKey(value),
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            hint: hintText != null ? Text(hintText!) : null,
            style: context.circulariTheme.typography.body.large.regular
                .copyWith(color: CirculariColorsTokens.greyscale800),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(18),
              suffixIcon: aiGenerated
                  ? const Icon(
                      Icons.auto_awesome,
                      color: CirculariColorsTokens.greyscale600,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: CirculariColorsTokens.greyscale900,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: CirculariColorsTokens.greyscale900,
                  width: 1.5,
                ),
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
