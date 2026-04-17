import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/repository_providers.dart';
import '../../../profile/domain/entities/user.dart';
import '../../domain/entities/login_input.dart';
import '../../domain/entities/register_input.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, User?>(
  AuthController.new,
);

final currentAuthenticatedUserProvider = Provider<User?>((ref) {
  return ref.watch(authControllerProvider).valueOrNull;
});

final loginActionProvider = Provider<Future<void> Function(LoginInput)>((ref) {
  return ref.read(authControllerProvider.notifier).login;
});

final registerActionProvider = Provider<Future<void> Function(RegisterInput)>((
  ref,
) {
  return ref.read(authControllerProvider.notifier).register;
});

final logoutActionProvider = Provider<Future<void> Function()>((ref) {
  return ref.read(authControllerProvider.notifier).logout;
});

class AuthController extends AsyncNotifier<User?> {
  @override
  Future<User?> build() {
    return ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<void> refreshCurrentUser() async {
    final currentUser = await ref.read(authRepositoryProvider).getCurrentUser();
    state = AsyncData(currentUser);
  }

  Future<void> login(LoginInput input) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => ref.read(authRepositoryProvider).login(input),
    );
  }

  Future<void> register(RegisterInput input) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => ref.read(authRepositoryProvider).register(input),
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).logout();
      return null;
    });
  }
}
