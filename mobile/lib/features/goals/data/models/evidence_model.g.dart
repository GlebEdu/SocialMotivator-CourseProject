// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evidence_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EvidenceModel _$EvidenceModelFromJson(Map<String, dynamic> json) =>
    _EvidenceModel(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      submittedByUserId: json['submittedByUserId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      attachmentUrl: json['attachmentUrl'] as String?,
    );

Map<String, dynamic> _$EvidenceModelToJson(_EvidenceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goalId': instance.goalId,
      'submittedByUserId': instance.submittedByUserId,
      'title': instance.title,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'attachmentUrl': instance.attachmentUrl,
    };
