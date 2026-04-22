import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/arbitration/data/repositories/api_arbitration_repository.dart';
import '../../features/arbitration/domain/repositories/arbitration_repository.dart';
import '../../features/auth/data/repositories/api_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/bets/data/repositories/api_bets_repository.dart';
import '../../features/bets/domain/repositories/bets_repository.dart';
import '../../features/goals/data/repositories/api_goals_repository.dart';
import '../../features/goals/domain/repositories/goals_repository.dart';
import '../../features/goals/domain/services/goal_engine.dart';
import '../../features/profile/data/repositories/api_profile_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../services/api_client.dart';
import '../services/auth_token_store.dart';

final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return const AuthTokenStore();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStore: ref.watch(authTokenStoreProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ApiAuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStore: ref.watch(authTokenStoreProvider),
  );
});

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return ApiGoalsRepository(apiClient: ref.watch(apiClientProvider));
});

final goalsReadRepositoryProvider = Provider<ApiGoalsRepository>((ref) {
  final repository = ref.watch(goalsRepositoryProvider);
  if (repository is! ApiGoalsRepository) {
    throw StateError('ApiGoalsRepository is required for goals read access.');
  }
  return repository;
});

final betsRepositoryProvider = Provider<BetsRepository>((ref) {
  return ApiBetsRepository(apiClient: ref.watch(apiClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ApiProfileRepository(apiClient: ref.watch(apiClientProvider));
});

final profileReadRepositoryProvider = Provider<ApiProfileRepository>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  if (repository is! ApiProfileRepository) {
    throw StateError(
      'ApiProfileRepository is required for profile read access.',
    );
  }
  return repository;
});

final arbitrationReadRepositoryProvider = Provider<ApiArbitrationRepository>((
  ref,
) {
  final repository = ref.watch(arbitrationRepositoryProvider);
  if (repository is! ApiArbitrationRepository) {
    throw StateError(
      'ApiArbitrationRepository is required for arbitration read access.',
    );
  }
  return repository;
});

final arbitrationRepositoryProvider = Provider<ArbitrationRepository>((ref) {
  return ApiArbitrationRepository(apiClient: ref.watch(apiClientProvider));
});

final goalEngineProvider = Provider<GoalEngine>((ref) {
  return GoalEngine(
    authRepository: ref.watch(authRepositoryProvider),
    goalsRepository: ref.watch(goalsRepositoryProvider),
    betsRepository: ref.watch(betsRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    arbitrationRepository: ref.watch(arbitrationRepositoryProvider),
  );
});
