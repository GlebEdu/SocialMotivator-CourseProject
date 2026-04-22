import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../goals/presentation/providers/goals_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/models/arbitration_details_model.dart';
import '../../data/models/arbitration_summary_model.dart';
import '../../data/models/arbitration_vote_response_model.dart';
import '../../domain/entities/arbitration_decision.dart';

final arbitrationListProvider =
    FutureProvider<List<ArbitrationCaseSummaryModel>>((ref) async {
      final currentUser = await ref.watch(authControllerProvider.future);
      if (currentUser == null) {
        return const <ArbitrationCaseSummaryModel>[];
      }

      return ref.watch(arbitrationReadRepositoryProvider).getAssignedCases();
    });

final arbitrationCaseDetailsProvider =
    FutureProvider.family<ArbitrationCaseDetailsModel?, String>((
      ref,
      caseId,
    ) async {
      final currentUser = await ref.watch(authControllerProvider.future);
      if (currentUser == null) {
        return null;
      }

      return ref
          .watch(arbitrationReadRepositoryProvider)
          .getCaseDetails(caseId);
    });

final voteArbitrationControllerProvider =
    AsyncNotifierProvider.autoDispose<VoteArbitrationController, void>(
      VoteArbitrationController.new,
    );

class VoteArbitrationController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<SubmitArbitrationVoteResponseModel> vote({
    required String caseId,
    required ArbitrationDecision decision,
    String? comment,
  }) async {
    final caseDetails = await ref.read(
      arbitrationCaseDetailsProvider(caseId).future,
    );
    if (caseDetails == null) {
      throw StateError('Arbitration case $caseId was not found.');
    }

    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => ref
          .read(arbitrationReadRepositoryProvider)
          .submitVoteResponse(
            caseId: caseId,
            decision: decision,
            comment: comment,
          ),
    );
    state = result.whenData((_) {});

    result.requireValue;

    ref.invalidate(arbitrationListProvider);
    ref.invalidate(arbitrationCaseDetailsProvider(caseId));
    ref.invalidate(goalsFeedProvider);
    ref.invalidate(discoverGoalsProvider);
    ref.invalidate(goalReadDetailsProvider(caseDetails.goal.id));
    ref.invalidate(goalDetailsProvider(caseDetails.goal.id));
    ref.invalidate(goalEvidenceProvider(caseDetails.goal.id));
    ref.invalidate(
      userProfileSummaryProvider(caseDetails.authorSummary.user.id),
    );

    return result.requireValue;
  }
}
