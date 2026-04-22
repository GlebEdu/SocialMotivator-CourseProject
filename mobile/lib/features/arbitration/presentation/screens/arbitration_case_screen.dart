import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/arbitration_details_model.dart';
import '../../../goals/domain/entities/evidence_attachment.dart';
import '../../../goals/presentation/widgets/evidence_attachment_preview.dart';
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
              const SnackBar(content: Text('Vote submitted successfully.')),
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
        const SizedBox(height: 12),
        _AssignmentsCard(caseDetails: caseDetails),
        const SizedBox(height: 12),
        _VotesCard(caseDetails: caseDetails),
        const SizedBox(height: 16),
        if (canVote)
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: voteState.isLoading
                      ? null
                      : () => _submitVote(ArbitrationDecision.rejected),
                  child: const Text('Reject / Failed'),
                ),
              ),
              const SizedBox(width: 12),
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
                      : const Text('Approve / Completed'),
                ),
              ),
            ],
          )
        else
          Text(
            caseDetails.arbitrationCase.decision == ArbitrationDecision.pending
                ? caseDetails.viewerContext.hasVoted
                      ? 'Your vote has been recorded. Waiting for the remaining arbitrators.'
                      : 'Voting is available only for assigned arbitrators.'
                : 'This case has already been resolved.',
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

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _GoalReviewCard extends StatelessWidget {
  const _GoalReviewCard({required this.caseDetails});

  final ArbitrationCaseDetailsModel caseDetails;

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

  final ArbitrationCaseDetailsModel caseDetails;

  @override
  Widget build(BuildContext context) {
    final evidence = caseDetails.latestEvidence;

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
            EvidenceAttachmentPreview(
              attachment: evidence?.attachment,
              emptyTitle: 'No attachment submitted',
              emptyDescription:
                  'The author has not attached a photo or video for review.',
            ),
            const SizedBox(height: 16),
            if (evidence == null)
              Text(
                'No evidence description was found for this goal.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...<Widget>[
              Text(
                evidence.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (evidence.attachment != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _attachmentLabel(evidence.attachment!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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

  String _attachmentLabel(EvidenceAttachment attachment) {
    return attachment.type == EvidenceAttachmentType.image
        ? 'Photo attachment'
        : 'Video attachment';
  }
}

class _AssignmentsCard extends StatelessWidget {
  const _AssignmentsCard({required this.caseDetails});

  final ArbitrationCaseDetailsModel caseDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Assigned Arbitrators',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._buildAssignments(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAssignments(BuildContext context) {
    return List<Widget>.generate(caseDetails.assignments.length, (index) {
      final assignment = caseDetails.assignments[index];
      return Padding(
        padding: EdgeInsets.only(
          bottom: index == caseDetails.assignments.length - 1 ? 0 : 12,
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.person_outline, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(assignment.displayName)),
            Text(
              assignment.hasVoted ? 'Voted' : 'Pending',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    });
  }
}

class _VotesCard extends StatelessWidget {
  const _VotesCard({required this.caseDetails});

  final ArbitrationCaseDetailsModel caseDetails;

  @override
  Widget build(BuildContext context) {
    final votes = caseDetails.votes;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Vote History',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (votes.isEmpty)
              Text(
                'No votes have been submitted yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              ..._buildVotes(context, votes),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildVotes(BuildContext context, List<ArbitrationVote> votes) {
    return List<Widget>.generate(votes.length, (index) {
      final vote = votes[index];
      return Padding(
        padding: EdgeInsets.only(bottom: index == votes.length - 1 ? 0 : 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _DecisionChip(decision: vote.decision),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_displayNameForVote(vote.voterUserId)),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(vote.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (vote.comment != null && vote.comment!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        vote.comment!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String _displayNameForVote(String userId) {
    for (final assignment in caseDetails.assignments) {
      if (assignment.userId == userId) {
        return assignment.displayName;
      }
    }
    return userId;
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
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
