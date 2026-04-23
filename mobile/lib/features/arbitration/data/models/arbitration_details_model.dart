import '../../../goals/data/models/goal_model.dart';
import '../../../goals/domain/entities/evidence.dart';
import '../../../goals/domain/entities/evidence_attachment.dart';
import '../../../goals/domain/entities/goal.dart';
import '../../../profile/data/models/profile_summary_model.dart';
import '../../domain/entities/arbitration_case.dart';
import '../../domain/entities/arbitration_decision.dart';
import '../../domain/entities/arbitration_vote.dart';

class ArbitrationAssignmentModel {
  const ArbitrationAssignmentModel({
    required this.userId,
    required this.displayName,
    required this.hasVoted,
  });

  factory ArbitrationAssignmentModel.fromJson(Map<String, dynamic> json) {
    return ArbitrationAssignmentModel(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      hasVoted: json['hasVoted'] as bool? ?? false,
    );
  }

  final String userId;
  final String displayName;
  final bool hasVoted;
}

class ArbitrationViewerContextModel {
  const ArbitrationViewerContextModel({
    required this.isAssigned,
    required this.hasVoted,
    required this.canVote,
  });

  factory ArbitrationViewerContextModel.fromJson(Map<String, dynamic> json) {
    return ArbitrationViewerContextModel(
      isAssigned: json['isAssigned'] as bool? ?? false,
      hasVoted: json['hasVoted'] as bool? ?? false,
      canVote: json['canVote'] as bool? ?? false,
    );
  }

  final bool isAssigned;
  final bool hasVoted;
  final bool canVote;
}

class ArbitrationCaseDetailsModel {
  const ArbitrationCaseDetailsModel({
    required this.arbitrationCase,
    required this.goal,
    required this.authorSummary,
    required this.assignments,
    required this.votes,
    required this.viewerContext,
    this.latestEvidence,
  });

  factory ArbitrationCaseDetailsModel.fromJson(Map<String, dynamic> json) {
    final assignments =
        ((json['assignments'] as List<dynamic>?) ?? const <dynamic>[])
            .map((item) => ArbitrationAssignmentModel.fromJson(_asMap(item)))
            .toList(growable: false);
    final caseJson = _asMap(json['case']);

    return ArbitrationCaseDetailsModel(
      arbitrationCase: ArbitrationCase(
        id: caseJson['id'] as String,
        goalId: caseJson['goalId'] as String,
        createdByUserId: caseJson['createdByUserId'] as String,
        arbitratorUserIds: assignments
            .map((assignment) => assignment.userId)
            .toList(growable: false),
        reason: caseJson['reason'] as String,
        decision: ArbitrationDecision.values.byName(
          caseJson['decision'] as String,
        ),
        createdAt: DateTime.parse(caseJson['createdAt'] as String),
        resolvedAt: caseJson['resolvedAt'] == null
            ? null
            : DateTime.parse(caseJson['resolvedAt'] as String),
      ),
      goal: GoalModel.fromJson(_asMap(json['goal'])).toEntity(),
      authorSummary: ProfileSummaryModel.fromJson(
        json['authorSummary'] as Map<String, dynamic>,
      ),
      latestEvidence: _parseEvidence(json['latestEvidence']),
      assignments: assignments,
      votes: ((json['votes'] as List<dynamic>?) ?? const <dynamic>[])
          .map((item) => _parseVote(_asMap(item)))
          .toList(growable: false),
      viewerContext: ArbitrationViewerContextModel.fromJson(
        json['viewerContext'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      ),
    );
  }

  final ArbitrationCase arbitrationCase;
  final Goal goal;
  final ProfileSummaryModel authorSummary;
  final Evidence? latestEvidence;
  final List<ArbitrationAssignmentModel> assignments;
  final List<ArbitrationVote> votes;
  final ArbitrationViewerContextModel viewerContext;

  static ArbitrationVote _parseVote(Map<String, dynamic> json) {
    return ArbitrationVote(
      id: json['id'] as String,
      caseId: json['caseId'] as String,
      voterUserId: json['voterUserId'] as String,
      decision: ArbitrationDecision.values.byName(json['decision'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      comment: json['comment'] as String?,
    );
  }

  static Evidence? _parseEvidence(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    return Evidence(
      id: value['id'] as String,
      goalId: value['goalId'] as String,
      submittedByUserId: value['submittedByUserId'] as String,
      description: value['description'] as String,
      createdAt: DateTime.parse(value['createdAt'] as String),
      attachments: _parseAttachments(value),
    );
  }

  static List<EvidenceAttachment> _parseAttachments(Map<String, dynamic> json) {
    final attachmentsJson = json['attachments'];
    if (attachmentsJson is List) {
      return attachmentsJson
          .whereType<Map<String, dynamic>>()
          .map(_parseAttachment)
          .toList(growable: false);
    }

    final attachmentJson = json['attachment'];
    if (attachmentJson is Map<String, dynamic>) {
      return <EvidenceAttachment>[_parseAttachment(attachmentJson)];
    }

    return const <EvidenceAttachment>[];
  }

  static EvidenceAttachment _parseAttachment(Map<String, dynamic> json) {
    return EvidenceAttachment(
      type: EvidenceAttachmentType.values.byName(json['type'] as String),
      remoteUrl: json['url'] as String?,
      mimeType: json['mimeType'] as String?,
      fileName: json['fileName'] as String?,
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  return Map<String, dynamic>.from(value as Map);
}
