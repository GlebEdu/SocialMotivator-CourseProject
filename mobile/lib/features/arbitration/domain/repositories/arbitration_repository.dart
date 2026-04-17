import '../entities/arbitration_case.dart';
import '../entities/arbitration_vote.dart';

abstract class ArbitrationRepository {
  Future<List<ArbitrationCase>> getArbitrationCases();

  Future<ArbitrationCase?> getArbitrationCaseById(String caseId);

  Future<ArbitrationCase?> getArbitrationCaseForGoal(String goalId);

  Future<ArbitrationCase> createArbitrationCase(
    ArbitrationCase arbitrationCase,
  );

  Future<List<ArbitrationVote>> getVotesForCase(String caseId);

  Future<ArbitrationVote> submitVote(ArbitrationVote vote);

  Future<ArbitrationCase> updateArbitrationCase(
    ArbitrationCase arbitrationCase,
  );
}
