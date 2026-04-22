import 'evidence.dart';
import 'goal_status.dart';

class EvidenceSubmissionResult {
  const EvidenceSubmissionResult({
    required this.evidence,
    required this.goalStatus,
    this.arbitrationCaseId,
  });

  final Evidence evidence;
  final GoalStatus goalStatus;
  final String? arbitrationCaseId;
}
