import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        if (cases.isEmpty) {
          return const _ArbitrationMessage(
            icon: Icons.balance_outlined,
            title: 'Нет дел арбитража',
            description: 'Здесь появятся дела, которым нужна проверка.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(arbitrationListProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cases.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final arbitrationCase = cases[index];
              return _ArbitrationCaseCard(
                arbitrationCase: arbitrationCase,
                onTap: () => context.push('/arbitration/${arbitrationCase.id}'),
              );
            },
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

class _ArbitrationCaseCard extends StatelessWidget {
  const _ArbitrationCaseCard({
    required this.arbitrationCase,
    required this.onTap,
  });

  final ArbitrationCaseSummaryModel arbitrationCase;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _DecisionChip(decision: arbitrationCase.decision),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                arbitrationCase.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Icon(Icons.schedule_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(arbitrationCase.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    arbitrationCase.viewerAssignment.hasVoted
                        ? 'Голос отправлен'
                        : 'Ожидается ваш голос',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
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
}

class _DecisionChip extends StatelessWidget {
  const _DecisionChip({required this.decision});

  final ArbitrationDecision decision;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (backgroundColor, foregroundColor) = switch (decision) {
      ArbitrationDecision.pending => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      ArbitrationDecision.approved => (
        Colors.green.shade100,
        Colors.green.shade900,
      ),
      ArbitrationDecision.rejected => (
        Colors.red.shade100,
        Colors.red.shade900,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _labelForDecision(decision),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
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
