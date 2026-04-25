import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/widgets/brand_backdrop.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({required this.currentTab, required this.child, super.key});

  final HomeTabItem currentTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentIndex = homeTabs.indexWhere((tab) => tab.item == currentTab);

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: HabitBetTheme.surface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: HabitBetTheme.line),
              boxShadow: HabitBetTheme.softShadow(),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) =>
                    context.go(homeTabs[index].route),
                destinations: homeTabs
                    .map(
                      (tab) => NavigationDestination(
                        icon: Icon(tab.icon),
                        label: _labelForTab(tab.item),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const homeTabs = <HomeTab>[
  HomeTab(
    item: HomeTabItem.myGoals,
    route: '/my-goals',
    icon: Icons.flag_outlined,
  ),
  HomeTab(
    item: HomeTabItem.discover,
    route: '/discover',
    icon: Icons.explore_outlined,
  ),
  HomeTab(
    item: HomeTabItem.arbitration,
    route: '/arbitration',
    icon: Icons.balance_outlined,
  ),
  HomeTab(
    item: HomeTabItem.profile,
    route: '/profile',
    icon: Icons.person_outline,
  ),
];

class HomeTab {
  const HomeTab({required this.item, required this.route, required this.icon});

  final HomeTabItem item;
  final String route;
  final IconData icon;
}

enum HomeTabItem { myGoals, discover, arbitration, profile }

String _labelForTab(HomeTabItem item) {
  return switch (item) {
    HomeTabItem.myGoals => 'Мои цели',
    HomeTabItem.discover => 'Обзор',
    HomeTabItem.arbitration => 'Арбитраж',
    HomeTabItem.profile => 'Профиль',
  };
}
