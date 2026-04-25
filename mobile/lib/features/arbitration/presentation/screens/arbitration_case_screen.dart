import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/brand_backdrop.dart';
import '../../../../app/widgets/glowing_gradient_panel.dart';
import '../../data/models/arbitration_details_model.dart';
import '../../../goals/domain/entities/evidence_attachment.dart';
import '../../../goals/presentation/widgets/evidence_attachment_preview.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/widgets/author_summary_card.dart';
import '../../domain/entities/arbitration_decision.dart';
import '../providers/arbitration_provider.dart';

class ArbitrationCaseScreen extends ConsumerWidget {
  const ArbitrationCaseScreen({required this.caseId, super.key});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arbitrationCaseAsync = ref.watch(
      arbitrationCaseDetailsProvider(caseId),
    );

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/arbitration');
              }
            },
          ),
          title: const Text('Дело арбитража'),
        ),
        body: arbitrationCaseAsync.when(
          data: (caseDetails) {
            if (caseDetails == null) {
              return const _ArbitrationCaseMessage(
                icon: Icons.search_off_outlined,
                title: 'Дело не найдено',
                description: 'Это дело арбитража больше недоступно.',
              );
            }

            return _ArbitrationCaseBody(caseDetails: caseDetails);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ArbitrationCaseMessage(
            icon: Icons.error_outline,
            title: 'Не удалось загрузить дело',
            description: error.toString(),
          ),
        ),
      ),
    );
  }
}

class _ArbitrationCaseBody extends ConsumerStatefulWidget {
  const _ArbitrationCaseBody({required this.caseDetails});

  final ArbitrationCaseDetailsModel caseDetails;

  @override
  ConsumerState<_ArbitrationCaseBody> createState() =>
      _ArbitrationCaseBodyState();
}

class _ArbitrationCaseBodyState extends ConsumerState<_ArbitrationCaseBody> {
  bool _hasPendingVoteSubmission = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(voteArbitrationControllerProvider, (
      previous,
      next,
    ) {
      final shouldHandleSubmissionResult =
          _hasPendingVoteSubmission && previous?.isLoading == true;
      if (!shouldHandleSubmissionResult) {
        return;
      }

      next.whenOrNull(
        data: (_) {
          _hasPendingVoteSubmission = false;
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Голос успешно отправлен.')),
            );
        },
        error: (error, _) {
          _hasPendingVoteSubmission = false;
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    final voteState = ref.watch(voteArbitrationControllerProvider);
    final caseDetails = widget.caseDetails;
    final canVote = caseDetails.viewerContext.canVote;
    final authorSummary = AsyncData<UserGoalSummary?>(
      UserGoalSummary(
        user: caseDetails.authorSummary.user,
        goals: caseDetails.authorSummary.goals,
        totalGoalsOverride: caseDetails.authorSummary.totalGoals,
        completedGoalsOverride: caseDetails.authorSummary.completedGoals,
        activeGoalsOverride: caseDetails.authorSummary.activeGoals,
        resolvedGoalsOverride: caseDetails.authorSummary.resolvedGoals,
        completionRateOverride: caseDetails.authorSummary.completionRate,
        completionRateLabelOverride:
            caseDetails.authorSummary.completionRateLabel,
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _GoalReviewCard(caseDetails: caseDetails),
        const SizedBox(height: 16),
        AuthorSummaryCard(authorSummary: authorSummary),
        const SizedBox(height: 12),
        _EvidenceReviewCard(caseDetails: caseDetails),
        const SizedBox(height: 16),
        if (canVote)
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: voteState.isLoading
                      ? null
                      : () => _submitVote(ArbitrationDecision.approved),
                  child: voteState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Одобрить / выполнена'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC96B5C),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(
                      0xFFC96B5C,
                    ).withValues(alpha: 0.4),
                    disabledForegroundColor: Colors.white70,
                  ),
                  onPressed: voteState.isLoading
                      ? null
                      : () => _submitVote(ArbitrationDecision.rejected),
                  child: const Text('Отклонить / провалена'),
                ),
              ),
            ],
          )
        else
          Text(
            caseDetails.arbitrationCase.decision == ArbitrationDecision.pending
                ? caseDetails.viewerContext.hasVoted
                      ? 'Ваш голос записан. Ожидаем остальных арбитров.'
                      : 'Голосование доступно только назначенным арбитрам.'
                : 'Верифицирование цели завершено.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }

  Future<void> _submitVote(ArbitrationDecision decision) async {
    _hasPendingVoteSubmission = true;
    await ref
        .read(voteArbitrationControllerProvider.notifier)
        .vote(
          caseId: widget.caseDetails.arbitrationCase.id,
          decision: decision,
        );
  }
}

class _GoalReviewCard extends StatelessWidget {
  const _GoalReviewCard({required this.caseDetails});

  final ArbitrationCaseDetailsModel caseDetails;

  @override
  Widget build(BuildContext context) {
    final deadlineText = caseDetails.goal.deadline == null
        ? 'Без срока'
        : _formatDate(caseDetails.goal.deadline!);

    return GlowingGradientPanel(
      radius: 28,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Цель для проверки',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            caseDetails.goal.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            caseDetails.goal.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.event_outlined, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  deadlineText,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }
}

class _EvidenceReviewCard extends StatelessWidget {
  const _EvidenceReviewCard({required this.caseDetails});

  final ArbitrationCaseDetailsModel caseDetails;

  @override
  Widget build(BuildContext context) {
    final evidence = caseDetails.latestEvidence;
    final attachments = evidence?.attachments ?? const <EvidenceAttachment>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Отправленное доказательство',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (attachments.isEmpty)
              const EvidenceAttachmentPreview(
                attachment: null,
                emptyTitle: 'Файлы не отправлены',
                emptyDescription:
                    'Автор не прикрепил фото или видео для проверки.',
              )
            else
              for (final entry in attachments.indexed) ...<Widget>[
                EvidenceAttachmentPreview(attachment: entry.$2),
                if (entry.$1 != attachments.length - 1)
                  const SizedBox(height: 16),
              ],
            const SizedBox(height: 16),
            if (evidence == null)
              Text(
                'Описание доказательства для этой цели не найдено.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...<Widget>[
              Text(
                evidence.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (attachments.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _attachmentsSubmitted(attachments.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Отправлено: ${_formatDate(evidence.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _attachmentsSubmitted(int count) {
    return '$count ${_plural(count, 'файл', 'файла', 'файлов')} отправлено';
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day.$month.${value.year}';
  }

  String _plural(int value, String one, String few, String many) {
    final mod10 = value % 10;
    final mod100 = value % 100;
    if (mod10 == 1 && mod100 != 11) {
      return one;
    }
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return few;
    }
    return many;
  }
}

class _ArbitrationCaseMessage extends StatelessWidget {
  const _ArbitrationCaseMessage({
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
