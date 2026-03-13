import 'bet_side.dart';

class PlaceBetInput {
  final String goalId;
  final BetSide side;
  final double amount;

  const PlaceBetInput({
    required this.goalId,
    required this.side,
    required this.amount,
  });
}
