import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bets/domain/entities/bet.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../domain/entities/create_goal_input.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_status.dart';

final goalsFeedProvider = FutureProvider<List<Goal>>((ref) async {
  await ref.read(goalEngineProvider).syncExpiredGoalsForArbitration();
  return ref.watch(goalsRepositoryProvider).getGoalsFeed();
});

final goalEvidenceProvider = FutureProvider.family<Evidence?, String>((
  ref,
  goalId,
) {
  return ref.watch(goalsRepositoryProvider).getLatestEvidenceForGoal(goalId);
});

final myGoalsProvider = FutureProvider<List<Goal>>((ref) async {
  final currentUser = await ref.watch(authControllerProvider.future);
  if (currentUser == null) {
    return const <Goal>[];
  }

  final goals = await ref.watch(goalsFeedProvider.future);
  return goals
      .where((goal) => goal.userId == currentUser.id)
      .toList(growable: false);
});

final currentUserBetsProvider = FutureProvider<List<Bet>>((ref) async {
  final currentUser = await ref.watch(authControllerProvider.future);
  if (currentUser == null) {
    return const <Bet>[];
  }

  return ref.watch(betsRepositoryProvider).getBetsForUser(currentUser.id);
});

final currentUserPredictedGoalIdsProvider = FutureProvider<Set<String>>((
  ref,
) async {
  final bets = await ref.watch(currentUserBetsProvider.future);
  return bets.map((bet) => bet.goalId).toSet();
});

final discoverGoalsProvider =
    FutureProvider.family<List<DiscoverGoalListItem>, DiscoverGoalsFilter>((
      ref,
      filter,
    ) async {
      final currentUser = await ref.watch(authControllerProvider.future);
      final goals = await ref.watch(goalsFeedProvider.future);
      final predictedGoalIds = await ref.watch(
        currentUserPredictedGoalIdsProvider.future,
      );

      final discoverGoals = goals
          .where((goal) => goal.userId != currentUser?.id)
          .where((goal) => goal.status != GoalStatus.completed)
          .map(
            (goal) => DiscoverGoalListItem(
              goal: goal,
              hasPrediction: predictedGoalIds.contains(goal.id),
            ),
          )
          .where((item) => filter.matches(item))
          .toList(growable: false);

      return discoverGoals;
    });

final goalDetailsProvider = FutureProvider.family<Goal?, String>((
  ref,
  goalId,
) async {
  await ref.read(goalEngineProvider).syncExpiredGoalsForArbitration();
  return ref.watch(goalsRepositoryProvider).getGoalById(goalId);
});

final createGoalControllerProvider =
    AsyncNotifierProvider<CreateGoalController, void>(CreateGoalController.new);

final submitEvidenceControllerProvider =
    AsyncNotifierProvider<SubmitEvidenceController, void>(
      SubmitEvidenceController.new,
    );

class CreateGoalController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Goal> createGoal(CreateGoalInput input) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(goalEngineProvider).createGoal(input),
    );
    state = result.whenData((_) {});

    final goal = result.requireValue;
    await ref.read(authControllerProvider.notifier).refreshCurrentUser();
    ref.invalidate(goalsFeedProvider);
    ref.invalidate(goalDetailsProvider(goal.id));

    return goal;
  }
}

class SubmitEvidenceController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Evidence> submitEvidence(Evidence evidence) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(goalEngineProvider).submitEvidence(evidence),
    );
    state = result.whenData((_) {});

    final savedEvidence = result.requireValue;
    ref.invalidate(goalsFeedProvider);
    ref.invalidate(goalDetailsProvider(savedEvidence.goalId));

    return savedEvidence;
  }
}

enum DiscoverGoalsFilter { all, predicted, newOnly }

extension DiscoverGoalsFilterX on DiscoverGoalsFilter {
  bool matches(DiscoverGoalListItem item) {
    return switch (this) {
      DiscoverGoalsFilter.all => true,
      DiscoverGoalsFilter.predicted => item.hasPrediction,
      DiscoverGoalsFilter.newOnly =>
        !item.hasPrediction && item.goal.status == GoalStatus.active,
    };
  }
}

class DiscoverGoalListItem {
  const DiscoverGoalListItem({required this.goal, required this.hasPrediction});

  final Goal goal;
  final bool hasPrediction;
}
