import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/widgets/glowing_gradient_panel.dart';
import '../../domain/entities/goal_status.dart';
import '../providers/goals_provider.dart';
import '../widgets/goal_card.dart';

class MyGoalsScreen extends ConsumerWidget {
  const MyGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myGoals = ref.watch(myGoalsProvider);

    return myGoals.when(
      data: (goals) {
        final activeGoalsCount = goals
            .where((goal) => goal.status == GoalStatus.active)
            .length;
        return RefreshIndicator(
          onRefresh: () => ref.refresh(myGoalsProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
            children: <Widget>[
              _ActiveGoalsCard(activeGoalsCount: activeGoalsCount),
              const SizedBox(height: 16),
              if (goals.isEmpty)
                _GoalsFeedMessage(
                  icon: Icons.flag_outlined,
                  title: 'Пока нет целей',
                  description: 'Пора начать строить лучшую версию себя!',
                  actionLabel: 'Создать цель',
                  onAction: () => context.push('/my-goals/create'),
                )
              else ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: () => context.push('/my-goals/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Создать цель'),
                    ),
                  ),
                ),
                ...goals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GoalCard(
                      goal: goal,
                      onTap: () => context.push('/goals/${goal.id}'),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _GoalsFeedMessage(
        icon: Icons.error_outline,
        title: 'Не удалось загрузить ваши цели',
        description: error.toString(),
      ),
    );
  }
}

class _ActiveGoalsCard extends StatelessWidget {
  const _ActiveGoalsCard({required this.activeGoalsCount});

  final int activeGoalsCount;

  @override
  Widget build(BuildContext context) {
    return GlowingGradientPanel(
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.flash_on_outlined,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Активные цели: $activeGoalsCount',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalsFeedMessage extends StatelessWidget {
  const _GoalsFeedMessage({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

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
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (actionLabel != null && onAction != null) ...<Widget>[
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
