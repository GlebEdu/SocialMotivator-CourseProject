import '../../../../shared/services/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/profile_summary_model.dart';

class ApiProfileRepository implements ProfileRepository {
  ApiProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ProfileSummaryModel?> getProfileSummary(String userId) async {
    try {
      final payload = await _apiClient.getJson(
        '/users/$userId/profile-summary',
      );
      return ProfileSummaryModel.fromJson(payload);
    } on ApiException catch (error) {
      if (error.statusCode == 404 || error.statusCode == 422) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<List<User>> getProfiles() {
    throw UnsupportedError(
      'Listing all profiles is not available via the mobile API.',
    );
  }

  @override
  Future<User?> getUserProfile(String userId) async {
    return (await getProfileSummary(userId))?.user;
  }

  @override
  Future<User> updateUser(User user) {
    throw UnsupportedError(
      'Profile updates are not available via the mobile API.',
    );
  }
}
