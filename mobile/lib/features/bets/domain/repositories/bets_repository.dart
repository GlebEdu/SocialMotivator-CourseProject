import '../entities/bet.dart';
import '../entities/place_bet_input.dart';

abstract class BetsRepository {
  Future<Bet> placeBet(PlaceBetInput input);

  Future<List<Bet>> getBetsForGoal(String goalId);

  Future<List<Bet>> getBetsForUser(String userId);
}
