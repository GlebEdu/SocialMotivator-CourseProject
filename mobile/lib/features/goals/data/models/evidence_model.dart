import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/evidence.dart';

part 'evidence_model.freezed.dart';
part 'evidence_model.g.dart';

@freezed
abstract class EvidenceModel with _$EvidenceModel {
  const EvidenceModel._();

  const factory EvidenceModel({
    required String id,
    required String goalId,
    required String submittedByUserId,
    required String title,
    required String description,
    required DateTime createdAt,
    String? attachmentUrl,
  }) = _EvidenceModel;

  factory EvidenceModel.fromJson(Map<String, dynamic> json) =>
      _$EvidenceModelFromJson(json);

  factory EvidenceModel.fromEntity(Evidence entity) => EvidenceModel(
    id: entity.id,
    goalId: entity.goalId,
    submittedByUserId: entity.submittedByUserId,
    title: entity.title,
    description: entity.description,
    createdAt: entity.createdAt,
    attachmentUrl: entity.attachmentUrl,
  );

  Evidence toEntity() => Evidence(
    id: id,
    goalId: goalId,
    submittedByUserId: submittedByUserId,
    title: title,
    description: description,
    createdAt: createdAt,
    attachmentUrl: attachmentUrl,
  );
}
