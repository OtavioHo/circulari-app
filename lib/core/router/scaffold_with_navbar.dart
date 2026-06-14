import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Tabs are entered with context.go, so a non-home tab is the only entry on
    // the stack — the system back button would otherwise close the app. Send it
    // to home first; on home, allow the default pop (exit).
    final isHome = GoRouterState.of(context).matchedLocation.startsWith('/home');
    return PopScope(
      canPop: isHome,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        context.go('/home');
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Align(
            alignment: Alignment.bottomCenter,
            child: CirculariBottomNavBar(
              items: const [
                CirculariNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                ),
                CirculariNavItem(
                  icon: Icons.add_circle_outline,
                  activeIcon: Icons.add_circle,
                  label: 'Add',
                ),
                CirculariNavItem(
                  icon: Icons.list_alt_outlined,
                  activeIcon: Icons.list_alt,
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
          ),
        ],
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
        break;
      case 1:
        context.go('/add');
      case 2:
        context.go('/lists');
      case 3:
        context.go('/profile');
    }
  }
}
