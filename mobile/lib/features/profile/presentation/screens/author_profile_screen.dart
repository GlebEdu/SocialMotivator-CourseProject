import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/widgets/brand_backdrop.dart';
import '../../../../app/widgets/glowing_gradient_panel.dart';
import '../../../goals/presentation/widgets/goal_card.dart';
import '../providers/profile_provider.dart';

class AuthorProfileScreen extends ConsumerWidget {
  const AuthorProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(userGoalSummaryProvider(userId));

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Профиль автора')),
        body: summaryAsync.when(
          data: (summary) {
            if (summary == null) {
              return const _AuthorProfileMessage(
                icon: Icons.person_search_outlined,
                title: 'Автор не найден',
                description: 'Этот профиль больше недоступен.',
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _AuthorProfileHeader(summary: summary),
                const SizedBox(height: 24),
                Text('Цели', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (summary.goals.isEmpty)
                  const _AuthorProfileMessage(
                    icon: Icons.flag_outlined,
                    title: 'Пока нет целей',
                    description: 'Этот автор пока не опубликовал цели.',
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
            title: 'Не удалось загрузить профиль',
            description: error.toString(),
          ),
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

    return GlowingGradientPanel(
      radius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: HabitBetTheme.accent,
            foregroundColor: HabitBetTheme.ink,
            child: Text(
              initial,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            summary.user.displayName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Выполнено ${summary.completedGoals} из ${summary.totalGoals} целей',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
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
                      label: 'Рейтинг',
                      value: summary.user.rating.toString(),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _ProfileStatCard(
                      label: 'Цели',
                      value: summary.totalGoals.toString(),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _ProfileStatCard(
                      label: 'Процент выполнения',
                      value: _completionRateLabel(summary.completionRateLabel),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _ProfileStatCard(
                      label: 'Активные цели',
                      value: summary.activeGoals.toString(),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _completionRateLabel(String value) {
    return value == 'No results yet' || value == 'Пока нет результатов'
        ? '-'
        : value;
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
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: HabitBetTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
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
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: HabitBetTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: HabitBetTheme.ink),
                ),
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
        ),
      ),
    );
  }
}
