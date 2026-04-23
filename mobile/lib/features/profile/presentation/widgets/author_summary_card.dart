import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Автор', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    CircleAvatar(child: Text(initial)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            summary.user.displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Рейтинг ${summary.user.rating}',
                            style: Theme.of(context).textTheme.bodyMedium,
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
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: _AuthorMetricCard(
                            label: 'Активные цели',
                            value: summary.activeGoals.toString(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Процент выполнения: ${_completionRateLabel(summary.completionRateLabel)}',
                  style: Theme.of(context).textTheme.bodyMedium,
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
    return value == 'No results yet' ? 'Пока нет результатов' : value;
  }
}

class _AuthorMetricCard extends StatelessWidget {
  const _AuthorMetricCard({required this.label, required this.value});

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
