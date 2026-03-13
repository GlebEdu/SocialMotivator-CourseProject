import '../../../profile/domain/entities/user.dart';
import '../entities/login_input.dart';
import '../entities/register_input.dart';

abstract class AuthRepository {
  Future<User> login(LoginInput input);

  Future<User> register(RegisterInput input);

  Future<User?> getCurrentUser();

  Future<void> logout();
}
