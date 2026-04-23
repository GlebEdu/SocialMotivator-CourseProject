import '../../../../shared/services/api_client.dart';
import '../../domain/entities/create_evidence_upload_input.dart';
import '../../domain/entities/create_goal_input.dart';
import '../../domain/entities/evidence.dart';
import '../../domain/entities/evidence_submission_result.dart';
import '../../domain/entities/evidence_upload_slot.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_status.dart';
import '../../domain/entities/submit_goal_evidence_input.dart';
import '../../domain/repositories/goals_repository.dart';
import '../models/goal_read_models.dart';
import '../models/evidence_write_models.dart';
import '../models/goal_write_models.dart';

class ApiGoalsRepository implements GoalsRepository {
  ApiGoalsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Goal> createGoal(CreateGoalInput input) async {
    final payload = await _apiClient.postJson(
      '/goals',
      body: <String, dynamic>{
        'title': input.title,
        'description': input.description,
        if (input.deadline != null) 'deadline': _formatDate(input.deadline!),
      },
    );
    return CreateGoalResponseModel.fromJson(payload).goal;
  }

  Future<List<Goal>> getMyGoals() async {
    final payload = await _apiClient.getJsonList('/goals/mine');
    return payload
        .map((item) => GoalListItemModel.fromJson(_asMap(item)).goal)
        .toList(growable: false);
  }

  Future<List<GoalListItemModel>> getDiscoverGoals({
    required String filter,
  }) async {
    final payload = await _apiClient.getJsonList(
      '/goals/discover',
      queryParameters: <String, String>{'filter': filter},
    );
    return payload
        .map((item) => GoalListItemModel.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  Future<GoalDetailsReadModel?> getGoalDetails(String goalId) async {
    try {
      final payload = await _apiClient.getJson('/goals/$goalId');
      return GoalDetailsReadModel.fromJson(payload);
    } on ApiException catch (error) {
      if (error.statusCode == 404 || error.statusCode == 422) {
        return null;
      }
      rethrow;
    }
  }

  Future<Evidence?> getLatestEvidence(String goalId) async {
    final details = await getGoalDetails(goalId);
    return details?.latestEvidence;
  }

  @override
  Future<List<Goal>> getGoalsFeed() async {
    final myGoals = await getMyGoals();
    final discoverGoals = await getDiscoverGoals(filter: 'all');

    final byId = <String, Goal>{
      for (final goal in myGoals) goal.id: goal,
      for (final item in discoverGoals) item.goal.id: item.goal,
    };

    final goals = byId.values.toList(growable: false);
    goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return goals;
  }

  @override
  Future<Goal?> getGoalById(String goalId) async {
    final details = await getGoalDetails(goalId);
    return details?.goal;
  }

  @override
  Future<EvidenceUploadSlot> createEvidenceUpload(
    CreateEvidenceUploadInput input,
  ) async {
    final payload = await _apiClient.postJson(
      '/evidence/uploads',
      body: <String, dynamic>{
        'type': input.type.name,
        'fileName': input.fileName,
        if (input.mimeType != null) 'mimeType': input.mimeType,
      },
    );
    return EvidenceUploadSlotModel.fromJson(payload).toEntity();
  }

  @override
  Future<void> uploadEvidenceFile({
    required EvidenceUploadSlot upload,
    required List<int> bytes,
    String? mimeType,
  }) async {
    await _apiClient.putBytesUrl(
      upload.uploadUrl,
      bytes: bytes,
      contentType: mimeType ?? 'application/octet-stream',
    );
  }

  @override
  Future<EvidenceSubmissionResult> submitEvidence(
    SubmitGoalEvidenceInput input,
  ) async {
    final payload = await _apiClient.postJson(
      '/goals/${input.goalId}/evidence',
      body: <String, dynamic>{
        'description': input.description,
        'attachments': input.attachments
            .map(
              (attachment) => <String, dynamic>{
                'type': attachment.type.name,
                'uploadId': attachment.uploadId,
                'fileName': attachment.fileName,
                if (attachment.mimeType != null)
                  'mimeType': attachment.mimeType,
              },
            )
            .toList(growable: false),
      },
    );
    return EvidenceSubmissionResultModel.fromJson(payload).toEntity();
  }

  @override
  Future<Evidence?> getLatestEvidenceForGoal(String goalId) {
    return getLatestEvidence(goalId);
  }

  @override
  Future<Goal> updateGoalStatus({
    required String goalId,
    required GoalStatus status,
  }) {
    throw UnsupportedError(
      'Goal status updates are managed by backend arbitration.',
    );
  }

  Map<String, dynamic> _asMap(Object? value) {
    return Map<String, dynamic>.from(value as Map);
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
