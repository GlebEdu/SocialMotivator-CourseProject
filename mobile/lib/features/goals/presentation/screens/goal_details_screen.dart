import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bets/presentation/widgets/bet_panel.dart';
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
              context.go('/home');
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

          final showBetPanel =
              currentUser == null || currentUser.id != goal.userId;
          final canSubmitEvidence =
              currentUser != null &&
              currentUser.id == goal.userId &&
              goal.status == GoalStatus.active;

          return _GoalDetailsBody(
            goal: goal,
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
    required this.showBetPanel,
    required this.canSubmitEvidence,
  });

  final Goal goal;
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
        Text(goal.description, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('Deadline'),
            subtitle: Text(deadlineText),
          ),
        ),
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

class _GoalStatusBanner extends StatelessWidget {
  const _GoalStatusBanner({required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.flag_outlined, size: 18),
      label: Text(_labelForStatus(status)),
    );
  }

  String _labelForStatus(GoalStatus status) {
    switch (status) {
      case GoalStatus.draft:
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
