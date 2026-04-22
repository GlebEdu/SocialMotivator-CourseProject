import '../../../../shared/services/api_client.dart';
import '../../domain/entities/arbitration_case.dart';
import '../../domain/entities/arbitration_decision.dart';
import '../../domain/entities/arbitration_vote.dart';
import '../../domain/repositories/arbitration_repository.dart';
import '../models/arbitration_details_model.dart';
import '../models/arbitration_summary_model.dart';
import '../models/arbitration_vote_response_model.dart';

class ApiArbitrationRepository implements ArbitrationRepository {
  ApiArbitrationRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ArbitrationCaseSummaryModel>> getAssignedCases({
    ArbitrationDecision? status,
  }) async {
    final payload = await _apiClient.getJsonList(
      '/arbitration/cases',
      queryParameters: <String, String>{
        if (status != null) 'status': status.name,
      },
    );
    return payload
        .map((item) => ArbitrationCaseSummaryModel.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  Future<ArbitrationCaseDetailsModel?> getCaseDetails(String caseId) async {
    try {
      final payload = await _apiClient.getJson('/arbitration/cases/$caseId');
      return ArbitrationCaseDetailsModel.fromJson(payload);
    } on ApiException catch (error) {
      if (error.statusCode == 403 ||
          error.statusCode == 404 ||
          error.statusCode == 422) {
        return null;
      }
      rethrow;
    }
  }

  Future<SubmitArbitrationVoteResponseModel> submitVoteResponse({
    required String caseId,
    required ArbitrationDecision decision,
    String? comment,
  }) async {
    final payload = await _apiClient.postJson(
      '/arbitration/cases/$caseId/votes',
      body: <String, dynamic>{
        'decision': decision.name,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment,
      },
    );
    return SubmitArbitrationVoteResponseModel.fromJson(payload);
  }

  @override
  Future<List<ArbitrationCase>> getArbitrationCases() async {
    final summaries = await getAssignedCases();
    final cases = <ArbitrationCase>[];

    for (final summary in summaries) {
      final details = await getCaseDetails(summary.id);
      if (details != null) {
        cases.add(details.arbitrationCase);
      }
    }

    return cases;
  }

  @override
  Future<ArbitrationCase?> getArbitrationCaseById(String caseId) async {
    return (await getCaseDetails(caseId))?.arbitrationCase;
  }

  @override
  Future<ArbitrationCase?> getArbitrationCaseForGoal(String goalId) async {
    final cases = await getArbitrationCases();
    for (final arbitrationCase in cases) {
      if (arbitrationCase.goalId == goalId) {
        return arbitrationCase;
      }
    }
    return null;
  }

  @override
  Future<ArbitrationCase> createArbitrationCase(
    ArbitrationCase arbitrationCase,
  ) {
    throw UnsupportedError(
      'Arbitration cases are created by backend evidence submission.',
    );
  }

  @override
  Future<List<ArbitrationVote>> getVotesForCase(String caseId) async {
    final details = await getCaseDetails(caseId);
    return details?.votes ?? const <ArbitrationVote>[];
  }

  @override
  Future<ArbitrationVote> submitVote(ArbitrationVote vote) async {
    final response = await submitVoteResponse(
      caseId: vote.caseId,
      decision: vote.decision,
      comment: vote.comment,
    );
    return response.vote;
  }

  @override
  Future<ArbitrationCase> updateArbitrationCase(
    ArbitrationCase arbitrationCase,
  ) {
    throw UnsupportedError(
      'Arbitration case updates are resolved by backend voting.',
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  return Map<String, dynamic>.from(value as Map);
}
