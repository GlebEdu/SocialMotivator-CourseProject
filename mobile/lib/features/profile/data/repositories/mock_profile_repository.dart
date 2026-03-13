import '../../../../shared/services/fake_database.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  MockProfileRepository({FakeDatabase? database})
    : _database = database ?? FakeDatabase.instance;

  final FakeDatabase _database;

  @override
  Future<List<User>> getProfiles() async {
    return _database.users.values.toList(growable: false);
  }

  @override
  Future<User?> getUserProfile(String userId) async {
    return _database.users[userId];
  }

  @override
  Future<User> updateUser(User user) async {
    _database.users[user.id] = user;
    return user;
  }
}
