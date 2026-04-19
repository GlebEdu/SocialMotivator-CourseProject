import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/evidence.dart';
import '../../domain/entities/evidence_attachment.dart';

part 'evidence_model.freezed.dart';
part 'evidence_model.g.dart';

@freezed
abstract class EvidenceAttachmentModel with _$EvidenceAttachmentModel {
  const EvidenceAttachmentModel._();

  const factory EvidenceAttachmentModel({
    required EvidenceAttachmentType type,
    String? localPath,
    String? remoteUrl,
    String? mimeType,
    String? fileName,
  }) = _EvidenceAttachmentModel;

  factory EvidenceAttachmentModel.fromJson(Map<String, dynamic> json) =>
      _$EvidenceAttachmentModelFromJson(json);

  factory EvidenceAttachmentModel.fromEntity(EvidenceAttachment entity) =>
      EvidenceAttachmentModel(
        type: entity.type,
        localPath: entity.localPath,
        remoteUrl: entity.remoteUrl,
        mimeType: entity.mimeType,
        fileName: entity.fileName,
      );

  EvidenceAttachment toEntity() => EvidenceAttachment(
    type: type,
    localPath: localPath,
    remoteUrl: remoteUrl,
    mimeType: mimeType,
    fileName: fileName,
  );
}

@freezed
abstract class EvidenceModel with _$EvidenceModel {
  const EvidenceModel._();

  const factory EvidenceModel({
    required String id,
    required String goalId,
    required String submittedByUserId,
    required String description,
    required DateTime createdAt,
    EvidenceAttachmentModel? attachment,
  }) = _EvidenceModel;

  factory EvidenceModel.fromJson(Map<String, dynamic> json) =>
      _$EvidenceModelFromJson(json);

  factory EvidenceModel.fromEntity(Evidence entity) => EvidenceModel(
    id: entity.id,
    goalId: entity.goalId,
    submittedByUserId: entity.submittedByUserId,
    description: entity.description,
    createdAt: entity.createdAt,
    attachment: entity.attachment == null
        ? null
        : EvidenceAttachmentModel.fromEntity(entity.attachment!),
  );

  Evidence toEntity() => Evidence(
    id: id,
    goalId: goalId,
    submittedByUserId: submittedByUserId,
    description: description,
    createdAt: createdAt,
    attachment: attachment?.toEntity(),
  );
}
