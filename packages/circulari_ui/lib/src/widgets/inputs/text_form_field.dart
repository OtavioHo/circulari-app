import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

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
  final int lines;
  final void Function()? onSuffixIconPressed;
  final void Function(String)? onFieldSubmitted;
  final bool aiGenerated;

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
    this.onSuffixIconPressed,
    this.textInputAction,
    this.onFieldSubmitted,
    this.lines = 1,
    this.aiGenerated = false,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: context.circulariTheme.typography.body.large.regular.copyWith(
            color: CirculariColorsTokens.greyscale600,
          ),
        ),
        if (widget.description != null) ...[
          SizedBox(height: context.circulariTheme.spacing.small),
          Text(
            widget.description!,
            style: context.circulariTheme.typography.body.small.regular
                .copyWith(color: CirculariColorsTokens.greyscale500),
          ),
        ],
        SizedBox(height: context.circulariTheme.spacing.small),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          minLines: widget.lines,
          maxLines: widget.lines,
          style: context.circulariTheme.typography.body.large.medium.copyWith(
            color: CirculariColorsTokens.greyscale800,
          ),
          cursorColor: CirculariColorsTokens.greyscale900,
          decoration: InputDecoration(
            hintText: widget.hintText,
            contentPadding: const EdgeInsets.all(18),
            suffixIcon: widget.aiGenerated
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: CirculariColorsTokens.greyscale600,
                      ),
                      for (int i = 0; i < widget.lines - 1; i++)
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.transparent,
                        ),
                    ],
                  )
                : null,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: CirculariColorsTokens.greyscale600,
                    size: 20,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            labelStyle: context.circulariTheme.typography.body.small.regular
                .copyWith(color: CirculariColorsTokens.greyscale600),
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
      ],
    );
  }
}
