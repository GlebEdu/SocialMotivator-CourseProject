// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arbitration_vote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ArbitrationVoteModel _$ArbitrationVoteModelFromJson(
  Map<String, dynamic> json,
) => _ArbitrationVoteModel(
  id: json['id'] as String,
  caseId: json['caseId'] as String,
  voterUserId: json['voterUserId'] as String,
  decision: $enumDecode(_$ArbitrationDecisionEnumMap, json['decision']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  comment: json['comment'] as String?,
);

Map<String, dynamic> _$ArbitrationVoteModelToJson(
  _ArbitrationVoteModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'caseId': instance.caseId,
  'voterUserId': instance.voterUserId,
  'decision': _$ArbitrationDecisionEnumMap[instance.decision]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'comment': instance.comment,
};

const _$ArbitrationDecisionEnumMap = {
  ArbitrationDecision.pending: 'pending',
  ArbitrationDecision.approved: 'approved',
  ArbitrationDecision.rejected: 'rejected',
};
