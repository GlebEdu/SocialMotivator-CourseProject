import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    required String displayName,
    String? avatarUrl,
    @Default(1000) double balance,
    @Default(1000) int rating,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(User entity) => UserModel(
    id: entity.id,
    email: entity.email,
    displayName: entity.displayName,
    avatarUrl: entity.avatarUrl,
    balance: entity.balance,
    rating: entity.rating,
  );

  User toEntity() => User(
    id: id,
    email: email,
    displayName: displayName,
    avatarUrl: avatarUrl,
    balance: balance,
    rating: rating,
  );
}
