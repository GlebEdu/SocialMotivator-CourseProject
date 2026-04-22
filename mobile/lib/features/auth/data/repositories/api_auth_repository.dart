import '../../../../shared/services/api_client.dart';
import '../../../../shared/services/auth_token_store.dart';
import '../../../profile/domain/entities/user.dart';
import '../../domain/entities/login_input.dart';
import '../../domain/entities/register_input.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({
    required ApiClient apiClient,
    required AuthTokenStore tokenStore,
  }) : _apiClient = apiClient,
       _tokenStore = tokenStore;

  final ApiClient _apiClient;
  final AuthTokenStore _tokenStore;

  @override
  Future<User?> getCurrentUser() async {
    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final payload = await _apiClient.getJson('/profile/me');
      final user = AuthResponseModel.fromJson(<String, dynamic>{
        'accessToken': token,
        'user': payload,
      }).user;
      return user;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _tokenStore.clear();
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<User> login(LoginInput input) async {
    final payload = await _apiClient.postJson(
      '/auth/login',
      body: <String, dynamic>{'email': input.email, 'password': input.password},
      authenticated: false,
    );
    final response = AuthResponseModel.fromJson(payload);
    await _tokenStore.save(response.accessToken);
    return response.user;
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.postEmpty('/auth/logout');
    } on ApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
    } finally {
      await _tokenStore.clear();
    }
  }

  @override
  Future<User> register(RegisterInput input) async {
    final payload = await _apiClient.postJson(
      '/auth/register',
      body: <String, dynamic>{
        'displayName': input.displayName,
        'email': input.email,
        'password': input.password,
      },
      authenticated: false,
    );
    final response = AuthResponseModel.fromJson(payload);
    await _tokenStore.save(response.accessToken);
    return response.user;
  }
}
