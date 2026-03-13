import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/bet.dart';
import '../../domain/entities/bet_side.dart';

part 'bet_model.freezed.dart';
part 'bet_model.g.dart';

@freezed
abstract class BetModel with _$BetModel {
  const BetModel._();

  const factory BetModel({
    required String id,
    required String goalId,
    required String userId,
    required BetSide side,
    required double amount,
    required DateTime createdAt,
  }) = _BetModel;

  factory BetModel.fromJson(Map<String, dynamic> json) =>
      _$BetModelFromJson(json);

  factory BetModel.fromEntity(Bet entity) => BetModel(
    id: entity.id,
    goalId: entity.goalId,
    userId: entity.userId,
    side: entity.side,
    amount: entity.amount,
    createdAt: entity.createdAt,
  );

  Bet toEntity() => Bet(
    id: id,
    goalId: goalId,
    userId: userId,
    side: side,
    amount: amount,
    createdAt: createdAt,
  );
}
