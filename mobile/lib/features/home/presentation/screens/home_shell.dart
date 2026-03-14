import 'package:flutter/material.dart';

import '../../../arbitration/presentation/screens/arbitration_list_screen.dart';
import '../../../goals/presentation/screens/goals_feed_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const _tabs = <_HomeTab>[
    _HomeTab(
      label: 'Goals',
      icon: Icons.flag_outlined,
      title: 'Goals',
      body: GoalsFeedScreen(),
    ),
    _HomeTab(
      label: 'Arbitration',
      icon: Icons.balance_outlined,
      title: 'Arbitration',
      body: ArbitrationListScreen(),
    ),
    _HomeTab(
      label: 'Profile',
      icon: Icons.person_outline,
      title: 'Profile',
      body: ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedTab = _tabs[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(selectedTab.title)),
      body: selectedTab.body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _tabs
            .map(
              (tab) =>
                  NavigationDestination(icon: Icon(tab.icon), label: tab.label),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _HomeTab {
  const _HomeTab({
    required this.label,
    required this.icon,
    required this.title,
    required this.body,
  });

  final String label;
  final IconData icon;
  final String title;
  final Widget body;
}
