import '../../../bets/data/models/bet_model.dart';
import '../../../bets/domain/entities/bet.dart';
import '../../domain/entities/goal.dart';
import 'goal_model.dart';

class CreateGoalResponseModel {
  const CreateGoalResponseModel({
    required this.goal,
    required this.authorAutoBet,
  });

  factory CreateGoalResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateGoalResponseModel(
      goal: GoalModel.fromJson(json['goal'] as Map<String, dynamic>).toEntity(),
      authorAutoBet: BetModel.fromJson(
        json['authorAutoBet'] as Map<String, dynamic>,
      ).toEntity(),
    );
  }

  final Goal goal;
  final Bet authorAutoBet;
}
