import '../../features/arbitration/domain/entities/arbitration_case.dart';
import '../../features/arbitration/domain/entities/arbitration_decision.dart';
import '../../features/arbitration/domain/entities/arbitration_vote.dart';
import '../../features/bets/domain/entities/bet.dart';
import '../../features/bets/domain/entities/bet_side.dart';
import '../../features/goals/domain/entities/evidence.dart';
import '../../features/goals/domain/entities/goal.dart';
import '../../features/goals/domain/entities/goal_status.dart';
import '../../features/profile/domain/entities/user.dart';

class FakeDatabase {
  //FakeDatabase._internal();
  //Test data
  FakeDatabase._internal() {
    users.addAll(_seedUsers);
    goals.addAll(_seedGoals);
    bets.addAll(_seedBets);
    evidence.addAll(_seedEvidence);
    arbitrationCases.addAll(_seedArbitrationCases);
    votes.addAll(_seedVotes);
    currentUserId = _currentUserId;
  }

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

  static const String _currentUserId = 'user_alice';

  static final Map<String, User> _seedUsers = <String, User>{
    'user_alice': const User(
      id: 'user_alice',
      email: 'alice@habitbet.app',
      displayName: 'Alice Carter',
      balance: 1340,
      rating: 1048,
    ),
    'user_max': const User(
      id: 'user_max',
      email: 'max@habitbet.app',
      displayName: 'Max Volkov',
      balance: 920,
      rating: 1012,
    ),
    'user_nina': const User(
      id: 'user_nina',
      email: 'nina@habitbet.app',
      displayName: 'Nina Sokolova',
      balance: 1180,
      rating: 1031,
    ),
    'user_leo': const User(
      id: 'user_leo',
      email: 'leo@habitbet.app',
      displayName: 'Leo Kim',
      balance: 1505,
      rating: 1084,
    ),
  };

  static final Map<String, Goal> _seedGoals = <String, Goal>{
    'goal_alice_gym': Goal(
      id: 'goal_alice_gym',
      userId: 'user_alice',
      title: 'Gym 4 times this week',
      description:
          'I want to rebuild consistency and complete four full gym sessions this week.',
      status: GoalStatus.active,
      createdAt: DateTime(2026, 3, 12, 9),
      deadline: DateTime(2026, 3, 21),
    ),
    'goal_max_reading': Goal(
      id: 'goal_max_reading',
      userId: 'user_max',
      title: 'Read 20 pages every day',
      description:
          'Daily reading streak with a minimum of twenty pages before bed.',
      status: GoalStatus.active,
      createdAt: DateTime(2026, 3, 10, 20),
      deadline: DateTime(2026, 3, 31),
    ),
    'goal_nina_portfolio': Goal(
      id: 'goal_nina_portfolio',
      userId: 'user_nina',
      title: 'Finish my portfolio case study',
      description:
          'Evidence was submitted and the case is currently under community review.',
      status: GoalStatus.draft,
      createdAt: DateTime(2026, 3, 6, 14),
      deadline: DateTime(2026, 3, 18),
    ),
    'goal_leo_nosugar': Goal(
      id: 'goal_leo_nosugar',
      userId: 'user_leo',
      title: 'No sugar for 14 days',
      description:
          'Two weeks without desserts or sweet drinks, completed on schedule.',
      status: GoalStatus.completed,
      createdAt: DateTime(2026, 2, 20, 8),
      deadline: DateTime(2026, 3, 6),
    ),
  };

  static final Map<String, Bet> _seedBets = <String, Bet>{
    'bet_alice_support': Bet(
      id: 'bet_alice_support',
      goalId: 'goal_alice_gym',
      userId: 'user_alice',
      side: BetSide.forGoal,
      amount: 10,
      createdAt: DateTime(2026, 3, 12, 9, 2),
    ),
    'bet_max_against_alice': Bet(
      id: 'bet_max_against_alice',
      goalId: 'goal_alice_gym',
      userId: 'user_max',
      side: BetSide.againstGoal,
      amount: 40,
      createdAt: DateTime(2026, 3, 12, 11),
    ),
    'bet_leo_for_alice': Bet(
      id: 'bet_leo_for_alice',
      goalId: 'goal_alice_gym',
      userId: 'user_leo',
      side: BetSide.forGoal,
      amount: 25,
      createdAt: DateTime(2026, 3, 12, 12, 30),
    ),
    'bet_alice_for_max': Bet(
      id: 'bet_alice_for_max',
      goalId: 'goal_max_reading',
      userId: 'user_alice',
      side: BetSide.forGoal,
      amount: 35,
      createdAt: DateTime(2026, 3, 11, 19),
    ),
    'bet_nina_against_max': Bet(
      id: 'bet_nina_against_max',
      goalId: 'goal_max_reading',
      userId: 'user_nina',
      side: BetSide.againstGoal,
      amount: 20,
      createdAt: DateTime(2026, 3, 11, 20),
    ),
    'bet_leo_support': Bet(
      id: 'bet_leo_support',
      goalId: 'goal_leo_nosugar',
      userId: 'user_leo',
      side: BetSide.forGoal,
      amount: 10,
      createdAt: DateTime(2026, 2, 20, 8, 5),
    ),
    'bet_alice_for_leo': Bet(
      id: 'bet_alice_for_leo',
      goalId: 'goal_leo_nosugar',
      userId: 'user_alice',
      side: BetSide.forGoal,
      amount: 30,
      createdAt: DateTime(2026, 2, 20, 10),
    ),
  };

  static final Map<String, Evidence> _seedEvidence = <String, Evidence>{
    'evidence_nina_portfolio': Evidence(
      id: 'evidence_nina_portfolio',
      goalId: 'goal_nina_portfolio',
      submittedByUserId: 'user_nina',
      title: 'Final portfolio link',
      description:
          'Shared the updated Behance project and exported PDF case study for review.',
      createdAt: DateTime(2026, 3, 13, 16, 30),
      attachmentUrl: 'placeholder://portfolio-proof',
    ),
  };

  static final Map<String, ArbitrationCase>
  _seedArbitrationCases = <String, ArbitrationCase>{
    'case_nina_portfolio': ArbitrationCase(
      id: 'case_nina_portfolio',
      goalId: 'goal_nina_portfolio',
      createdByUserId: 'user_nina',
      arbitratorUserIds: const <String>['user_alice', 'user_max', 'user_leo'],
      reason:
          'Final portfolio link: Shared the updated Behance project and exported PDF case study for review.',
      decision: ArbitrationDecision.pending,
      createdAt: DateTime(2026, 3, 13, 16, 35),
    ),
  };

  static final Map<String, ArbitrationVote> _seedVotes =
      <String, ArbitrationVote>{
        'vote_leo_portfolio': ArbitrationVote(
          id: 'vote_leo_portfolio',
          caseId: 'case_nina_portfolio',
          voterUserId: 'user_leo',
          decision: ArbitrationDecision.approved,
          createdAt: DateTime(2026, 3, 13, 18),
          comment: 'The evidence looks complete and consistent.',
        ),
      };
}
