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
        title: const Text('Детали цели'),
      ),
      body: goalAsync.when(
        data: (goal) {
          if (goal == null) {
            return _GoalDetailsMessage(
              icon: Icons.search_off_outlined,
              title: 'Цель не найдена',
              description: 'Эта цель больше недоступна.',
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
          title: 'Не удалось загрузить цель',
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
        ? 'Без срока'
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
            title: const Text('Срок'),
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
            label: const Text('Отправить доказательство'),
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
    return '$day.$month.${value.year}';
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
                  'Активность ставок',
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
                            label: 'Общий банк',
                            value: _coins(summary.totalPool),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _GoalDetailsMetricCard(
                            label: 'Ставок',
                            value: summary.goalBetsCount.toString(),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _GoalDetailsMetricCard(
                            label: 'За выполнение',
                            value: _coins(summary.forPool),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _GoalDetailsMetricCard(
                            label: 'Против выполнения',
                            value: _coins(summary.againstPool),
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
                    'Вы ещё не сделали ставку на эту цель.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Загрузка ставок...')),
            ],
          ),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Не удалось загрузить ставки: $error'),
        ),
      ),
    );
  }

  String _coins(num amount) => '${amount.toStringAsFixed(0)} монет';
}

class _CurrentUserBetSummary extends StatelessWidget {
  const _CurrentUserBetSummary({required this.summary});

  final GoalBetSummary summary;

  @override
  Widget build(BuildContext context) {
    final predictionLabel = summary.isCurrentUserOnlyFor
        ? 'Вы ставите за выполнение этой цели'
        : summary.isCurrentUserOnlyAgainst
        ? 'Вы ставите против выполнения этой цели'
        : 'У вас есть ставки на обе стороны';

    final detailLabel = summary.isCurrentUserOnlyFor
        ? '${summary.currentUserTotal.toStringAsFixed(0)} монет за'
        : summary.isCurrentUserOnlyAgainst
        ? '${summary.currentUserTotal.toStringAsFixed(0)} монет против'
        : 'За: ${summary.currentUserForTotal.toStringAsFixed(0)} монет, '
              'против: ${summary.currentUserAgainstTotal.toStringAsFixed(0)} монет';

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
        return 'На проверке';
      case GoalStatus.active:
        return 'Активна';
      case GoalStatus.completed:
        return 'Выполнена';
      case GoalStatus.failed:
        return 'Провалена';
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
