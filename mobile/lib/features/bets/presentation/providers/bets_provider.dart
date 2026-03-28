import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../domain/entities/bet.dart';
import '../../domain/entities/place_bet_input.dart';

final placeBetControllerProvider =
    AsyncNotifierProvider<PlaceBetController, void>(PlaceBetController.new);

class PlaceBetController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Bet> placeBet(PlaceBetInput input) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(goalEngineProvider).placeBet(input),
    );
    state = result.whenData((_) {});

    final bet = result.requireValue;
    ref.invalidate(goalsFeedProvider);
    ref.invalidate(currentUserBetsProvider);
    ref.invalidate(currentUserPredictedGoalIdsProvider);
    ref.invalidate(goalDetailsProvider(input.goalId));

    return bet;
  }
}
