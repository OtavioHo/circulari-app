import 'package:flutter/material.dart';
import 'package:circulari_ui/circulari_ui.dart';

class CirculariNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const CirculariNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class CirculariBottomNavBar extends StatelessWidget {
  final List<CirculariNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CirculariBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: CirculariColorsTokens.greyscale700,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: CirculariColorsTokens.greyscale900.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: currentIndex * itemWidth + 8,
                    width: itemWidth - 16,
                    top: 10,
                    bottom: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: CirculariColorsTokens.freshCore,
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isActive = index == currentIndex;

                      return SizedBox(
                        width: itemWidth,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onTap(index),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isActive ? item.activeIcon : item.icon,
                                  size: 24,
                                  color: isActive
                                      ? CirculariColorsTokens.greyscale700
                                      : CirculariColorsTokens.greyscale50,
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: isActive
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(width: 6),
                                            Text(
                                              item.label,
                                              style: theme.typography.body.xSmall.regular.copyWith(
                                                color: CirculariColorsTokens.greyscale700,
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
