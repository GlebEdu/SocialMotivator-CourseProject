import '../entities/evidence.dart';
import '../entities/goal.dart';

abstract class GoalsRepository {
  Future<List<Goal>> getGoalsFeed();

  Future<Goal?> getGoalById(String goalId);

  Future<Goal> saveGoal(Goal goal);

  Future<Goal> updateGoal(Goal goal);

  Future<Evidence> submitEvidence(Evidence evidence);
}
