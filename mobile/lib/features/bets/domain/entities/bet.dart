import 'bet_side.dart';

class Bet {
  final String id;
  final String goalId;
  final String userId;
  final BetSide side;
  final double amount;
  final DateTime createdAt;

  const Bet({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.side,
    required this.amount,
    required this.createdAt,
  });
}
