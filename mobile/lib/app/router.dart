import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/arbitration/presentation/screens/arbitration_case_screen.dart';
import '../features/arbitration/presentation/screens/arbitration_list_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_shell.dart';
import '../features/goals/presentation/screens/create_goal_screen.dart';
import '../features/goals/presentation/screens/goal_details_screen.dart';
import '../features/goals/presentation/screens/upload_evidence_screen.dart';

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
      GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const _PlaceholderScreen(title: 'Goals'),
      ),
      GoRoute(
        path: '/goals/create',
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
        path: '/profile',
        builder: (context, state) => const _PlaceholderScreen(title: 'Profile'),
      ),
      GoRoute(
        path: '/arbitration',
        builder: (context, state) => const ArbitrationListScreen(),
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

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen')),
    );
  }
}
