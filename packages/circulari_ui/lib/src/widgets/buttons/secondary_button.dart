import 'package:flutter/material.dart';

class CirculariSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const CirculariSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
