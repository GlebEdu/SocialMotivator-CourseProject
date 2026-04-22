import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../domain/entities/bet.dart';
import '../../domain/entities/bet_side.dart';
import '../../domain/entities/place_bet_input.dart';

final placeBetControllerProvider =
    AsyncNotifierProvider.autoDispose<PlaceBetController, void>(
      PlaceBetController.new,
    );

final goalBetSummaryProvider = FutureProvider.family<GoalBetSummary, String>((
  ref,
  goalId,
) async {
  final details = await ref.watch(goalReadDetailsProvider(goalId).future);
  final currentUser = await ref.watch(authControllerProvider.future);
  if (details != null && currentUser != null) {
    return GoalBetSummary(
      goalBets: const <Bet>[],
      currentUserBets: details.betSummary.toSyntheticViewerBets(
        goalId: goalId,
        userId: currentUser.id,
      ),
      totalPoolOverride: details.betSummary.totalPool,
      forPoolOverride: details.betSummary.forPool,
      againstPoolOverride: details.betSummary.againstPool,
      goalBetsCountOverride: details.betSummary.betsCount,
      currentUserTotalOverride: details.betSummary.viewerTotal,
      currentUserForTotalOverride: details.betSummary.viewerForTotal,
      currentUserAgainstTotalOverride: details.betSummary.viewerAgainstTotal,
    );
  }

  final goalBets = await ref.watch(
    betsRepositoryProvider.select(
      (repository) => repository.getBetsForGoal(goalId),
    ),
  );
  final currentUserBets = currentUser == null
      ? const <Bet>[]
      : goalBets
            .where((bet) => bet.userId == currentUser.id)
            .toList(growable: false);

  return GoalBetSummary(goalBets: goalBets, currentUserBets: currentUserBets);
});

class PlaceBetController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<Bet> placeBet(PlaceBetInput input) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(betsRepositoryProvider).placeBet(input),
    );
    state = result.whenData((_) {});

    final bet = result.requireValue;
    await _refreshCurrentUserBestEffort();
    ref.invalidate(goalsFeedProvider);
    ref.invalidate(myGoalsProvider);
    ref.invalidate(discoverGoalsProvider);
    ref.invalidate(currentUserBetsProvider);
    ref.invalidate(currentUserPredictedGoalIdsProvider);
    ref.invalidate(goalReadDetailsProvider(input.goalId));
    ref.invalidate(goalDetailsProvider(input.goalId));
    ref.invalidate(goalBetSummaryProvider(input.goalId));

    return bet;
  }

  Future<void> _refreshCurrentUserBestEffort() async {
    try {
      await ref.read(authControllerProvider.notifier).refreshCurrentUser();
    } catch (_) {
      // Bet placement already succeeded on the backend, so keep UI flow intact.
    }
  }
}

class GoalBetSummary {
  const GoalBetSummary({
    required this.goalBets,
    required this.currentUserBets,
    this.totalPoolOverride,
    this.forPoolOverride,
    this.againstPoolOverride,
    this.goalBetsCountOverride,
    this.currentUserTotalOverride,
    this.currentUserForTotalOverride,
    this.currentUserAgainstTotalOverride,
  });

  final List<Bet> goalBets;
  final List<Bet> currentUserBets;
  final double? totalPoolOverride;
  final double? forPoolOverride;
  final double? againstPoolOverride;
  final int? goalBetsCountOverride;
  final double? currentUserTotalOverride;
  final double? currentUserForTotalOverride;
  final double? currentUserAgainstTotalOverride;

  bool get hasCurrentUserBet => currentUserBets.isNotEmpty;

  double get totalPool =>
      totalPoolOverride ??
      goalBets.fold<double>(0, (sum, bet) => sum + bet.amount);

  double get forPool =>
      forPoolOverride ?? _amountForSide(goalBets, BetSide.forGoal);

  double get againstPool =>
      againstPoolOverride ?? _amountForSide(goalBets, BetSide.againstGoal);

  int get goalBetsCount => goalBetsCountOverride ?? goalBets.length;

  double get currentUserTotal =>
      currentUserTotalOverride ??
      currentUserBets.fold<double>(0, (sum, bet) => sum + bet.amount);

  double get currentUserForTotal =>
      currentUserForTotalOverride ??
      _amountForSide(currentUserBets, BetSide.forGoal);

  double get currentUserAgainstTotal =>
      currentUserAgainstTotalOverride ??
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
