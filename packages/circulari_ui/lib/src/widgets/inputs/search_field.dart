import 'package:flutter/material.dart';

class CirculariSearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const CirculariSearchField({
    super.key,
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
        hintText: hint ?? 'Search',
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
