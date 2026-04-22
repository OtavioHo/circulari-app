import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      // bottomNavigationBar: NavigationBar(
      //   selectedIndex: _selectedIndex(context),
      //   onDestinationSelected: (i) => _onTap(context, i),
      //   destinations: const [
      //     NavigationDestination(icon: Icon(Icons.list), label: 'Lists'),
      //     NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      //   ],
      // ),
      bottomNavigationBar: CirculariBottomNavBar(
        items: const [
          CirculariNavItem(
            icon: Icons.home,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          CirculariNavItem(
            icon: Icons.add,
            activeIcon: Icons.add,
            label: 'Add',
          ),
          CirculariNavItem(
            icon: Icons.list_outlined,
            activeIcon: Icons.list,
            label: 'Lists',
          ),
          CirculariNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex(context),
        onTap: (index) => _onTap(context, index),
      ),
    );
  }

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/lists')) return 2;
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/add')) return 1;
    if (location.startsWith('/home')) return 0;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/add');
      case 2:
        context.go('/lists');
      case 3:
        context.go('/profile');
    }
  }
}
