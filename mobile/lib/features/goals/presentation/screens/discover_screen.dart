import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/goals_provider.dart';
import '../widgets/goal_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  DiscoverGoalsFilter _selectedFilter = DiscoverGoalsFilter.all;

  @override
  Widget build(BuildContext context) {
    final discoverGoals = ref.watch(discoverGoalsProvider(_selectedFilter));

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<DiscoverGoalsFilter>(
            selected: <DiscoverGoalsFilter>{_selectedFilter},
            showSelectedIcon: false,
            expandedInsets: EdgeInsets.zero,
            segments: <ButtonSegment<DiscoverGoalsFilter>>[
              ButtonSegment<DiscoverGoalsFilter>(
                value: DiscoverGoalsFilter.all,
                label: _SegmentLabel('Все'),
              ),
              ButtonSegment<DiscoverGoalsFilter>(
                value: DiscoverGoalsFilter.predicted,
                label: _SegmentLabel('С прогнозом'),
              ),
              ButtonSegment<DiscoverGoalsFilter>(
                value: DiscoverGoalsFilter.newOnly,
                label: _SegmentLabel('Новые'),
              ),
            ],
            onSelectionChanged: (selection) {
              setState(() {
                _selectedFilter = selection.first;
              });
            },
          ),
        ),
        Expanded(
          child: discoverGoals.when(
            data: (goals) {
              if (goals.isEmpty) {
                return _DiscoverMessage(
                  icon: Icons.explore_outlined,
                  title: _emptyTitleFor(_selectedFilter),
                  description: _emptyDescriptionFor(_selectedFilter),
                );
              }

              return RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(discoverGoalsProvider(_selectedFilter).future),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: goals.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = goals[index];
                    return GoalCard(
                      goal: item.goal,
                      badges: item.hasPrediction
                          ? <GoalCardBadge>[
                              GoalCardBadge(
                                label: 'Вы прогнозировали',
                                icon: Icons.check_circle_outline,
                              ),
                            ]
                          : const <GoalCardBadge>[],
                      onTap: () => context.push('/goals/${item.goal.id}'),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _DiscoverMessage(
              icon: Icons.error_outline,
              title: 'Не удалось загрузить цели',
              description: error.toString(),
            ),
          ),
        ),
      ],
    );
  }

  String _emptyTitleFor(DiscoverGoalsFilter filter) {
    return switch (filter) {
      DiscoverGoalsFilter.all => 'Нет целей для обзора',
      DiscoverGoalsFilter.predicted => 'Пока нет целей с вашим прогнозом',
      DiscoverGoalsFilter.newOnly => 'Сейчас нет новых целей',
    };
  }

  String _emptyDescriptionFor(DiscoverGoalsFilter filter) {
    return switch (filter) {
      DiscoverGoalsFilter.all =>
        'Здесь появятся цели, созданные другими пользователями.',
      DiscoverGoalsFilter.predicted =>
        'Здесь появятся цели, на которые вы уже сделали прогноз.',
      DiscoverGoalsFilter.newOnly =>
        'Здесь появятся цели, на которые вы ещё не сделали прогноз.',
    };
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DiscoverMessage extends StatelessWidget {
  const _DiscoverMessage({
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
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
