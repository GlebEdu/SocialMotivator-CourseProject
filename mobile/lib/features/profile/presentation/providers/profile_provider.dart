import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/domain/entities/goal_status.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../domain/entities/user.dart';

final userProfileProvider = FutureProvider.family<User?, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).getUserProfile(userId);
});

final userGoalsProvider = FutureProvider.family<List<Goal>, String>((
  ref,
  userId,
) async {
  final goals = await ref.watch(goalsFeedProvider.future);
  final userGoals = goals
      .where((goal) => goal.userId == userId)
      .toList(growable: false);

  userGoals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return userGoals;
});

final userGoalSummaryProvider = FutureProvider.family<UserGoalSummary?, String>(
  (ref, userId) async {
    final user = await ref.watch(userProfileProvider(userId).future);
    if (user == null) {
      return null;
    }

    final goals = await ref.watch(userGoalsProvider(userId).future);
    return UserGoalSummary(user: user, goals: goals);
  },
);

class UserGoalSummary {
  const UserGoalSummary({required this.user, required this.goals});

  final User user;
  final List<Goal> goals;

  int get totalGoals => goals.length;

  int get completedGoals =>
      goals.where((goal) => goal.status == GoalStatus.completed).length;

  int get activeGoals =>
      goals.where((goal) => goal.status == GoalStatus.active).length;

  int get resolvedGoals => goals
      .where(
        (goal) =>
            goal.status == GoalStatus.completed ||
            goal.status == GoalStatus.failed,
      )
      .length;

  double get completionRate =>
      resolvedGoals == 0 ? 0 : completedGoals / resolvedGoals;

  String get completionRateLabel => resolvedGoals == 0
      ? 'No results yet'
      : '${(completionRate * 100).round()}%';
}
