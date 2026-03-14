import 'package:flutter/material.dart';

import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_status.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({required this.goal, this.onTap, super.key});

  final Goal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final deadlineText = goal.deadline == null
        ? 'No deadline'
        : _formatDate(goal.deadline!);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _GoalStatusChip(status: goal.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                goal.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      deadlineText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _GoalStatusChip extends StatelessWidget {
  const _GoalStatusChip({required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (backgroundColor, foregroundColor) = switch (status) {
      GoalStatus.draft => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      GoalStatus.active => (
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
      GoalStatus.completed => (Colors.green.shade100, Colors.green.shade900),
      GoalStatus.failed => (Colors.red.shade100, Colors.red.shade900),
      GoalStatus.cancelled => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelForStatus(status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
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
