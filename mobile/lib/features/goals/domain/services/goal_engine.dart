import '../../../arbitration/domain/entities/arbitration_case.dart';
import '../../../arbitration/domain/entities/arbitration_decision.dart';
import '../../../arbitration/domain/entities/arbitration_vote.dart';
import '../../../arbitration/domain/repositories/arbitration_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../bets/domain/entities/bet.dart';
import '../../../bets/domain/entities/bet_side.dart';
import '../../../bets/domain/entities/place_bet_input.dart';
import '../../../bets/domain/repositories/bets_repository.dart';
import '../../../profile/domain/entities/user.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../entities/goal.dart';
import '../entities/goal_status.dart';
import '../repositories/goals_repository.dart';

class GoalEngine {
  static const int _arbitrationMajorityThreshold = 2;
  GoalEngine({
    required AuthRepository authRepository,
    required GoalsRepository goalsRepository,
    required BetsRepository betsRepository,
    required ProfileRepository profileRepository,
    required ArbitrationRepository arbitrationRepository,
  }) : _authRepository = authRepository,
       _goalsRepository = goalsRepository,
       _betsRepository = betsRepository,
       _profileRepository = profileRepository,
       _arbitrationRepository = arbitrationRepository;

  static const int _goalSuccessRatingDelta = 15;
  static const int _goalFailureRatingDelta = -10;
  static const int _winningBetRatingDelta = 5;
  static const int _losingBetRatingDelta = -3;

  final AuthRepository _authRepository;
  final GoalsRepository _goalsRepository;
  final BetsRepository _betsRepository;
  final ProfileRepository _profileRepository;
  final ArbitrationRepository _arbitrationRepository;

  Future<Bet> placeBet(PlaceBetInput input) async {
    final currentUser = await _requireCurrentUser();
    final goal = await _requireGoal(input.goalId);

    if (goal.status != GoalStatus.active) {
      throw StateError('Bets can only be placed on active goals.');
    }

    if (_hasDeadlinePassed(goal.deadline, DateTime.now())) {
      throw StateError('Bets can only be placed before the deadline.');
    }

    return _placeBetForUser(user: currentUser, input: input);
  }

  Future<ArbitrationVote> voteArbitration(ArbitrationVote vote) async {
    final currentUser = await _requireCurrentUser();
    final arbitrationCase = await _arbitrationRepository.getArbitrationCaseById(
      vote.caseId,
    );
    if (arbitrationCase == null) {
      throw StateError('Arbitration case ${vote.caseId} was not found.');
    }

    if (arbitrationCase.decision != ArbitrationDecision.pending) {
      throw StateError('Voting is closed for arbitration case ${vote.caseId}.');
    }

    if (vote.voterUserId != currentUser.id) {
      throw StateError(
        'Arbitration votes must be submitted by the current user.',
      );
    }

    if (!arbitrationCase.arbitratorUserIds.contains(vote.voterUserId)) {
      throw StateError(
        'User ${vote.voterUserId} is not assigned to this arbitration case.',
      );
    }

    final existingVotes = await _arbitrationRepository.getVotesForCase(
      vote.caseId,
    );
    final hasAlreadyVoted = existingVotes.any(
      (existingVote) => existingVote.voterUserId == vote.voterUserId,
    );
    if (hasAlreadyVoted) {
      throw StateError(
        'User ${vote.voterUserId} has already voted on this case.',
      );
    }

    final savedVote = await _arbitrationRepository.submitVote(vote);
    final votes = <ArbitrationVote>[...existingVotes, savedVote];

    final approvedVotes = votes
        .where(
          (existingVote) =>
              existingVote.decision == ArbitrationDecision.approved,
        )
        .length;
    final rejectedVotes = votes
        .where(
          (existingVote) =>
              existingVote.decision == ArbitrationDecision.rejected,
        )
        .length;

    ArbitrationDecision nextDecision = ArbitrationDecision.pending;
    if (approvedVotes >= _arbitrationMajorityThreshold) {
      nextDecision = ArbitrationDecision.approved;
    } else if (rejectedVotes >= _arbitrationMajorityThreshold) {
      nextDecision = ArbitrationDecision.rejected;
    }

    if (nextDecision != ArbitrationDecision.pending) {
      final resolvedCase = await _arbitrationRepository.updateArbitrationCase(
        ArbitrationCase(
          id: arbitrationCase.id,
          goalId: arbitrationCase.goalId,
          createdByUserId: arbitrationCase.createdByUserId,
          arbitratorUserIds: arbitrationCase.arbitratorUserIds,
          reason: arbitrationCase.reason,
          decision: nextDecision,
          createdAt: arbitrationCase.createdAt,
          resolvedAt: DateTime.now(),
        ),
      );

      await resolveGoal(
        goalId: resolvedCase.goalId,
        status: _goalStatusForDecision(nextDecision),
      );
    }

    return savedVote;
  }

  Future<Goal> resolveGoal({
    required String goalId,
    required GoalStatus status,
  }) async {
    if (status != GoalStatus.completed &&
        status != GoalStatus.failed &&
        status != GoalStatus.cancelled) {
      throw StateError(
        'Goals can only be resolved as completed, failed, or cancelled.',
      );
    }

    final goal = await _requireGoal(goalId);
    final resolvedGoal = Goal(
      id: goal.id,
      userId: goal.userId,
      title: goal.title,
      description: goal.description,
      status: status,
      createdAt: goal.createdAt,
      deadline: goal.deadline,
    );

    final savedGoal = await _goalsRepository.updateGoalStatus(
      goalId: resolvedGoal.id,
      status: resolvedGoal.status,
    );

    if (status == GoalStatus.completed || status == GoalStatus.failed) {
      await distributeBettingPool(savedGoal);
      await updateBalancesAndRatings(savedGoal);
    }

    return savedGoal;
  }

  Future<void> distributeBettingPool(Goal goal) async {
    final winningSide = _winningSideForStatus(goal.status);
    if (winningSide == null) {
      return;
    }

    final goalBets = await _betsRepository.getBetsForGoal(goal.id);
    if (goalBets.isEmpty) {
      return;
    }

    final winningBets = goalBets
        .where((bet) => bet.side == winningSide)
        .toList(growable: false);
    if (winningBets.isEmpty) {
      return;
    }

    final totalPool = goalBets.fold<double>(0, (sum, bet) => sum + bet.amount);
    final winningPool = winningBets.fold<double>(
      0,
      (sum, bet) => sum + bet.amount,
    );

    for (final bet in winningBets) {
      final user = await _requireUser(bet.userId);
      final payout = totalPool * (bet.amount / winningPool);
      await _profileRepository.updateUser(
        User(
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          avatarUrl: user.avatarUrl,
          balance: user.balance + payout,
          rating: user.rating,
        ),
      );
    }
  }

  Future<void> updateBalancesAndRatings(Goal goal) async {
    final goalAuthor = await _requireUser(goal.userId);
    final authorRatingDelta = goal.status == GoalStatus.completed
        ? _goalSuccessRatingDelta
        : _goalFailureRatingDelta;

    await _profileRepository.updateUser(
      User(
        id: goalAuthor.id,
        email: goalAuthor.email,
        displayName: goalAuthor.displayName,
        avatarUrl: goalAuthor.avatarUrl,
        balance: goalAuthor.balance,
        rating: goalAuthor.rating + authorRatingDelta,
      ),
    );

    final winningSide = _winningSideForStatus(goal.status);
    if (winningSide == null) {
      return;
    }

    final goalBets = await _betsRepository.getBetsForGoal(goal.id);
    for (final bet in goalBets) {
      final bettor = await _requireUser(bet.userId);
      final ratingDelta = bet.side == winningSide
          ? _winningBetRatingDelta
          : _losingBetRatingDelta;

      await _profileRepository.updateUser(
        User(
          id: bettor.id,
          email: bettor.email,
          displayName: bettor.displayName,
          avatarUrl: bettor.avatarUrl,
          balance: bettor.balance,
          rating: bettor.rating + ratingDelta,
        ),
      );
    }
  }

  Future<Bet> _placeBetForUser({
    required User user,
    required PlaceBetInput input,
  }) async {
    if (input.amount <= 0) {
      throw StateError('Bet amount must be greater than zero.');
    }

    if (user.balance < input.amount) {
      throw StateError('User ${user.id} does not have enough balance.');
    }

    final bet = await _betsRepository.placeBet(input);
    await _profileRepository.updateUser(
      User(
        id: user.id,
        email: user.email,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        balance: user.balance - input.amount,
        rating: user.rating,
      ),
    );

    return bet;
  }

  Future<User> _requireCurrentUser() async {
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser == null) {
      throw StateError('No active user session found.');
    }

    return currentUser;
  }

  Future<Goal> _requireGoal(String goalId) async {
    final goal = await _goalsRepository.getGoalById(goalId);
    if (goal == null) {
      throw StateError('Goal $goalId was not found.');
    }

    return goal;
  }

  Future<User> _requireUser(String userId) async {
    final user = await _profileRepository.getUserProfile(userId);
    if (user == null) {
      throw StateError('User $userId was not found.');
    }

    return user;
  }

  bool _hasDeadlinePassed(DateTime? deadline, DateTime now) {
    if (deadline == null) {
      return false;
    }

    final deadlineEnd = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
      23,
      59,
      59,
      999,
    );
    return now.isAfter(deadlineEnd);
  }

  BetSide? _winningSideForStatus(GoalStatus status) {
    switch (status) {
      case GoalStatus.completed:
        return BetSide.forGoal;
      case GoalStatus.failed:
        return BetSide.againstGoal;
      case GoalStatus.inReview:
      case GoalStatus.active:
      case GoalStatus.cancelled:
        return null;
    }
  }

  GoalStatus _goalStatusForDecision(ArbitrationDecision decision) {
    switch (decision) {
      case ArbitrationDecision.approved:
        return GoalStatus.completed;
      case ArbitrationDecision.rejected:
        return GoalStatus.failed;
      case ArbitrationDecision.pending:
        throw StateError('Pending arbitration decision cannot resolve a goal.');
    }
  }
}
