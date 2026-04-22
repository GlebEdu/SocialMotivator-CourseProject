import '../../../goals/data/models/goal_read_models.dart';
import '../../domain/entities/bet.dart';
import 'bet_model.dart';

class PlaceBetResponseModel {
  const PlaceBetResponseModel({
    required this.bet,
    required this.updatedBetSummary,
    required this.updatedBalance,
  });

  factory PlaceBetResponseModel.fromJson(Map<String, dynamic> json) {
    return PlaceBetResponseModel(
      bet: BetModel.fromJson(json['bet'] as Map<String, dynamic>).toEntity(),
      updatedBetSummary: GoalBetSummaryModel.fromJson(
        json['updatedBetSummary'] as Map<String, dynamic>,
      ),
      updatedBalance: (json['updatedBalance'] as num).toDouble(),
    );
  }

  final Bet bet;
  final GoalBetSummaryModel updatedBetSummary;
  final double updatedBalance;
}
