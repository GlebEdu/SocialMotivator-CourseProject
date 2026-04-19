import 'evidence_attachment.dart';

class Evidence {
  final String id;
  final String goalId;
  final String submittedByUserId;
  final String description;
  final DateTime createdAt;
  final EvidenceAttachment? attachment;

  const Evidence({
    required this.id,
    required this.goalId,
    required this.submittedByUserId,
    required this.description,
    required this.createdAt,
    this.attachment,
  });
}
