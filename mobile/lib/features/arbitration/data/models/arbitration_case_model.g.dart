// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arbitration_case_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ArbitrationCaseModel _$ArbitrationCaseModelFromJson(
  Map<String, dynamic> json,
) => _ArbitrationCaseModel(
  id: json['id'] as String,
  goalId: json['goalId'] as String,
  createdByUserId: json['createdByUserId'] as String,
  arbitratorUserIds: (json['arbitratorUserIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  reason: json['reason'] as String,
  decision: $enumDecode(_$ArbitrationDecisionEnumMap, json['decision']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
);

Map<String, dynamic> _$ArbitrationCaseModelToJson(
  _ArbitrationCaseModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'goalId': instance.goalId,
  'createdByUserId': instance.createdByUserId,
  'arbitratorUserIds': instance.arbitratorUserIds,
  'reason': instance.reason,
  'decision': _$ArbitrationDecisionEnumMap[instance.decision]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
};

const _$ArbitrationDecisionEnumMap = {
  ArbitrationDecision.pending: 'pending',
  ArbitrationDecision.approved: 'approved',
  ArbitrationDecision.rejected: 'rejected',
};
