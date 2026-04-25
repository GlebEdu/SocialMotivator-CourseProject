import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../providers/profile_provider.dart';

class AuthorSummaryCard extends StatelessWidget {
  const AuthorSummaryCard({
    required this.authorSummary,
    this.showViewProfile = true,
    super.key,
  });

  final AsyncValue<UserGoalSummary?> authorSummary;
  final bool showViewProfile;

  @override
  Widget build(BuildContext context) {
    return authorSummary.when(
      data: (summary) {
        if (summary == null) {
          return const SizedBox.shrink();
        }

        final initial = summary.user.displayName.isEmpty
            ? '?'
            : summary.user.displayName[0].toUpperCase();

        return Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Обзор автора',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: HabitBetTheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: HabitBetTheme.primary.withValues(
                        alpha: 0.18,
                      ),
                      foregroundColor: HabitBetTheme.ink,
                      child: Text(
                        initial,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            summary.user.displayName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Рейтинг ${summary.user.rating}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: HabitBetTheme.inkSoft),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                          child: _AuthorMetricCard(
                            label: 'Выполнено',
                            value:
                                '${summary.completedGoals}/${summary.totalGoals} целей',
                            icon: Icons.check_circle_outline,
                            color: HabitBetTheme.primary,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _AuthorMetricCard(
                            label: 'Активные цели',
                            value: summary.activeGoals.toString(),
                            icon: Icons.flash_on_outlined,
                            color: HabitBetTheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Процент выполнения: ${_completionRateLabel(summary.completionRateLabel)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: HabitBetTheme.inkSoft),
                ),
                if (showViewProfile) ...<Widget>[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          context.push('/users/${summary.user.id}'),
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Открыть профиль'),
                    ),
                  ),
                ],
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
              Expanded(child: Text('Загрузка автора...')),
            ],
          ),
        ),
      ),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Не удалось загрузить автора: $error'),
        ),
      ),
    );
  }

  String _completionRateLabel(String value) {
    return value == 'No results yet' || value == 'Пока нет результатов'
        ? '-'
        : value;
  }
}

class _AuthorMetricCard extends StatelessWidget {
  const _AuthorMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HabitBetTheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: HabitBetTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
