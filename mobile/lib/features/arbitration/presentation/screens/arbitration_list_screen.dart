import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/widgets/glowing_gradient_panel.dart';
import '../../data/models/arbitration_summary_model.dart';
import '../../domain/entities/arbitration_decision.dart';
import '../providers/arbitration_provider.dart';

class ArbitrationListScreen extends ConsumerWidget {
  const ArbitrationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arbitrationCases = ref.watch(arbitrationListProvider);

    return arbitrationCases.when(
      data: (cases) {
        return RefreshIndicator(
          onRefresh: () => ref.refresh(arbitrationListProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const _ArbitrationHero(),
              const SizedBox(height: 16),
              if (cases.isEmpty)
                const _ArbitrationMessage(
                  icon: Icons.balance_outlined,
                  title: 'Нет дел арбитража',
                  description: 'Здесь появятся цели, выполнение которых надо верифицировать',
                )
              else
                ...cases.map(
                  (arbitrationCase) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ArbitrationCaseCard(
                      arbitrationCase: arbitrationCase,
                      onTap: () =>
                          context.push('/arbitration/${arbitrationCase.id}'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ArbitrationMessage(
        icon: Icons.error_outline,
        title: 'Не удалось загрузить арбитраж',
        description: error.toString(),
      ),
    );
  }
}

class _ArbitrationHero extends StatelessWidget {
  const _ArbitrationHero();

  @override
  Widget build(BuildContext context) {
    return GlowingGradientPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Верифицируйсте выполнение целей',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ArbitrationCaseCard extends StatelessWidget {
  const _ArbitrationCaseCard({
    required this.arbitrationCase,
    required this.onTap,
  });

  final ArbitrationCaseSummaryModel arbitrationCase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final decisionTheme = _DecisionTheme.fromDecision(arbitrationCase.decision);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _borderGradient(decisionTheme.foreground),
        borderRadius: BorderRadius.circular(28),
        boxShadow: <BoxShadow>[
          ...HabitBetTheme.softShadow(),
          BoxShadow(
            color: decisionTheme.foreground.withValues(alpha: 0.12),
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
                          arbitrationCase.goalTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _DecisionChip(decision: arbitrationCase.decision),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    arbitrationCase.reason,
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
                      _StatusPill(
                        icon: Icons.schedule_outlined,
                        label: _formatDate(arbitrationCase.createdAt),
                      ),
                      _StatusPill(
                        icon: arbitrationCase.viewerAssignment.hasVoted
                            ? Icons.check_circle_outline
                            : Icons.pending_outlined,
                        label: arbitrationCase.viewerAssignment.hasVoted
                            ? 'Голос отправлен'
                            : 'Ожидается ваш голос',
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

class _DecisionChip extends StatelessWidget {
  const _DecisionChip({required this.decision});

  final ArbitrationDecision decision;

  @override
  Widget build(BuildContext context) {
    final theme = _DecisionTheme.fromDecision(decision);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelForDecision(decision),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: theme.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _labelForDecision(ArbitrationDecision decision) {
    switch (decision) {
      case ArbitrationDecision.pending:
        return 'Ожидает';
      case ArbitrationDecision.approved:
        return 'Одобрено';
      case ArbitrationDecision.rejected:
        return 'Отклонено';
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: HabitBetTheme.surfaceAlt.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: HabitBetTheme.inkSoft),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: HabitBetTheme.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _DecisionTheme {
  const _DecisionTheme({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  factory _DecisionTheme.fromDecision(ArbitrationDecision decision) {
    return switch (decision) {
      ArbitrationDecision.pending => _DecisionTheme(
        background: const Color(0xFFF8E9C9),
        foreground: HabitBetTheme.accent,
      ),
      ArbitrationDecision.approved => _DecisionTheme(
        background: HabitBetTheme.primary.withValues(alpha: 0.18),
        foreground: HabitBetTheme.success,
      ),
      ArbitrationDecision.rejected => _DecisionTheme(
        background: HabitBetTheme.danger.withValues(alpha: 0.14),
        foreground: HabitBetTheme.danger,
      ),
    };
  }
}

class _ArbitrationMessage extends StatelessWidget {
  const _ArbitrationMessage({
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
