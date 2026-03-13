import '../entities/user.dart';

abstract class ProfileRepository {
  Future<List<User>> getProfiles();

  Future<User?> getUserProfile(String userId);

  Future<User> updateUser(User user);
}
