import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/arbitration_decision.dart';
import '../../domain/entities/arbitration_vote.dart';

part 'arbitration_vote_model.freezed.dart';
part 'arbitration_vote_model.g.dart';

@freezed
abstract class ArbitrationVoteModel with _$ArbitrationVoteModel {
  const ArbitrationVoteModel._();

  const factory ArbitrationVoteModel({
    required String id,
    required String caseId,
    required String voterUserId,
    required ArbitrationDecision decision,
    required DateTime createdAt,
    String? comment,
  }) = _ArbitrationVoteModel;

  factory ArbitrationVoteModel.fromJson(Map<String, dynamic> json) =>
      _$ArbitrationVoteModelFromJson(json);

  factory ArbitrationVoteModel.fromEntity(ArbitrationVote entity) =>
      ArbitrationVoteModel(
        id: entity.id,
        caseId: entity.caseId,
        voterUserId: entity.voterUserId,
        decision: entity.decision,
        createdAt: entity.createdAt,
        comment: entity.comment,
      );

  ArbitrationVote toEntity() => ArbitrationVote(
    id: id,
    caseId: caseId,
    voterUserId: voterUserId,
    decision: decision,
    createdAt: createdAt,
    comment: comment,
  );
}
