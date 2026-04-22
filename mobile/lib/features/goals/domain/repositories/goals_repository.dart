import '../entities/create_goal_input.dart';
import '../entities/create_evidence_upload_input.dart';
import '../entities/evidence.dart';
import '../entities/evidence_submission_result.dart';
import '../entities/evidence_upload_slot.dart';
import '../entities/goal.dart';
import '../entities/goal_status.dart';
import '../entities/submit_goal_evidence_input.dart';

abstract class GoalsRepository {
  Future<List<Goal>> getGoalsFeed();

  Future<Goal?> getGoalById(String goalId);

  Future<Goal> createGoal(CreateGoalInput input);

  Future<Goal> updateGoalStatus({
    required String goalId,
    required GoalStatus status,
  });

  Future<EvidenceUploadSlot> createEvidenceUpload(
    CreateEvidenceUploadInput input,
  );

  Future<void> uploadEvidenceFile({
    required EvidenceUploadSlot upload,
    required List<int> bytes,
    String? mimeType,
  });

  Future<EvidenceSubmissionResult> submitEvidence(
    SubmitGoalEvidenceInput input,
  );

  Future<Evidence?> getLatestEvidenceForGoal(String goalId);
}
