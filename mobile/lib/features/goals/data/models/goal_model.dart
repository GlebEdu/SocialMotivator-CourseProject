import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_status.dart';

part 'goal_model.freezed.dart';
part 'goal_model.g.dart';

@freezed
abstract class GoalModel with _$GoalModel {
  const GoalModel._();

  const factory GoalModel({
    required String id,
    required String userId,
    required String title,
    required String description,
    required GoalStatus status,
    required DateTime createdAt,
    DateTime? deadline,
  }) = _GoalModel;

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);

  factory GoalModel.fromEntity(Goal entity) => GoalModel(
    id: entity.id,
    userId: entity.userId,
    title: entity.title,
    description: entity.description,
    status: entity.status,
    createdAt: entity.createdAt,
    deadline: entity.deadline,
  );

  Goal toEntity() => Goal(
    id: id,
    userId: userId,
    title: title,
    description: description,
    status: status,
    createdAt: createdAt,
    deadline: deadline,
  );
}
