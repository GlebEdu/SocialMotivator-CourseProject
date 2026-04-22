import '../../../profile/data/models/user_model.dart';
import '../../../profile/domain/entities/user.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.accessToken, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>).toEntity(),
    );
  }

  final String accessToken;
  final User user;
}
