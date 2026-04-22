import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bets/domain/entities/bet.dart';
import '../../../../shared/providers/repository_providers.dart';
import '../../data/models/goal_read_models.dart';
import '../../domain/entities/create_goal_input.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/evidence_attachment.dart';
import '../../domain/entities/evidence_submission_result.dart';
import '../../domain/entities/create_evidence_upload_input.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/submit_goal_evidence_input.dart';

final goalsFeedProvider = FutureProvider<List<Goal>>((ref) async {
  return ref.watch(goalsRepositoryProvider).getGoalsFeed();
});

final goalReadDetailsProvider =
    FutureProvider.family<GoalDetailsReadModel?, String>((ref, goalId) async {
      final currentUser = await ref.watch(authControllerProvider.future);
      if (currentUser == null) {
        return null;
      }

      return ref.watch(goalsReadRepositoryProvider).getGoalDetails(goalId);
    });

final goalEvidenceProvider = FutureProvider.family<Evidence?, String>((
  ref,
  goalId,
) {
  return ref.watch(goalsReadRepositoryProvider).getLatestEvidence(goalId);
});

final myGoalsProvider = FutureProvider<List<Goal>>((ref) async {
  final currentUser = await ref.watch(authControllerProvider.future);
  if (currentUser == null) {
    return const <Goal>[];
  }

  return ref.watch(goalsReadRepositoryProvider).getMyGoals();
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
      if (currentUser == null) {
        return const <DiscoverGoalListItem>[];
      }

      final items = await ref
          .watch(goalsReadRepositoryProvider)
          .getDiscoverGoals(filter: filter.apiValue);
      return items
          .map(
            (item) => DiscoverGoalListItem(
              goal: item.goal,
              hasPrediction: item.hasPrediction,
            ),
          )
          .toList(growable: false);
    });

final goalDetailsProvider = FutureProvider.family<Goal?, String>((
  ref,
  goalId,
) async {
  final details = await ref.watch(goalReadDetailsProvider(goalId).future);
  return details?.goal;
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
      () => ref.read(goalsRepositoryProvider).createGoal(input),
    );
    state = result.whenData((_) {});

    final goal = result.requireValue;
    await _refreshCurrentUserBestEffort();
    ref.invalidate(goalsFeedProvider);
    ref.invalidate(myGoalsProvider);
    ref.invalidate(currentUserBetsProvider);
    ref.invalidate(currentUserPredictedGoalIdsProvider);
    ref.invalidate(goalReadDetailsProvider(goal.id));
    ref.invalidate(goalDetailsProvider(goal.id));
    ref.invalidate(goalEvidenceProvider(goal.id));

    return goal;
  }

  Future<void> _refreshCurrentUserBestEffort() async {
    try {
      await ref.read(authControllerProvider.notifier).refreshCurrentUser();
    } catch (_) {
      // Goal creation already succeeded on the backend, so keep UI flow intact.
    }
  }
}

class SubmitEvidenceController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<EvidenceSubmissionResult> submitEvidence({
    required String goalId,
    required String description,
    required EvidenceAttachment attachment,
  }) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(
      () => _submitEvidence(
        goalId: goalId,
        description: description,
        attachment: attachment,
      ),
    );
    state = result.whenData((_) {});

    final savedEvidence = result.requireValue;
    ref.invalidate(goalsFeedProvider);
    ref.invalidate(myGoalsProvider);
    ref.invalidate(discoverGoalsProvider);
    ref.invalidate(goalReadDetailsProvider(savedEvidence.evidence.goalId));
    ref.invalidate(goalDetailsProvider(savedEvidence.evidence.goalId));
    ref.invalidate(goalEvidenceProvider(savedEvidence.evidence.goalId));

    return savedEvidence;
  }

  Future<EvidenceSubmissionResult> _submitEvidence({
    required String goalId,
    required String description,
    required EvidenceAttachment attachment,
  }) async {
    final localPath = attachment.localPath;
    final fileName = attachment.fileName;
    if (localPath == null || localPath.isEmpty || fileName == null) {
      throw StateError('Evidence attachment file is missing.');
    }

    final upload = await ref
        .read(goalsRepositoryProvider)
        .createEvidenceUpload(
          CreateEvidenceUploadInput(
            type: attachment.type,
            fileName: fileName,
            mimeType: attachment.mimeType,
          ),
        );

    final bytes = await File(localPath).readAsBytes();
    await ref
        .read(goalsRepositoryProvider)
        .uploadEvidenceFile(
          upload: upload,
          bytes: bytes,
          mimeType: attachment.mimeType,
        );

    return ref
        .read(goalsRepositoryProvider)
        .submitEvidence(
          SubmitGoalEvidenceInput(
            goalId: goalId,
            description: description,
            attachment: SubmitGoalEvidenceAttachmentInput(
              type: attachment.type,
              uploadId: upload.uploadId,
              fileName: fileName,
              mimeType: attachment.mimeType,
            ),
          ),
        );
  }
}

enum DiscoverGoalsFilter { all, predicted, newOnly }

extension DiscoverGoalsFilterX on DiscoverGoalsFilter {
  String get apiValue {
    return switch (this) {
      DiscoverGoalsFilter.all => 'all',
      DiscoverGoalsFilter.predicted => 'predicted',
      DiscoverGoalsFilter.newOnly => 'new',
    };
  }
}

class DiscoverGoalListItem {
  const DiscoverGoalListItem({required this.goal, required this.hasPrediction});

  final Goal goal;
  final bool hasPrediction;
}
