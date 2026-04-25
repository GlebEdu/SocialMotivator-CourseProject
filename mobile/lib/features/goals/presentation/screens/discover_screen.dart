import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/widgets/glowing_gradient_panel.dart';
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
          child: Column(
            children: <Widget>[
              _DiscoverHero(filter: _selectedFilter),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: HabitBetTheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: HabitBetTheme.line),
                  boxShadow: HabitBetTheme.softShadow(),
                ),
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
            ],
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
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = goals[index];
                    return GoalCard(
                      goal: item.goal,
                      badges: item.hasPrediction
                          ? <GoalCardBadge>[
                              GoalCardBadge(
                                label: 'Прогноз сделан',
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

class _DiscoverHero extends StatelessWidget {
  const _DiscoverHero({required this.filter});

  final DiscoverGoalsFilter filter;

  @override
  Widget build(BuildContext context) {
    return GlowingGradientPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Прогнозируйте результаты других участников',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: HabitBetTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(icon, color: HabitBetTheme.success, size: 34),
                ),
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
        ),
      ),
    );
  }
}
