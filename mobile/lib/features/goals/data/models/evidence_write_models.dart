import '../../domain/entities/evidence.dart';
import '../../domain/entities/evidence_attachment.dart';
import '../../domain/entities/evidence_submission_result.dart';
import '../../domain/entities/evidence_upload_slot.dart';
import '../../domain/entities/goal_status.dart';

class EvidenceUploadSlotModel {
  const EvidenceUploadSlotModel({
    required this.uploadId,
    required this.uploadUrl,
    required this.fileUrl,
  });

  factory EvidenceUploadSlotModel.fromJson(Map<String, dynamic> json) {
    return EvidenceUploadSlotModel(
      uploadId: json['uploadId'] as String,
      uploadUrl: json['uploadUrl'] as String,
      fileUrl: json['fileUrl'] as String,
    );
  }

  final String uploadId;
  final String uploadUrl;
  final String fileUrl;

  EvidenceUploadSlot toEntity() => EvidenceUploadSlot(
    uploadId: uploadId,
    uploadUrl: uploadUrl,
    fileUrl: fileUrl,
  );
}

class EvidenceSubmissionResultModel {
  const EvidenceSubmissionResultModel({
    required this.evidence,
    required this.goalStatus,
    this.arbitrationCaseId,
  });

  factory EvidenceSubmissionResultModel.fromJson(Map<String, dynamic> json) {
    final evidenceJson = json['evidence'] as Map<String, dynamic>;
    final attachments = _parseAttachments(evidenceJson);

    return EvidenceSubmissionResultModel(
      evidence: Evidence(
        id: evidenceJson['id'] as String,
        goalId: evidenceJson['goalId'] as String,
        submittedByUserId: evidenceJson['submittedByUserId'] as String,
        description: evidenceJson['description'] as String,
        createdAt: DateTime.parse(evidenceJson['createdAt'] as String),
        attachments: attachments,
      ),
      goalStatus: GoalStatus.values.byName(json['goalStatus'] as String),
      arbitrationCaseId: json['arbitrationCaseId'] as String?,
    );
  }

  final Evidence evidence;
  final GoalStatus goalStatus;
  final String? arbitrationCaseId;

  EvidenceSubmissionResult toEntity() => EvidenceSubmissionResult(
    evidence: evidence,
    goalStatus: goalStatus,
    arbitrationCaseId: arbitrationCaseId,
  );

  static List<EvidenceAttachment> _parseAttachments(
    Map<String, dynamic> evidenceJson,
  ) {
    final attachmentsJson = evidenceJson['attachments'];
    if (attachmentsJson is List) {
      return attachmentsJson
          .whereType<Map<String, dynamic>>()
          .map(_parseAttachment)
          .toList(growable: false);
    }

    final attachmentJson = evidenceJson['attachment'];
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
