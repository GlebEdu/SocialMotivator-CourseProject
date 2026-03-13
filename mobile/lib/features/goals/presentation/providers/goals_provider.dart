import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../domain/entities/create_goal_input.dart';
import '../../domain/entities/goal.dart';

final goalsFeedProvider = FutureProvider<List<Goal>>((ref) {
  return ref.watch(goalsRepositoryProvider).getGoalsFeed();
});

final goalDetailsProvider = FutureProvider.family<Goal?, String>((ref, goalId) {
  return ref.watch(goalsRepositoryProvider).getGoalById(goalId);
});

final createGoalControllerProvider =
    AsyncNotifierProvider<CreateGoalController, void>(CreateGoalController.new);

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
    ref.invalidate(goalsFeedProvider);
    ref.invalidate(goalDetailsProvider(goal.id));

    return goal;
  }
}
