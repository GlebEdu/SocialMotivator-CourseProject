import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/goals_provider.dart';
import '../widgets/goal_card.dart';

class GoalsFeedScreen extends ConsumerWidget {
  const GoalsFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsFeed = ref.watch(goalsFeedProvider);

    return Stack(
      children: <Widget>[
        goalsFeed.when(
          data: (goals) {
            if (goals.isEmpty) {
              return const _GoalsFeedMessage(
                icon: Icons.flag_outlined,
                title: 'No goals yet',
                description: 'Created goals will appear here.',
              );
            }

            return RefreshIndicator(
              onRefresh: () => ref.refresh(goalsFeedProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: goals.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  return GoalCard(
                    goal: goal,
                    onTap: () => context.push('/goals/${goal.id}'),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _GoalsFeedMessage(
            icon: Icons.error_outline,
            title: 'Could not load goals',
            description: error.toString(),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => context.push('/goals/create'),
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        ),
      ],
    );
  }
}

class _GoalsFeedMessage extends StatelessWidget {
  const _GoalsFeedMessage({
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
