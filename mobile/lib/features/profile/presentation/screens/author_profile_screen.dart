import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../goals/presentation/widgets/goal_card.dart';
import '../providers/profile_provider.dart';

class AuthorProfileScreen extends ConsumerWidget {
  const AuthorProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(userGoalSummaryProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Author Profile')),
      body: summaryAsync.when(
        data: (summary) {
          if (summary == null) {
            return const _AuthorProfileMessage(
              icon: Icons.person_search_outlined,
              title: 'Author not found',
              description: 'This profile is no longer available.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _AuthorProfileHeader(summary: summary),
              const SizedBox(height: 24),
              Text('Goals', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (summary.goals.isEmpty)
                const _AuthorProfileMessage(
                  icon: Icons.flag_outlined,
                  title: 'No goals yet',
                  description: 'This author has not published any goals yet.',
                )
              else
                ...summary.goals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GoalCard(
                      goal: goal,
                      onTap: () => context.push('/goals/${goal.id}'),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _AuthorProfileMessage(
          icon: Icons.error_outline,
          title: 'Could not load profile',
          description: error.toString(),
        ),
      ),
    );
  }
}

class _AuthorProfileHeader extends StatelessWidget {
  const _AuthorProfileHeader({required this.summary});

  final UserGoalSummary summary;

  @override
  Widget build(BuildContext context) {
    final initial = summary.user.displayName.isEmpty
        ? '?'
        : summary.user.displayName[0].toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(radius: 28, child: Text(initial)),
            const SizedBox(height: 16),
            Text(
              summary.user.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '${summary.completedGoals}/${summary.totalGoals} goals completed',
              style: Theme.of(context).textTheme.bodyMedium,
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
                      child: _ProfileStatCard(
                        label: 'Rating',
                        value: summary.user.rating.toString(),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _ProfileStatCard(
                        label: 'Goals',
                        value: summary.totalGoals.toString(),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _ProfileStatCard(
                        label: 'Completion rate',
                        value: summary.completionRateLabel,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _ProfileStatCard(
                        label: 'Active goals',
                        value: summary.activeGoals.toString(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AuthorProfileMessage extends StatelessWidget {
  const _AuthorProfileMessage({
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
