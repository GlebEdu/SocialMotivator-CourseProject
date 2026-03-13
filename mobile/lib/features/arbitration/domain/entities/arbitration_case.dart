import 'arbitration_decision.dart';

class ArbitrationCase {
  const ArbitrationCase({
    required this.id,
    required this.goalId,
    required this.createdByUserId,
    required this.arbitratorUserIds,
    required this.reason,
    required this.decision,
    required this.createdAt,
    this.resolvedAt,
  });

  final String id;
  final String goalId;
  final String createdByUserId;
  final List<String> arbitratorUserIds;
  final String reason;
  final ArbitrationDecision decision;
  final DateTime createdAt;
  final DateTime? resolvedAt;
}
