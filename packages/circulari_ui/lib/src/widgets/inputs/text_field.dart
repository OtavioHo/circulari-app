import 'package:flutter/material.dart';

class CirculariTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const CirculariTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
