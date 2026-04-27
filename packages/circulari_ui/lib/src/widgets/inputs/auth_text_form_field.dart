import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

class CirculariAuthTextFormField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool obscureText;
  final bool isAuth;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final void Function()? onSuffixIconPressed;
  final void Function(String)? onFieldSubmitted;

  const CirculariAuthTextFormField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.isAuth = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.onSuffixIconPressed,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<CirculariAuthTextFormField> createState() =>
      _CirculariAuthTextFormFieldState();
}

class _CirculariAuthTextFormFieldState
    extends State<CirculariAuthTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      style: context.circulariTheme.typography.body.small.regular.copyWith(
        color: CirculariColorsTokens.greyscale100,
      ),
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: widget.label,
        hintText: widget.hintText,
        contentPadding: const EdgeInsets.all(18),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: CirculariColorsTokens.greyscale600,
                size: 20,
              )
            : null,
        suffixIcon: widget.isAuth
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: CirculariColorsTokens.greyscale600,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: context.circulariTheme.typography.body.small.regular
            .copyWith(color: CirculariColorsTokens.greyscale600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: CirculariColorsTokens.greyscale500,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: CirculariColorsTokens.greyscale100,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: CirculariColorsTokens.solarPulse),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: CirculariColorsTokens.solarPulse),
        ),
      ),
    );
  }
}
