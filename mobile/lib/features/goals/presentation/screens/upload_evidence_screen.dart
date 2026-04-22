import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/evidence_attachment.dart';
import '../providers/goals_provider.dart';
import '../widgets/evidence_attachment_preview.dart';

class UploadEvidenceScreen extends ConsumerStatefulWidget {
  const UploadEvidenceScreen({required this.goalId, super.key});

  final String goalId;

  @override
  ConsumerState<UploadEvidenceScreen> createState() =>
      _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends ConsumerState<UploadEvidenceScreen> {
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  EvidenceAttachment? _attachment;

  @override
  void dispose() {
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Evidence Attachment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _attachment == null
                        ? 'Select a photo or video from your device.'
                        : _attachmentStatus(_attachment!),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  EvidenceAttachmentPreview(
                    attachment: _attachment,
                    emptyTitle: 'No attachment selected',
                    emptyDescription:
                        'Choose a photo or video to confirm goal completion.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: submitState.isLoading ? null : _pickPhoto,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Choose Photo'),
                      ),
                      OutlinedButton.icon(
                        onPressed: submitState.isLoading ? null : _pickVideo,
                        icon: const Icon(Icons.video_library_outlined),
                        label: const Text('Choose Video'),
                      ),
                      if (_attachment != null)
                        TextButton.icon(
                          onPressed: submitState.isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _attachment = null;
                                  });
                                },
                          icon: const Icon(Icons.close),
                          label: const Text('Remove'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 1,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Comment on completion',
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

    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Add a short comment about completing the goal.'),
          ),
        );
      return;
    }

    if (_attachment == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Attach a photo or video before submitting.'),
          ),
        );
      return;
    }

    try {
      await ref
          .read(submitEvidenceControllerProvider.notifier)
          .submitEvidence(
            goalId: widget.goalId,
            description: description,
            attachment: _attachment!,
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

  Future<void> _pickPhoto() async {
    await _pickAttachment(
      picker: () => _picker.pickImage(source: ImageSource.gallery),
      type: EvidenceAttachmentType.image,
    );
  }

  Future<void> _pickVideo() async {
    await _pickAttachment(
      picker: () => _picker.pickVideo(source: ImageSource.gallery),
      type: EvidenceAttachmentType.video,
    );
  }

  Future<void> _pickAttachment({
    required Future<XFile?> Function() picker,
    required EvidenceAttachmentType type,
  }) async {
    try {
      final file = await picker();
      if (file == null || !mounted) {
        return;
      }

      setState(() {
        _attachment = EvidenceAttachment(
          type: type,
          localPath: file.path,
          mimeType: _mimeTypeFor(file.name, type),
          fileName: file.name,
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not pick media: $error')));
    }
  }

  String _mimeTypeFor(String fileName, EvidenceAttachmentType type) {
    final extension = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : '';

    return switch ((type, extension)) {
      (EvidenceAttachmentType.image, 'png') => 'image/png',
      (EvidenceAttachmentType.image, 'heic') => 'image/heic',
      (EvidenceAttachmentType.image, 'webp') => 'image/webp',
      (EvidenceAttachmentType.image, _) => 'image/jpeg',
      (EvidenceAttachmentType.video, 'mov') => 'video/quicktime',
      (EvidenceAttachmentType.video, 'm4v') => 'video/x-m4v',
      (EvidenceAttachmentType.video, 'webm') => 'video/webm',
      (EvidenceAttachmentType.video, _) => 'video/mp4',
    };
  }

  String _attachmentStatus(EvidenceAttachment attachment) {
    return attachment.type == EvidenceAttachmentType.image
        ? 'Photo selected'
        : 'Video selected';
  }
}
