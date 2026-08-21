import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/common/floating_bottom_nav.dart';

/// Main application shell that hosts the persistent [FloatingBottomNav]
/// and renders the active branch from [StatefulNavigationShell].
class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

  /// The navigation shell provided by [StatefulShellRoute.indexedStack]
  final StatefulNavigationShell navigationShell;

  void _onTabSelected(NavTab tab) {
    navigationShell.goBranch(
      tab.index,
      // If tapping the currently active tab, reset branch to its initial location
      initialLocation: tab.index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = navigationShell.currentIndex.clamp(0, NavTab.values.length - 1);
    final currentTab = NavTab.values[activeIndex];

    return Scaffold(
      body: Stack(
        children: [
          // Active branch content
          navigationShell,

          // Persistent Floating Bottom Navigation Dock
          FloatingBottomNav(
            currentTab: currentTab,
            onTabSelected: _onTabSelected,
          ),
        ],
      ),
    );
  }
}
