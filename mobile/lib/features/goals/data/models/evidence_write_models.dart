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
    final attachmentJson = evidenceJson['attachment'] as Map<String, dynamic>?;

    return EvidenceSubmissionResultModel(
      evidence: Evidence(
        id: evidenceJson['id'] as String,
        goalId: evidenceJson['goalId'] as String,
        submittedByUserId: evidenceJson['submittedByUserId'] as String,
        description: evidenceJson['description'] as String,
        createdAt: DateTime.parse(evidenceJson['createdAt'] as String),
        attachment: attachmentJson == null
            ? null
            : EvidenceAttachment(
                type: EvidenceAttachmentType.values.byName(
                  attachmentJson['type'] as String,
                ),
                remoteUrl: attachmentJson['url'] as String?,
                mimeType: attachmentJson['mimeType'] as String?,
                fileName: attachmentJson['fileName'] as String?,
              ),
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
}
