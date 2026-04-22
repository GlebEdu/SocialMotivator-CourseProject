import 'evidence_attachment.dart';

class CreateEvidenceUploadInput {
  const CreateEvidenceUploadInput({
    required this.type,
    required this.fileName,
    this.mimeType,
  });

  final EvidenceAttachmentType type;
  final String fileName;
  final String? mimeType;
}
