// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => _GoalModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  status: $enumDecode(_$GoalStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  deadline: json['deadline'] == null
      ? null
      : DateTime.parse(json['deadline'] as String),
);

Map<String, dynamic> _$GoalModelToJson(_GoalModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'status': _$GoalStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'deadline': instance.deadline?.toIso8601String(),
    };

const _$GoalStatusEnumMap = {
  GoalStatus.draft: 'draft',
  GoalStatus.active: 'active',
  GoalStatus.completed: 'completed',
  GoalStatus.failed: 'failed',
  GoalStatus.cancelled: 'cancelled',
};
