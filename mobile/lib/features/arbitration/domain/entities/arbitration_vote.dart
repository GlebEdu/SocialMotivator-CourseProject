import 'arbitration_decision.dart';

class ArbitrationVote {
  final String id;
  final String caseId;
  final String voterUserId;
  final ArbitrationDecision decision;
  final DateTime createdAt;
  final String? comment;

    const ArbitrationVote({
    required this.id,
    required this.caseId,
    required this.voterUserId,
    required this.decision,
    required this.createdAt,
    this.comment,
  });
}
