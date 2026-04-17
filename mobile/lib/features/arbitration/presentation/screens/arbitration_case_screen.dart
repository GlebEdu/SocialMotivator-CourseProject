import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/widgets/author_summary_card.dart';
import '../../domain/entities/arbitration_decision.dart';
import '../../domain/entities/arbitration_vote.dart';
import '../providers/arbitration_provider.dart';

class ArbitrationCaseScreen extends ConsumerWidget {
  const ArbitrationCaseScreen({required this.caseId, super.key});

  final String caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arbitrationCaseAsync = ref.watch(
      arbitrationCaseDetailsProvider(caseId),
    );

    return Scaffold(
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
        title: const Text('Arbitration Case'),
      ),
      body: arbitrationCaseAsync.when(
        data: (caseDetails) {
          if (caseDetails == null) {
            return const _ArbitrationCaseMessage(
              icon: Icons.search_off_outlined,
              title: 'Case not found',
              description: 'This arbitration case is no longer available.',
            );
          }

          return _ArbitrationCaseBody(caseDetails: caseDetails);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ArbitrationCaseMessage(
          icon: Icons.error_outline,
          title: 'Could not load case',
          description: error.toString(),
        ),
      ),
    );
  }
}

class _ArbitrationCaseBody extends ConsumerWidget {
  const _ArbitrationCaseBody({required this.caseDetails});

  final ArbitrationCaseDetails caseDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(voteArbitrationControllerProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (_) {
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Vote submitted successfully.')),
            );
        },
        error: (error, _) {
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    final currentUser = ref.watch(currentAuthenticatedUserProvider);
    final authorSummary = ref.watch(
      userGoalSummaryProvider(caseDetails.goal.userId),
    );
    final voteState = ref.watch(voteArbitrationControllerProvider);
    final canVote =
        currentUser != null &&
        caseDetails.arbitrationCase.decision == ArbitrationDecision.pending &&
        caseDetails.arbitrationCase.arbitratorUserIds.contains(currentUser.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: Text('Case ${caseDetails.arbitrationCase.id}'),
            subtitle: Text(caseDetails.goal.title),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Current Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _DecisionChip(decision: caseDetails.arbitrationCase.decision),
                const SizedBox(height: 16),
                Text(
                  'Created: ${_formatDate(caseDetails.arbitrationCase.createdAt)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (caseDetails.arbitrationCase.resolvedAt != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    'Resolved: ${_formatDate(caseDetails.arbitrationCase.resolvedAt!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        AuthorSummaryCard(authorSummary: authorSummary),
        const SizedBox(height: 12),
        _GoalReviewCard(caseDetails: caseDetails),
        const SizedBox(height: 12),
        _EvidenceReviewCard(caseDetails: caseDetails),
        const SizedBox(height: 16),
        if (canVote)
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: voteState.isLoading
                      ? null
                      : () => _submitVote(
                          ref,
                          currentUser.id,
                          ArbitrationDecision.rejected,
                        ),
                  child: const Text('Reject / Failed'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: voteState.isLoading
                      ? null
                      : () => _submitVote(
                          ref,
                          currentUser.id,
                          ArbitrationDecision.approved,
                        ),
                  child: voteState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Approve / Completed'),
                ),
              ),
            ],
          )
        else
          Text(
            caseDetails.arbitrationCase.decision == ArbitrationDecision.pending
                ? 'Voting is available only for assigned arbitrators.'
                : 'This case has already been resolved.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }

  Future<void> _submitVote(
    WidgetRef ref,
    String voterUserId,
    ArbitrationDecision decision,
  ) async {
    await ref
        .read(voteArbitrationControllerProvider.notifier)
        .vote(
          ArbitrationVote(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            caseId: caseDetails.arbitrationCase.id,
            voterUserId: voterUserId,
            decision: decision,
            createdAt: DateTime.now(),
          ),
        );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _GoalReviewCard extends StatelessWidget {
  const _GoalReviewCard({required this.caseDetails});

  final ArbitrationCaseDetails caseDetails;

  @override
  Widget build(BuildContext context) {
    final deadlineText = caseDetails.goal.deadline == null
        ? 'No deadline'
        : _formatDate(caseDetails.goal.deadline!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Goal to Verify',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              caseDetails.goal.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              caseDetails.goal.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Icon(Icons.event_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  deadlineText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _EvidenceReviewCard extends StatelessWidget {
  const _EvidenceReviewCard({required this.caseDetails});

  final ArbitrationCaseDetails caseDetails;

  @override
  Widget build(BuildContext context) {
    final evidence = caseDetails.evidence;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Submitted Evidence',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: <Widget>[
                  const Icon(Icons.photo_camera_back_outlined, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    evidence?.attachmentUrl != null
                        ? 'Photo proof placeholder attached'
                        : 'No photo proof attached',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This area will show the uploaded evidence photo once real attachments are supported.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (evidence == null)
              Text(
                'No evidence description was found for this goal.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...<Widget>[
              Text(
                evidence.title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                evidence.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Submitted: ${_formatDate(evidence.createdAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
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
        return 'Pending';
      case ArbitrationDecision.approved:
        return 'Approved';
      case ArbitrationDecision.rejected:
        return 'Rejected';
    }
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
