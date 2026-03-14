import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/evidence.dart';
import '../providers/goals_provider.dart';

class UploadEvidenceScreen extends ConsumerStatefulWidget {
  const UploadEvidenceScreen({required this.goalId, super.key});

  final String goalId;

  @override
  ConsumerState<UploadEvidenceScreen> createState() =>
      _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends ConsumerState<UploadEvidenceScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _hasAttachment = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(submitEvidenceControllerProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, _) {
          final messenger = ScaffoldMessenger.of(context);
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    final currentUser = ref.watch(currentAuthenticatedUserProvider);
    final submitState = ref.watch(submitEvidenceControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Evidence')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: ListTile(
              leading: const Icon(Icons.photo_camera_back_outlined),
              title: const Text('Photo attachment'),
              subtitle: Text(
                _hasAttachment
                    ? 'Placeholder attachment selected'
                    : 'No attachment selected',
              ),
              trailing: TextButton(
                onPressed: submitState.isLoading
                    ? null
                    : () {
                        setState(() {
                          _hasAttachment = !_hasAttachment;
                        });
                      },
                child: Text(_hasAttachment ? 'Remove' : 'Attach'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Evidence title'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 4,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Evidence description',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: submitState.isLoading || currentUser == null
                ? null
                : _submit,
            child: submitState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Evidence'),
          ),
          if (currentUser == null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'You need to be signed in to submit evidence.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final currentUser = ref.read(currentAuthenticatedUserProvider);
    if (currentUser == null) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Enter an evidence title and description.'),
          ),
        );
      return;
    }

    try {
      await ref
          .read(submitEvidenceControllerProvider.notifier)
          .submitEvidence(
            Evidence(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              goalId: widget.goalId,
              submittedByUserId: currentUser.id,
              title: title,
              description: description,
              createdAt: DateTime.now(),
              attachmentUrl: _hasAttachment
                  ? 'placeholder://evidence-photo'
                  : null,
            ),
          );

      if (!mounted) {
        return;
      }

      if (Navigator.of(context).canPop()) {
        context.pop();
      } else {
        context.go('/goals/${widget.goalId}');
      }
    } catch (_) {
      // Error feedback is handled by the provider listener above.
    }
  }
}
