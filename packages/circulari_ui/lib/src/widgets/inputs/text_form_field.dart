import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CirculariTextFormField extends StatefulWidget {
  final String label;
  final String? description;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? prefixText;
  final List<TextInputFormatter>? inputFormatters;
  final int lines;
  final void Function()? onSuffixIconPressed;
  final void Function(String)? onFieldSubmitted;
  final bool aiGenerated;

  /// Renders the field with light borders/text so it contrasts on a dark
  /// (e.g. greyscale800) background.
  final bool onDark;

  const CirculariTextFormField({
    super.key,
    required this.label,
    this.hintText,
    this.description,
    this.controller,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.prefixText,
    this.inputFormatters,
    this.onSuffixIconPressed,
    this.textInputAction,
    this.onFieldSubmitted,
    this.lines = 1,
    this.aiGenerated = false,
    this.onDark = false,
  });

  @override
  State<CirculariTextFormField> createState() => _CirculariTextFormFieldState();
}

class _CirculariTextFormFieldState extends State<CirculariTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.onDark
        ? CirculariColorsTokens.greyscale50
        : CirculariColorsTokens.greyscale900;
    final textColor = widget.onDark
        ? CirculariColorsTokens.greyscale50
        : CirculariColorsTokens.greyscale800;
    final labelColor = widget.onDark
        ? CirculariColorsTokens.greyscale100
        : CirculariColorsTokens.greyscale600;
    final descriptionColor = widget.onDark
        ? CirculariColorsTokens.greyscale400
        : CirculariColorsTokens.greyscale500;
    final iconColor = widget.onDark
        ? CirculariColorsTokens.greyscale100
        : CirculariColorsTokens.greyscale600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: context.circulariTheme.typography.body.large.regular.copyWith(
            color: labelColor,
          ),
        ),
        if (widget.description != null) ...[
          SizedBox(height: context.circulariTheme.spacing.small),
          Text(
            widget.description!,
            style: context.circulariTheme.typography.body.small.regular
                .copyWith(color: descriptionColor),
          ),
        ],
        SizedBox(height: context.circulariTheme.spacing.small),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction,
          minLines: widget.lines,
          maxLines: widget.lines,
          style: context.circulariTheme.typography.body.large.medium.copyWith(
            color: textColor,
          ),
          cursorColor: borderColor,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixText: widget.prefixText,
            prefixStyle: context.circulariTheme.typography.body.large.medium
                .copyWith(color: textColor),
            contentPadding: const EdgeInsets.all(18),
            suffixIcon: widget.aiGenerated
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: iconColor),
                      for (int i = 0; i < widget.lines - 1; i++)
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.transparent,
                        ),
                    ],
                  )
                : null,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: iconColor, size: 20)
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            labelStyle: context.circulariTheme.typography.body.small.regular
                .copyWith(color: labelColor),
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
      ],
    );
  }
}
