import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/arbitration_case.dart';
import '../../domain/entities/arbitration_decision.dart';

part 'arbitration_case_model.freezed.dart';
part 'arbitration_case_model.g.dart';

@freezed
abstract class ArbitrationCaseModel with _$ArbitrationCaseModel {
  const ArbitrationCaseModel._();

  const factory ArbitrationCaseModel({
    required String id,
    required String goalId,
    required String createdByUserId,
    required List<String> arbitratorUserIds,
    required String reason,
    required ArbitrationDecision decision,
    required DateTime createdAt,
    DateTime? resolvedAt,
  }) = _ArbitrationCaseModel;

  factory ArbitrationCaseModel.fromJson(Map<String, dynamic> json) =>
      _$ArbitrationCaseModelFromJson(json);

  factory ArbitrationCaseModel.fromEntity(ArbitrationCase entity) =>
      ArbitrationCaseModel(
        id: entity.id,
        goalId: entity.goalId,
        createdByUserId: entity.createdByUserId,
        arbitratorUserIds: entity.arbitratorUserIds,
        reason: entity.reason,
        decision: entity.decision,
        createdAt: entity.createdAt,
        resolvedAt: entity.resolvedAt,
      );

  ArbitrationCase toEntity() => ArbitrationCase(
    id: id,
    goalId: goalId,
    createdByUserId: createdByUserId,
    arbitratorUserIds: arbitratorUserIds,
    reason: reason,
    decision: decision,
    createdAt: createdAt,
    resolvedAt: resolvedAt,
  );
}
