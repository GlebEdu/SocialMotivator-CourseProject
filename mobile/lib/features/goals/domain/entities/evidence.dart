import 'evidence_attachment.dart';

class Evidence {
  final String id;
  final String goalId;
  final String submittedByUserId;
  final String description;
  final DateTime createdAt;
  final List<EvidenceAttachment> attachments;

  Evidence({
    required this.id,
    required this.goalId,
    required this.submittedByUserId,
    required this.description,
    required this.createdAt,
    List<EvidenceAttachment>? attachments,
    EvidenceAttachment? attachment,
  }) : attachments =
           attachments ??
           (attachment == null ? const <EvidenceAttachment>[] : [attachment]);

  EvidenceAttachment? get attachment =>
      attachments.isEmpty ? null : attachments.first;
}
