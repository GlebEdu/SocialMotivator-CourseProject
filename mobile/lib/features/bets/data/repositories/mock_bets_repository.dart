import '../../../../shared/services/fake_database.dart';
import '../../domain/entities/bet.dart';
import '../../domain/entities/place_bet_input.dart';
import '../../domain/repositories/bets_repository.dart';

class MockBetsRepository implements BetsRepository {
  MockBetsRepository({FakeDatabase? database})
    : _database = database ?? FakeDatabase.instance;

  final FakeDatabase _database;

  @override
  Future<List<Bet>> getBetsForGoal(String goalId) async {
    return _database.bets.values
        .where((bet) => bet.goalId == goalId)
        .toList(growable: false);
  }

  @override
  Future<List<Bet>> getBetsForUser(String userId) async {
    return _database.bets.values
        .where((bet) => bet.userId == userId)
        .toList(growable: false);
  }

  @override
  Future<Bet> placeBet(PlaceBetInput input) async {
    final currentUserId = _database.currentUserId;
    if (currentUserId == null) {
      throw StateError('No active user session found.');
    }

    final bet = Bet(
      id: _generateId(),
      goalId: input.goalId,
      userId: currentUserId,
      side: input.side,
      amount: input.amount,
      createdAt: DateTime.now(),
    );

    _database.bets[bet.id] = bet;
    return bet;
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}
