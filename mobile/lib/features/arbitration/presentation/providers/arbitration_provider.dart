import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../goals/domain/entities/evidence.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../domain/entities/arbitration_case.dart';
import '../../domain/entities/arbitration_vote.dart';

final arbitrationListProvider = FutureProvider<List<ArbitrationCase>>((
  ref,
) async {
  await ref.read(goalEngineProvider).syncExpiredGoalsForArbitration();
  final currentUser = await ref.watch(authControllerProvider.future);
  if (currentUser == null) {
    return const <ArbitrationCase>[];
  }

  final arbitrationCases = await ref
      .watch(arbitrationRepositoryProvider)
      .getArbitrationCases();

  return arbitrationCases
      .where(
        (arbitrationCase) =>
            arbitrationCase.arbitratorUserIds.contains(currentUser.id),
      )
      .toList(growable: false);
});

final arbitrationCaseProvider = FutureProvider.family<ArbitrationCase?, String>(
  (ref, caseId) {
    return ref
        .watch(arbitrationRepositoryProvider)
        .getArbitrationCaseById(caseId);
  },
);

final arbitrationCaseDetailsProvider =
    FutureProvider.family<ArbitrationCaseDetails?, String>((ref, caseId) async {
      await ref.read(goalEngineProvider).syncExpiredGoalsForArbitration();
      final currentUser = await ref.watch(authControllerProvider.future);
      if (currentUser == null) {
        return null;
      }

      final arbitrationCase = await ref
          .watch(arbitrationRepositoryProvider)
          .getArbitrationCaseById(caseId);
      if (arbitrationCase == null) {
        return null;
      }

      if (!arbitrationCase.arbitratorUserIds.contains(currentUser.id)) {
        return null;
      }

      final goal = await ref.watch(
        goalDetailsProvider(arbitrationCase.goalId).future,
      );
      if (goal == null) {
        throw StateError(
          'Goal ${arbitrationCase.goalId} was not found for arbitration case ${arbitrationCase.id}.',
        );
      }

      final evidence = await ref.watch(goalEvidenceProvider(goal.id).future);

      return ArbitrationCaseDetails(
        arbitrationCase: arbitrationCase,
        goal: goal,
        evidence: evidence,
      );
    });

final voteArbitrationControllerProvider =
    AsyncNotifierProvider<VoteArbitrationController, void>(
      VoteArbitrationController.new,
    );

class ArbitrationCaseDetails {
  const ArbitrationCaseDetails({
    required this.arbitrationCase,
    required this.goal,
    required this.evidence,
  });

  final ArbitrationCase arbitrationCase;
  final Goal goal;
  final Evidence? evidence;
}

class VoteArbitrationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ArbitrationVote> vote(ArbitrationVote input) async {
    final arbitrationCase = await ref
        .read(arbitrationRepositoryProvider)
        .getArbitrationCaseById(input.caseId);

    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref.read(goalEngineProvider).voteArbitration(input),
    );
    state = result.whenData((_) {});

    result.requireValue;
    await ref.read(authControllerProvider.notifier).refreshCurrentUser();
    ref.invalidate(arbitrationListProvider);
    ref.invalidate(arbitrationCaseProvider(input.caseId));

    if (arbitrationCase != null) {
      ref.invalidate(goalsFeedProvider);
      ref.invalidate(goalDetailsProvider(arbitrationCase.goalId));
    }

    return result.requireValue;
  }
}
