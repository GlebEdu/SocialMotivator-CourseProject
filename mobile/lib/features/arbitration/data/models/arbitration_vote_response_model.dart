import '../../../goals/domain/entities/goal_status.dart';
import '../../domain/entities/arbitration_decision.dart';
import '../../domain/entities/arbitration_vote.dart';

class SubmitArbitrationVoteResponseModel {
  const SubmitArbitrationVoteResponseModel({
    required this.vote,
    required this.caseDecision,
    required this.goalStatus,
  });

  factory SubmitArbitrationVoteResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final voteJson = json['vote'] as Map<String, dynamic>;
    return SubmitArbitrationVoteResponseModel(
      vote: ArbitrationVote(
        id: voteJson['id'] as String,
        caseId: voteJson['caseId'] as String,
        voterUserId: voteJson['voterUserId'] as String,
        decision: ArbitrationDecision.values.byName(
          voteJson['decision'] as String,
        ),
        createdAt: DateTime.parse(voteJson['createdAt'] as String),
        comment: voteJson['comment'] as String?,
      ),
      caseDecision: ArbitrationDecision.values.byName(
        json['caseDecision'] as String,
      ),
      goalStatus: GoalStatus.values.byName(json['goalStatus'] as String),
    );
  }

  final ArbitrationVote vote;
  final ArbitrationDecision caseDecision;
  final GoalStatus goalStatus;
}
