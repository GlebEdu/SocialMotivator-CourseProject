import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../data/models/profile_summary_model.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/domain/entities/goal_status.dart';
import '../../domain/entities/user.dart';

final userProfileSummaryProvider =
    FutureProvider.family<ProfileSummaryModel?, String>((ref, userId) {
      return ref.watch(profileReadRepositoryProvider).getProfileSummary(userId);
    });

final userProfileProvider = FutureProvider.family<User?, String>((ref, userId) {
  return ref
      .watch(userProfileSummaryProvider(userId).future)
      .then((summary) => summary?.user);
});

final userGoalsProvider = FutureProvider.family<List<Goal>, String>((
  ref,
  userId,
) async {
  final summary = await ref.watch(userProfileSummaryProvider(userId).future);
  return summary?.goals ?? const <Goal>[];
});

final userGoalSummaryProvider = FutureProvider.family<UserGoalSummary?, String>(
  (ref, userId) async {
    final summary = await ref.watch(userProfileSummaryProvider(userId).future);
    if (summary == null) {
      return null;
    }

    return UserGoalSummary(
      user: summary.user,
      goals: summary.goals,
      totalGoalsOverride: summary.totalGoals,
      completedGoalsOverride: summary.completedGoals,
      activeGoalsOverride: summary.activeGoals,
      resolvedGoalsOverride: summary.resolvedGoals,
      completionRateOverride: summary.completionRate,
      completionRateLabelOverride: summary.completionRateLabel,
    );
  },
);

class UserGoalSummary {
  const UserGoalSummary({
    required this.user,
    required this.goals,
    this.totalGoalsOverride,
    this.completedGoalsOverride,
    this.activeGoalsOverride,
    this.resolvedGoalsOverride,
    this.completionRateOverride,
    this.completionRateLabelOverride,
  });

  final User user;
  final List<Goal> goals;
  final int? totalGoalsOverride;
  final int? completedGoalsOverride;
  final int? activeGoalsOverride;
  final int? resolvedGoalsOverride;
  final double? completionRateOverride;
  final String? completionRateLabelOverride;

  int get totalGoals => totalGoalsOverride ?? goals.length;

  int get completedGoals =>
      completedGoalsOverride ??
      goals.where((goal) => goal.status == GoalStatus.completed).length;

  int get activeGoals =>
      activeGoalsOverride ??
      goals.where((goal) => goal.status == GoalStatus.active).length;

  int get resolvedGoals =>
      resolvedGoalsOverride ??
      goals
          .where(
            (goal) =>
                goal.status == GoalStatus.completed ||
                goal.status == GoalStatus.failed,
          )
          .length;

  double get completionRate =>
      completionRateOverride ??
      (resolvedGoals == 0 ? 0 : completedGoals / resolvedGoals);

  String get completionRateLabel =>
      completionRateLabelOverride ??
      (resolvedGoals == 0
          ? 'No results yet'
          : '${(completionRate * 100).round()}%');
}
