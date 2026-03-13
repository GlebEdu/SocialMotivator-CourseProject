// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BetModel _$BetModelFromJson(Map<String, dynamic> json) => _BetModel(
  id: json['id'] as String,
  goalId: json['goalId'] as String,
  userId: json['userId'] as String,
  side: $enumDecode(_$BetSideEnumMap, json['side']),
  amount: (json['amount'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BetModelToJson(_BetModel instance) => <String, dynamic>{
  'id': instance.id,
  'goalId': instance.goalId,
  'userId': instance.userId,
  'side': _$BetSideEnumMap[instance.side]!,
  'amount': instance.amount,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$BetSideEnumMap = {
  BetSide.forGoal: 'forGoal',
  BetSide.againstGoal: 'againstGoal',
};
