import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_status.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    required this.goal,
    this.onTap,
    this.badges = const <GoalCardBadge>[],
    this.metrics = const <GoalCardMetric>[],
    super.key,
  });

  final Goal goal;
  final VoidCallback? onTap;
  final List<GoalCardBadge> badges;
  final List<GoalCardMetric> metrics;

  @override
  Widget build(BuildContext context) {
    final deadlineText = goal.deadline == null
        ? 'Без срока'
        : _formatDate(goal.deadline!);
    final statusTheme = _GoalStatusTheme.fromStatus(goal.status);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _borderGradient(statusTheme.foreground),
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          ...HabitBetTheme.softShadow(),
          BoxShadow(
            color: statusTheme.foreground.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: -8,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(1.2, 4.2, 1.2, 1.2),
        child: Material(
          color: HabitBetTheme.surface.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(27),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(27),
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
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _GoalStatusChip(status: goal.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    goal.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: HabitBetTheme.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: <Widget>[
                      _FooterChip(
                        icon: Icons.calendar_today_outlined,
                        label: deadlineText,
                      ),
                      ...badges.map(
                        (badge) => _GoalCardBadgeChip(badge: badge),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

  LinearGradient _borderGradient(Color color) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        color.withValues(alpha: 0.9),
        color.withValues(alpha: 0.42),
        color.withValues(alpha: 0.18),
        color.withValues(alpha: 0.38),
      ],
      stops: const <double>[0, 0.18, 0.7, 1],
    );
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

class GoalCardMetric {
  const GoalCardMetric({
    required this.label,
    required this.value,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final String value;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

class _GoalStatusChip extends StatelessWidget {
  const _GoalStatusChip({required this.status});

  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = _GoalStatusTheme.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelForStatus(status),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: theme.foreground,
          fontWeight: FontWeight.w700,
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
    final backgroundColor =
        badge.backgroundColor ?? HabitBetTheme.primary.withValues(alpha: 0.16);
    final foregroundColor = badge.foregroundColor ?? HabitBetTheme.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterChip extends StatelessWidget {
  const _FooterChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: HabitBetTheme.surfaceAlt.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: HabitBetTheme.inkSoft),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: HabitBetTheme.inkSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalStatusTheme {
  const _GoalStatusTheme({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  factory _GoalStatusTheme.fromStatus(GoalStatus status) {
    return switch (status) {
      GoalStatus.inReview => _GoalStatusTheme(
        background: const Color(0xFFF8E9C9),
        foreground: HabitBetTheme.accent,
      ),
      GoalStatus.active => _GoalStatusTheme(
        background: HabitBetTheme.primary.withValues(alpha: 0.18),
        foreground: HabitBetTheme.success,
      ),
      GoalStatus.completed => _GoalStatusTheme(
        background: HabitBetTheme.primary.withValues(alpha: 0.18),
        foreground: HabitBetTheme.primary,
      ),
      GoalStatus.failed => _GoalStatusTheme(
        background: HabitBetTheme.danger.withValues(alpha: 0.14),
        foreground: HabitBetTheme.danger,
      ),
    };
  }
}
