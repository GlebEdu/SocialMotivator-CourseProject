enum EvidenceAttachmentType { image, video }

class EvidenceAttachment {
  final EvidenceAttachmentType type;
  final String? localPath;
  final String? remoteUrl;
  final String? mimeType;
  final String? fileName;

  const EvidenceAttachment({
    required this.type,
    this.localPath,
    this.remoteUrl,
    this.mimeType,
    this.fileName,
  });
}
