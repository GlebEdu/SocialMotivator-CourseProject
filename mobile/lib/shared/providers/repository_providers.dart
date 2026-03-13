import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/arbitration/data/repositories/mock_arbitration_repository.dart';
import '../../features/arbitration/domain/repositories/arbitration_repository.dart';
import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/bets/data/repositories/mock_bets_repository.dart';
import '../../features/bets/domain/repositories/bets_repository.dart';
import '../../features/goals/data/repositories/mock_goals_repository.dart';
import '../../features/goals/domain/repositories/goals_repository.dart';
import '../../features/goals/domain/services/goal_engine.dart';
import '../../features/profile/data/repositories/mock_profile_repository.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../services/fake_database.dart';

final fakeDatabaseProvider = Provider<FakeDatabase>((ref) {
  return FakeDatabase.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(database: ref.watch(fakeDatabaseProvider));
});

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  return MockGoalsRepository(database: ref.watch(fakeDatabaseProvider));
});

final betsRepositoryProvider = Provider<BetsRepository>((ref) {
  return MockBetsRepository(database: ref.watch(fakeDatabaseProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return MockProfileRepository(database: ref.watch(fakeDatabaseProvider));
});

final arbitrationRepositoryProvider = Provider<ArbitrationRepository>((ref) {
  return MockArbitrationRepository(database: ref.watch(fakeDatabaseProvider));
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
