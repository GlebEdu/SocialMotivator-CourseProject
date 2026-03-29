import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/arbitration/presentation/screens/arbitration_case_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/arbitration/presentation/screens/arbitration_list_screen.dart';
import '../features/home/presentation/screens/home_shell.dart';
import '../features/goals/presentation/screens/create_goal_screen.dart';
import '../features/goals/presentation/screens/discover_screen.dart';
import '../features/goals/presentation/screens/goal_details_screen.dart';
import '../features/goals/presentation/screens/my_goals_screen.dart';
import '../features/goals/presentation/screens/upload_evidence_screen.dart';
import '../features/profile/presentation/screens/author_profile_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', redirect: (context, state) => '/login'),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/home', redirect: (context, state) => '/my-goals'),
      ShellRoute(
        builder: (context, state, child) => HomeShell(
          currentTab: _tabForLocation(state.uri.path),
          child: child,
        ),
        routes: <RouteBase>[
          GoRoute(
            path: '/my-goals',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MyGoalsScreen()),
          ),
          GoRoute(
            path: '/discover',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DiscoverScreen()),
          ),
          GoRoute(
            path: '/arbitration',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ArbitrationListScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/my-goals/create',
        builder: (context, state) => const CreateGoalScreen(),
      ),
      GoRoute(
        path: '/goals/:id/evidence',
        builder: (context, state) {
          final goalId = state.pathParameters['id']!;
          return UploadEvidenceScreen(goalId: goalId);
        },
      ),
      GoRoute(
        path: '/goals/:id',
        builder: (context, state) {
          final goalId = state.pathParameters['id']!;
          return GoalDetailsScreen(goalId: goalId);
        },
      ),
      GoRoute(
        path: '/users/:id',
        builder: (context, state) {
          final userId = state.pathParameters['id']!;
          return AuthorProfileScreen(userId: userId);
        },
      ),
      GoRoute(
        path: '/arbitration/:id',
        builder: (context, state) {
          final caseId = state.pathParameters['id']!;
          return ArbitrationCaseScreen(caseId: caseId);
        },
      ),
    ],
  );
});

HomeTabItem _tabForLocation(String location) {
  for (final tab in homeTabs) {
    if (location == tab.route || location.startsWith('${tab.route}/')) {
      return tab.item;
    }
  }

  return HomeTabItem.myGoals;
}
