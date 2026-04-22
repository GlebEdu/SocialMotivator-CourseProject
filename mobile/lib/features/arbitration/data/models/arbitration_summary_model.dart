import '../../domain/entities/arbitration_decision.dart';

class ArbitrationViewerAssignmentModel {
  const ArbitrationViewerAssignmentModel({
    required this.isAssigned,
    required this.hasVoted,
  });

  factory ArbitrationViewerAssignmentModel.fromJson(Map<String, dynamic> json) {
    return ArbitrationViewerAssignmentModel(
      isAssigned: json['isAssigned'] as bool? ?? false,
      hasVoted: json['hasVoted'] as bool? ?? false,
    );
  }

  final bool isAssigned;
  final bool hasVoted;
}

class ArbitrationCaseSummaryModel {
  const ArbitrationCaseSummaryModel({
    required this.id,
    required this.goalId,
    required this.goalTitle,
    required this.decision,
    required this.reason,
    required this.createdAt,
    required this.viewerAssignment,
    this.resolvedAt,
  });

  factory ArbitrationCaseSummaryModel.fromJson(Map<String, dynamic> json) {
    return ArbitrationCaseSummaryModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      goalTitle: json['goalTitle'] as String? ?? 'Goal',
      decision: ArbitrationDecision.values.byName(json['decision'] as String),
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      viewerAssignment: ArbitrationViewerAssignmentModel.fromJson(
        json['viewerAssignment'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
    );
  }

  final String id;
  final String goalId;
  final String goalTitle;
  final ArbitrationDecision decision;
  final String reason;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final ArbitrationViewerAssignmentModel viewerAssignment;
}
