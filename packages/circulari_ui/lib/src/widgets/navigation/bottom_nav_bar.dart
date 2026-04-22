import 'package:flutter/material.dart';
import 'package:circulari_ui/circulari_ui.dart';
import 'package:google_fonts/google_fonts.dart';

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
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final partitions = constraints.maxWidth / ((items.length *2)+1);
              final itemWidth = partitions * 2;
              final activeItemWidth = partitions * 3;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: currentIndex * itemWidth + 12,
                    width: activeItemWidth - 24,
                    top: 14,
                    bottom: 14,
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
                        width: isActive ? activeItemWidth : itemWidth,
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
                                              style: GoogleFonts.figtree(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
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
