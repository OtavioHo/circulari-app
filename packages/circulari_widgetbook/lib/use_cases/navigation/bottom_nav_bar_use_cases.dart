import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

final _items = const [
  CirculariNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
  ),
  CirculariNavItem(
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    label: 'Explore',
  ),
  CirculariNavItem(
    icon: Icons.bookmark_outline,
    activeIcon: Icons.bookmark,
    label: 'Saved',
  ),
  CirculariNavItem(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
  ),
];

final bottomNavBarUseCases = [
  WidgetbookUseCase(
    name: 'Default',
    builder: (context) {
      final activeIndex = context.knobs.object.dropdown(
        label: 'Active index',
        options: [0, 1, 2, 3],
        labelBuilder: (i) => _items[i].label,
      );

      return Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: CirculariBottomNavBar(
          items: _items,
          currentIndex: activeIndex,
          onTap: (_) {},
        ),
      );
    },
  ),
];
