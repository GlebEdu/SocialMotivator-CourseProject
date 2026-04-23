import 'package:flutter/material.dart';

import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_status.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.goal,
    this.onTap,
    this.badges = const <GoalCardBadge>[],
    super.key,
  });

  final Goal goal;
  final VoidCallback? onTap;
  final List<GoalCardBadge> badges;

  @override
  Widget build(BuildContext context) {
    final deadlineText = goal.deadline == null
        ? 'Без срока'
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
              if (badges.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: badges
                      .map((badge) => _GoalCardBadgeChip(badge: badge))
                      .toList(growable: false),
                ),
              ],
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
    return '$day.$month.${value.year}';
  }
}

class GoalCardBadge {
  const GoalCardBadge({
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

class _GoalStatusChip extends StatelessWidget {
  const _GoalStatusChip({required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, foregroundColor) = switch (status) {
      GoalStatus.inReview => (Colors.amber.shade100, Colors.amber.shade900),
      GoalStatus.active => (Colors.green.shade100, Colors.green.shade900),
      GoalStatus.completed => (Colors.grey.shade300, Colors.grey.shade800),
      GoalStatus.failed => (Colors.red.shade100, Colors.red.shade900),
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

class _GoalCardBadgeChip extends StatelessWidget {
  const _GoalCardBadgeChip({required this.badge});

  final GoalCardBadge badge;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = badge.backgroundColor ?? Colors.blue.shade100;
    final foregroundColor = badge.foregroundColor ?? Colors.blue.shade900;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (badge.icon != null) ...<Widget>[
            Icon(badge.icon, size: 14, color: foregroundColor),
            const SizedBox(width: 6),
          ],
          Text(
            badge.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
