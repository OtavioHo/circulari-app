import 'package:flutter/material.dart';

class CirculariItemCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CirculariItemCard({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
