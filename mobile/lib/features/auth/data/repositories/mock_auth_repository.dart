import '../../../../shared/services/fake_database.dart';
import '../../../profile/domain/entities/user.dart';
import '../../domain/entities/login_input.dart';
import '../../domain/entities/register_input.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({FakeDatabase? database})
    : _database = database ?? FakeDatabase.instance;

  final FakeDatabase _database;

  @override
  Future<User?> getCurrentUser() async {
    final currentUserId = _database.currentUserId;
    if (currentUserId == null) {
      return null;
    }

    return _database.users[currentUserId];
  }

  @override
  Future<User> login(LoginInput input) async {
    final user = _database.users.values
        .where((user) => user.email == input.email)
        .firstOrNull;

    if (user == null) {
      throw StateError('User with email ${input.email} was not found.');
    }

    _database.currentUserId = user.id;
    return user;
  }

  @override
  Future<void> logout() async {
    _database.currentUserId = null;
  }

  @override
  Future<User> register(RegisterInput input) async {
    final user = User(
      id: _generateId(),
      email: input.email,
      displayName: input.displayName,
    );

    _database.users[user.id] = user;
    _database.currentUserId = user.id;

    return user;
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();
}
