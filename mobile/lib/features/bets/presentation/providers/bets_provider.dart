import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../domain/entities/bet.dart';
import '../../domain/entities/bet_side.dart';
import '../../domain/entities/place_bet_input.dart';

final placeBetControllerProvider =
    AsyncNotifierProvider<PlaceBetController, void>(PlaceBetController.new);

final goalBetSummaryProvider = FutureProvider.family<GoalBetSummary, String>((
  ref,
  goalId,
) async {
  final goalBets = await ref.watch(
    betsRepositoryProvider.select(
      (repository) => repository.getBetsForGoal(goalId),
    ),
  );
  final currentUser = await ref.watch(authControllerProvider.future);
  final currentUserBets = currentUser == null
      ? const <Bet>[]
      : goalBets
            .where((bet) => bet.userId == currentUser.id)
            .toList(growable: false);

  return GoalBetSummary(goalBets: goalBets, currentUserBets: currentUserBets);
});

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
    await ref.read(authControllerProvider.notifier).refreshCurrentUser();
    ref.invalidate(goalsFeedProvider);
    ref.invalidate(currentUserBetsProvider);
    ref.invalidate(currentUserPredictedGoalIdsProvider);
    ref.invalidate(goalDetailsProvider(input.goalId));
    ref.invalidate(goalBetSummaryProvider(input.goalId));

    return bet;
  }
}

class GoalBetSummary {
  const GoalBetSummary({required this.goalBets, required this.currentUserBets});

  final List<Bet> goalBets;
  final List<Bet> currentUserBets;

  bool get hasCurrentUserBet => currentUserBets.isNotEmpty;

  double get totalPool =>
      goalBets.fold<double>(0, (sum, bet) => sum + bet.amount);

  double get forPool => _amountForSide(goalBets, BetSide.forGoal);

  double get againstPool => _amountForSide(goalBets, BetSide.againstGoal);

  double get currentUserTotal =>
      currentUserBets.fold<double>(0, (sum, bet) => sum + bet.amount);

  double get currentUserForTotal =>
      _amountForSide(currentUserBets, BetSide.forGoal);

  double get currentUserAgainstTotal =>
      _amountForSide(currentUserBets, BetSide.againstGoal);

  bool get isCurrentUserOnlyFor =>
      currentUserForTotal > 0 && currentUserAgainstTotal == 0;

  bool get isCurrentUserOnlyAgainst =>
      currentUserAgainstTotal > 0 && currentUserForTotal == 0;

  static double _amountForSide(List<Bet> bets, BetSide side) {
    return bets
        .where((bet) => bet.side == side)
        .fold<double>(0, (sum, bet) => sum + bet.amount);
  }
}
