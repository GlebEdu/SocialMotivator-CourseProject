import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({required this.currentTab, required this.child, super.key});

  final HomeTabItem currentTab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentIndex = homeTabs.indexWhere((tab) => tab.item == currentTab);
    final selectedTab = homeTabs[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(selectedTab.title)),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => context.go(homeTabs[index].route),
        destinations: homeTabs
            .map(
              (tab) =>
                  NavigationDestination(icon: Icon(tab.icon), label: tab.label),
            )
            .toList(growable: false),
      ),
    );
  }
}

const homeTabs = <HomeTab>[
  HomeTab(
    item: HomeTabItem.myGoals,
    route: '/my-goals',
    label: 'My Goals',
    icon: Icons.flag_outlined,
    title: 'My Goals',
  ),
  HomeTab(
    item: HomeTabItem.discover,
    route: '/discover',
    label: 'Discover',
    icon: Icons.explore_outlined,
    title: 'Discover',
  ),
  HomeTab(
    item: HomeTabItem.arbitration,
    route: '/arbitration',
    label: 'Arbitration',
    icon: Icons.balance_outlined,
    title: 'Arbitration',
  ),
  HomeTab(
    item: HomeTabItem.profile,
    route: '/profile',
    label: 'Profile',
    icon: Icons.person_outline,
    title: 'Profile',
  ),
];

class HomeTab {
  const HomeTab({
    required this.item,
    required this.route,
    required this.label,
    required this.icon,
    required this.title,
  });

  final HomeTabItem item;
  final String route;
  final String label;
  final IconData icon;
  final String title;
}

enum HomeTabItem { myGoals, discover, arbitration, profile }
