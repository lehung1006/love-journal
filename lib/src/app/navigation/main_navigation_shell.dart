import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/journal/presentation/components/journal_components.dart';
import '../router/app_routes.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    required this.navigationShell,
    required this.currentPath,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final showTabBar = _tabRootPaths.contains(currentPath);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: navigationShell),
          if (showTabBar)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.paddingOf(context).bottom,
              child: AppBottomTabBar(
                currentIndex: navigationShell.currentIndex,
                onChanged: _goBranch,
              ),
            ),
        ],
      ),
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  static const _tabRootPaths = {
    AppRoutePaths.home,
    AppRoutePaths.timeline,
    AppRoutePaths.map,
    AppRoutePaths.letters,
  };
}
