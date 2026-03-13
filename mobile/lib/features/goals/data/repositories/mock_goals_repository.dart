import '../../../../shared/services/fake_database.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goals_repository.dart';

class MockGoalsRepository implements GoalsRepository {
  MockGoalsRepository({FakeDatabase? database})
    : _database = database ?? FakeDatabase.instance;

  final FakeDatabase _database;

  @override
  Future<Goal> saveGoal(Goal goal) async {
    _database.goals[goal.id] = goal;
    return goal;
  }

  @override
  Future<List<Goal>> getGoalsFeed() async {
    return _database.goals.values.toList(growable: false);
  }

  @override
  Future<Goal?> getGoalById(String goalId) async {
    return _database.goals[goalId];
  }

  @override
  Future<Evidence> submitEvidence(Evidence evidence) async {
    _database.evidence[evidence.id] = evidence;
    return evidence;
  }

  @override
  Future<Goal> updateGoal(Goal goal) async {
    _database.goals[goal.id] = goal;
    return goal;
  }
}
