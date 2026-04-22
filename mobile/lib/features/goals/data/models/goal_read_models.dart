import '../../../bets/domain/entities/bet.dart';
import '../../../bets/domain/entities/bet_side.dart';
import '../../../profile/data/models/profile_summary_model.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/evidence_attachment.dart';
import '../../domain/entities/goal.dart';
import 'goal_model.dart';

class GoalListItemModel {
  const GoalListItemModel({required this.goal, required this.hasPrediction});

  factory GoalListItemModel.fromJson(Map<String, dynamic> json) {
    return GoalListItemModel(
      goal: GoalModel.fromJson(<String, dynamic>{
        ...json,
        'userId': (json['author'] as Map<String, dynamic>)['id'],
      }).toEntity(),
      hasPrediction:
          ((json['viewerContext'] as Map<String, dynamic>)['hasPrediction']
              as bool?) ??
          false,
    );
  }

  final Goal goal;
  final bool hasPrediction;
}

class GoalBetSummaryModel {
  const GoalBetSummaryModel({
    required this.totalPool,
    required this.forPool,
    required this.againstPool,
    required this.betsCount,
    required this.viewerTotal,
    required this.viewerForTotal,
    required this.viewerAgainstTotal,
    required this.viewerHasBet,
    required this.viewerOnlyFor,
    required this.viewerOnlyAgainst,
  });

  factory GoalBetSummaryModel.fromJson(Map<String, dynamic> json) {
    return GoalBetSummaryModel(
      totalPool: (json['totalPool'] as num).toDouble(),
      forPool: (json['forPool'] as num).toDouble(),
      againstPool: (json['againstPool'] as num).toDouble(),
      betsCount: (json['betsCount'] as num).toInt(),
      viewerTotal: (json['viewerTotal'] as num?)?.toDouble() ?? 0,
      viewerForTotal: (json['viewerForTotal'] as num?)?.toDouble() ?? 0,
      viewerAgainstTotal: (json['viewerAgainstTotal'] as num?)?.toDouble() ?? 0,
      viewerHasBet: json['viewerHasBet'] as bool? ?? false,
      viewerOnlyFor: json['viewerOnlyFor'] as bool? ?? false,
      viewerOnlyAgainst: json['viewerOnlyAgainst'] as bool? ?? false,
    );
  }

  final double totalPool;
  final double forPool;
  final double againstPool;
  final int betsCount;
  final double viewerTotal;
  final double viewerForTotal;
  final double viewerAgainstTotal;
  final bool viewerHasBet;
  final bool viewerOnlyFor;
  final bool viewerOnlyAgainst;

  List<Bet> toSyntheticViewerBets({
    required String goalId,
    required String userId,
  }) {
    final bets = <Bet>[];
    if (viewerForTotal > 0) {
      bets.add(
        Bet(
          id: '$goalId-viewer-for',
          goalId: goalId,
          userId: userId,
          side: BetSide.forGoal,
          amount: viewerForTotal,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }
    if (viewerAgainstTotal > 0) {
      bets.add(
        Bet(
          id: '$goalId-viewer-against',
          goalId: goalId,
          userId: userId,
          side: BetSide.againstGoal,
          amount: viewerAgainstTotal,
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }
    return bets;
  }
}

class GoalDetailsReadModel {
  const GoalDetailsReadModel({
    required this.goal,
    required this.authorSummary,
    required this.betSummary,
    required this.latestEvidence,
  });

  factory GoalDetailsReadModel.fromJson(Map<String, dynamic> json) {
    final goalJson = Map<String, dynamic>.from(json['goal'] as Map);
    final authorSummary = ProfileSummaryModel.fromJson(
      json['authorSummary'] as Map<String, dynamic>,
    );

    return GoalDetailsReadModel(
      goal: GoalModel.fromJson(goalJson).toEntity(),
      authorSummary: authorSummary,
      betSummary: GoalBetSummaryModel.fromJson(
        json['betSummary'] as Map<String, dynamic>,
      ),
      latestEvidence: _parseEvidence(json['latestEvidence']),
    );
  }

  final Goal goal;
  final ProfileSummaryModel authorSummary;
  final GoalBetSummaryModel betSummary;
  final Evidence? latestEvidence;

  static Evidence? _parseEvidence(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final attachmentJson = value['attachment'] as Map<String, dynamic>?;
    return Evidence(
      id: value['id'] as String,
      goalId: value['goalId'] as String,
      submittedByUserId: value['submittedByUserId'] as String,
      description: value['description'] as String,
      createdAt: DateTime.parse(value['createdAt'] as String),
      attachment: attachmentJson == null
          ? null
          : EvidenceAttachment(
              type: EvidenceAttachmentType.values.byName(
                attachmentJson['type'] as String,
              ),
              remoteUrl: attachmentJson['url'] as String?,
              mimeType: attachmentJson['mimeType'] as String?,
              fileName: attachmentJson['fileName'] as String?,
            ),
    );
  }
}
