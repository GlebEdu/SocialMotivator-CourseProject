import '../../features/arbitration/domain/entities/arbitration_case.dart';
import '../../features/arbitration/domain/entities/arbitration_vote.dart';
import '../../features/bets/domain/entities/bet.dart';
import '../../features/goals/domain/entities/evidence.dart';
import '../../features/goals/domain/entities/goal.dart';
import '../../features/profile/domain/entities/user.dart';

class FakeDatabase {
  FakeDatabase._internal();

  static final FakeDatabase _instance = FakeDatabase._internal();

  factory FakeDatabase() => _instance;

  static FakeDatabase get instance => _instance;

  final Map<String, User> users = <String, User>{};
  final Map<String, Goal> goals = <String, Goal>{};
  final Map<String, Bet> bets = <String, Bet>{};
  final Map<String, Evidence> evidence = <String, Evidence>{};
  final Map<String, ArbitrationCase> arbitrationCases =
      <String, ArbitrationCase>{};
  final Map<String, ArbitrationVote> votes = <String, ArbitrationVote>{};

  String? currentUserId;
}
