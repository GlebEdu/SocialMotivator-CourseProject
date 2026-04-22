import 'evidence_attachment.dart';

class SubmitGoalEvidenceInput {
  const SubmitGoalEvidenceInput({
    required this.goalId,
    required this.description,
    required this.attachment,
  });

  final String goalId;
  final String description;
  final SubmitGoalEvidenceAttachmentInput attachment;
}

class SubmitGoalEvidenceAttachmentInput {
  const SubmitGoalEvidenceAttachmentInput({
    required this.type,
    required this.uploadId,
    required this.fileName,
    this.mimeType,
  });

  final EvidenceAttachmentType type;
  final String uploadId;
  final String fileName;
  final String? mimeType;
}
