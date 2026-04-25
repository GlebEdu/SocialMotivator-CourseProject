import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/widgets/glowing_gradient_panel.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _hasPendingLogout = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<dynamic>>(authControllerProvider, (previous, next) {
      final shouldHandleLogoutResult =
          _hasPendingLogout && previous?.isLoading == true;
      if (!shouldHandleLogoutResult) {
        return;
      }

      next.whenOrNull(
        data: (_) {
          _hasPendingLogout = false;
          context.go('/login');
        },
        error: (error, _) {
          _hasPendingLogout = false;
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final currentUser = ref.watch(currentAuthenticatedUserProvider);

    if (authState.isLoading && currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentUser == null) {
      return const _ProfileMessage(
        icon: Icons.person_off_outlined,
        title: 'Пользователь не вошёл',
        description: 'Войдите, чтобы увидеть информацию профиля.',
      );
    }

    final goalSummary = ref.watch(userGoalSummaryProvider(currentUser.id));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        GlowingGradientPanel(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                foregroundColor: Colors.white,
                child: Text(
                  currentUser.displayName.isEmpty
                      ? '?'
                      : currentUser.displayName[0].toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      currentUser.displayName,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                  child: _ProfileMetricCard(
                    label: 'Баланс',
                    value: '${currentUser.balance.toStringAsFixed(0)} монет',
                    icon: Icons.monetization_on_outlined,
                    color: HabitBetTheme.accent,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _ProfileMetricCard(
                    label: 'Рейтинг',
                    value: currentUser.rating.toString(),
                    icon: Icons.show_chart_rounded,
                    color: HabitBetTheme.primary,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        goalSummary.when(
          data: (summary) {
            if (summary == null) {
              return const SizedBox.shrink();
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    SizedBox(
                      width: itemWidth,
                      child: _ProfileMetricCard(
                        label: 'Активные цели',
                        value: summary.activeGoals.toString(),
                        icon: Icons.flash_on_outlined,
                        color: HabitBetTheme.success,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _ProfileMetricCard(
                        label: 'Выполнено',
                        value:
                            '${summary.completedGoals} из ${summary.totalGoals}',
                        icon: Icons.check_circle_outline,
                        color: HabitBetTheme.primary,
                      ),
                    ),
                  ],
                );
              },
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text('Загрузка статистики целей...')),
                ],
              ),
            ),
          ),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Не удалось загрузить статистику целей.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: HabitBetTheme.inkSoft),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: authState.isLoading ? null : _logout,
          icon: const Icon(Icons.logout),
          label: authState.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Выйти'),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    _hasPendingLogout = true;
    await ref.read(logoutActionProvider)();
  }
}

class _ProfileMetricCard extends StatelessWidget {
  const _ProfileMetricCard({
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 16),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: HabitBetTheme.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  const _ProfileMessage({
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
