import '../../../../shared/services/fake_database.dart';
import '../../domain/entities/arbitration_case.dart';
import '../../domain/entities/arbitration_vote.dart';
import '../../domain/repositories/arbitration_repository.dart';

class MockArbitrationRepository implements ArbitrationRepository {
  MockArbitrationRepository({FakeDatabase? database})
    : _database = database ?? FakeDatabase.instance;

  final FakeDatabase _database;

  @override
  Future<ArbitrationCase> createArbitrationCase(
    ArbitrationCase arbitrationCase,
  ) async {
    _database.arbitrationCases[arbitrationCase.id] = arbitrationCase;
    return arbitrationCase;
  }

  @override
  Future<ArbitrationCase?> getArbitrationCaseById(String caseId) async {
    return _database.arbitrationCases[caseId];
  }

  @override
  Future<ArbitrationCase?> getArbitrationCaseForGoal(String goalId) async {
    for (final arbitrationCase in _database.arbitrationCases.values) {
      if (arbitrationCase.goalId == goalId) {
        return arbitrationCase;
      }
    }

    return null;
  }

  @override
  Future<List<ArbitrationCase>> getArbitrationCases() async {
    return _database.arbitrationCases.values.toList(growable: false);
  }

  @override
  Future<List<ArbitrationVote>> getVotesForCase(String caseId) async {
    return _database.votes.values
        .where((vote) => vote.caseId == caseId)
        .toList(growable: false);
  }

  @override
  Future<ArbitrationVote> submitVote(ArbitrationVote vote) async {
    _database.votes[vote.id] = vote;
    return vote;
  }

  @override
  Future<ArbitrationCase> updateArbitrationCase(
    ArbitrationCase arbitrationCase,
  ) async {
    _database.arbitrationCases[arbitrationCase.id] = arbitrationCase;
    return arbitrationCase;
  }
}
