import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../domain/entities/arbitration_case.dart';
import '../../domain/entities/arbitration_vote.dart';

final arbitrationListProvider = FutureProvider<List<ArbitrationCase>>((ref) {
  return ref.watch(arbitrationRepositoryProvider).getArbitrationCases();
});

final arbitrationCaseProvider = FutureProvider.family<ArbitrationCase?, String>(
  (ref, caseId) {
    return ref
        .watch(arbitrationRepositoryProvider)
        .getArbitrationCaseById(caseId);
  },
);

final voteArbitrationControllerProvider =
    AsyncNotifierProvider<VoteArbitrationController, void>(
      VoteArbitrationController.new,
    );

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
    ref.invalidate(arbitrationListProvider);
    ref.invalidate(arbitrationCaseProvider(input.caseId));

    if (arbitrationCase != null) {
      ref.invalidate(goalsFeedProvider);
      ref.invalidate(goalDetailsProvider(arbitrationCase.goalId));
    }

    return result.requireValue;
  }
}
