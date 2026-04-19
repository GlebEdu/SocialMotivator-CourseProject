import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bets/presentation/providers/bets_provider.dart';
import '../../../bets/presentation/widgets/bet_panel.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/widgets/author_summary_card.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_status.dart';
import '../providers/goals_provider.dart';

class GoalDetailsScreen extends ConsumerWidget {
  const GoalDetailsScreen({required this.goalId, super.key});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailsProvider(goalId));
    final currentUser = ref.watch(currentAuthenticatedUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/my-goals');
            }
          },
        ),
        title: const Text('Goal Details'),
      ),
      body: goalAsync.when(
        data: (goal) {
          if (goal == null) {
            return const _GoalDetailsMessage(
              icon: Icons.search_off_outlined,
              title: 'Goal not found',
              description: 'This goal is no longer available.',
            );
          }

          final showAuthorSummary =
              currentUser == null || currentUser.id != goal.userId;
          final authorSummary = showAuthorSummary
              ? ref.watch(userGoalSummaryProvider(goal.userId))
              : const AsyncData<UserGoalSummary?>(null);
          final betSummary = ref.watch(goalBetSummaryProvider(goal.id));
          final showBetPanel =
              currentUser == null || currentUser.id != goal.userId;
          final canSubmitEvidence =
              currentUser != null &&
              currentUser.id == goal.userId &&
              goal.status == GoalStatus.active;

          return _GoalDetailsBody(
            goal: goal,
            authorSummary: authorSummary,
            betSummary: betSummary,
            showBetPanel: showBetPanel,
            canSubmitEvidence: canSubmitEvidence,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _GoalDetailsMessage(
          icon: Icons.error_outline,
          title: 'Could not load goal',
          description: error.toString(),
        ),
      ),
    );
  }
}

class _GoalDetailsBody extends StatelessWidget {
  const _GoalDetailsBody({
    required this.goal,
    required this.authorSummary,
    required this.betSummary,
    required this.showBetPanel,
    required this.canSubmitEvidence,
  });

  final Goal goal;
  final AsyncValue<UserGoalSummary?> authorSummary;
  final AsyncValue<GoalBetSummary> betSummary;
  final bool showBetPanel;
  final bool canSubmitEvidence;

  @override
  Widget build(BuildContext context) {
    final deadlineText = goal.deadline == null
        ? 'No deadline'
        : _formatDate(goal.deadline!);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(goal.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        _GoalStatusBanner(status: goal.status),
        const SizedBox(height: 16),
        AuthorSummaryCard(authorSummary: authorSummary),
        const SizedBox(height: 16),
        Text(goal.description, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('Deadline'),
            subtitle: Text(deadlineText),
          ),
        ),
        const SizedBox(height: 16),
        _GoalBetSummaryCard(betSummary: betSummary),
        if (canSubmitEvidence) ...<Widget>[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/goals/${goal.id}/evidence'),
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Submit Evidence'),
          ),
        ],
        if (showBetPanel) ...<Widget>[
          const SizedBox(height: 16),
          BetPanel(goal: goal),
        ],
      ],
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _GoalBetSummaryCard extends StatelessWidget {
  const _GoalBetSummaryCard({required this.betSummary});

  final AsyncValue<GoalBetSummary> betSummary;

  @override
  Widget build(BuildContext context) {
    return betSummary.when(
      data: (summary) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Bet Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 12) / 2;

                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        SizedBox(
                          width: itemWidth,
                          child: _GoalDetailsMetricCard(
                            label: 'Total pool',
                            value:
                                '${summary.totalPool.toStringAsFixed(0)} Coins',
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _GoalDetailsMetricCard(
                            label: 'Bets placed',
                            value: summary.goalBets.length.toString(),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _GoalDetailsMetricCard(
                            label: 'For goal',
                            value:
                                '${summary.forPool.toStringAsFixed(0)} Coins',
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _GoalDetailsMetricCard(
                            label: 'Against goal',
                            value:
                                '${summary.againstPool.toStringAsFixed(0)} Coins',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (summary.hasCurrentUserBet)
                  _CurrentUserBetSummary(summary: summary)
                else
                  Text(
                    'You have not placed a bet on this goal yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(child: Text('Loading bet activity...')),
            ],
          ),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Could not load bet activity: $error'),
        ),
      ),
    );
  }
}

class _CurrentUserBetSummary extends StatelessWidget {
  const _CurrentUserBetSummary({required this.summary});

  final GoalBetSummary summary;

  @override
  Widget build(BuildContext context) {
    final predictionLabel = summary.isCurrentUserOnlyFor
        ? 'You are betting for this goal'
        : summary.isCurrentUserOnlyAgainst
        ? 'You are betting against this goal'
        : 'You have bets on both sides';

    final detailLabel = summary.isCurrentUserOnlyFor
        ? '${summary.currentUserTotal.toStringAsFixed(0)} Coins on For'
        : summary.isCurrentUserOnlyAgainst
        ? '${summary.currentUserTotal.toStringAsFixed(0)} Coins on Against'
        : 'For ${summary.currentUserForTotal.toStringAsFixed(0)} Coins, '
              'Against ${summary.currentUserAgainstTotal.toStringAsFixed(0)} Coins';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            predictionLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detailLabel,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalDetailsMetricCard extends StatelessWidget {
  const _GoalDetailsMetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _GoalStatusBanner extends StatelessWidget {
  const _GoalStatusBanner({required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = switch (status) {
      GoalStatus.inReview => (Colors.amber.shade100, Colors.amber.shade900),
      GoalStatus.active => (Colors.green.shade100, Colors.green.shade900),
      GoalStatus.completed => (Colors.grey.shade300, Colors.grey.shade800),
      GoalStatus.failed => (Colors.red.shade100, Colors.red.shade900),
      GoalStatus.cancelled => (Colors.grey.shade200, Colors.grey.shade700),
    };

    return Chip(
      backgroundColor: backgroundColor,
      avatar: const Icon(Icons.flag_outlined, size: 18),
      label: Text(
        _labelForStatus(status),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: IconThemeData(color: foregroundColor),
    );
  }

  String _labelForStatus(GoalStatus status) {
    switch (status) {
      case GoalStatus.inReview:
        return 'In Review';
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.failed:
        return 'Failed';
      case GoalStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class _GoalDetailsMessage extends StatelessWidget {
  const _GoalDetailsMessage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
