// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evidence_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EvidenceAttachmentModel _$EvidenceAttachmentModelFromJson(
  Map<String, dynamic> json,
) => _EvidenceAttachmentModel(
  type: $enumDecode(_$EvidenceAttachmentTypeEnumMap, json['type']),
  localPath: json['localPath'] as String?,
  remoteUrl: json['remoteUrl'] as String?,
  mimeType: json['mimeType'] as String?,
  fileName: json['fileName'] as String?,
);

Map<String, dynamic> _$EvidenceAttachmentModelToJson(
  _EvidenceAttachmentModel instance,
) => <String, dynamic>{
  'type': _$EvidenceAttachmentTypeEnumMap[instance.type]!,
  'localPath': instance.localPath,
  'remoteUrl': instance.remoteUrl,
  'mimeType': instance.mimeType,
  'fileName': instance.fileName,
};

const _$EvidenceAttachmentTypeEnumMap = {
  EvidenceAttachmentType.image: 'image',
  EvidenceAttachmentType.video: 'video',
};

_EvidenceModel _$EvidenceModelFromJson(Map<String, dynamic> json) =>
    _EvidenceModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      submittedByUserId: json['submittedByUserId'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      attachment: json['attachment'] == null
          ? null
          : EvidenceAttachmentModel.fromJson(
              json['attachment'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$EvidenceModelToJson(_EvidenceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'submittedByUserId': instance.submittedByUserId,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'attachment': instance.attachment,
    };
