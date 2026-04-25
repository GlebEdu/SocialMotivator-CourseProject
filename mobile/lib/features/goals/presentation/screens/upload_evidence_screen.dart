import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/widgets/brand_backdrop.dart';
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
  static const int _maxAttachments = 10;

  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<EvidenceAttachment> _attachments = <EvidenceAttachment>[];

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

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Загрузка доказательства')),
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
                      'Файлы доказательства',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _attachments.isEmpty
                          ? 'Выберите фото или видео из галереи или снимите их на камеру.'
                          : _attachmentsStatus(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    _EvidenceAttachmentsPreviewList(
                      attachments: _attachments,
                      onRemove: submitState.isLoading
                          ? null
                          : (index) {
                              setState(() {
                                _attachments.removeAt(index);
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: submitState.isLoading
                              ? null
                              : _showPhotoSourcePicker,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Добавить фото'),
                        ),
                        OutlinedButton.icon(
                          onPressed: submitState.isLoading
                              ? null
                              : _showVideoSourcePicker,
                          icon: const Icon(Icons.video_library_outlined),
                          label: const Text('Добавить видео'),
                        ),
                        if (_attachments.isNotEmpty)
                          TextButton.icon(
                            onPressed: submitState.isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _attachments.clear();
                                    });
                                  },
                            icon: const Icon(Icons.close),
                            label: const Text('Удалить всё'),
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
                labelText: 'Комментарий о выполнении',
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
                  : const Text('Отправить доказательство'),
            ),
            if (currentUser == null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                'Войдите, чтобы отправить доказательство.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final currentUser = ref.read(currentAuthenticatedUserProvider);
    if (currentUser == null) {
      return;
    }

    final description = _descriptionController.text.trim();

    if (_attachments.isEmpty) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Прикрепите фото или видео перед отправкой.'),
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
            attachments: List<EvidenceAttachment>.unmodifiable(_attachments),
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

  Future<void> _showPhotoSourcePicker() async {
    final source = await _showSourcePickerSheet(
      title: 'Добавить фото',
      galleryLabel: 'Выбрать из галереи',
      cameraLabel: 'Сделать фото',
      galleryIcon: Icons.photo_library_outlined,
      cameraIcon: Icons.photo_camera_outlined,
    );
    if (source == null) {
      return;
    }

    await _pickPhoto(source);
  }

  Future<void> _showVideoSourcePicker() async {
    final source = await _showSourcePickerSheet(
      title: 'Добавить видео',
      galleryLabel: 'Выбрать из галереи',
      cameraLabel: 'Снять видео',
      galleryIcon: Icons.video_library_outlined,
      cameraIcon: Icons.videocam_outlined,
    );
    if (source == null) {
      return;
    }

    await _pickVideo(source);
  }

  Future<ImageSource?> _showSourcePickerSheet({
    required String title,
    required String galleryLabel,
    required String cameraLabel,
    required IconData galleryIcon,
    required IconData cameraIcon,
  }) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(title: Text(title)),
              ListTile(
                leading: Icon(galleryIcon),
                title: Text(galleryLabel),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(cameraIcon),
                title: Text(cameraLabel),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final files = source == ImageSource.gallery
          ? await _picker.pickMultiImage()
          : await _pickSinglePhotoFromCamera();
      if (files.isEmpty || !mounted) {
        return;
      }

      _addFiles(files, EvidenceAttachmentType.image);
    } catch (error) {
      _showPickError(error);
    }
  }

  Future<List<XFile>> _pickSinglePhotoFromCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) {
      return const <XFile>[];
    }

    return <XFile>[file];
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final file = await _picker.pickVideo(source: source);
      if (file == null || !mounted) {
        return;
      }

      _addFiles(<XFile>[file], EvidenceAttachmentType.video);
    } catch (error) {
      _showPickError(error);
    }
  }

  void _addFiles(List<XFile> files, EvidenceAttachmentType type) {
    final remainingSlots = _maxAttachments - _attachments.length;
    if (remainingSlots <= 0) {
      _showAttachmentLimitMessage();
      return;
    }

    final acceptedFiles = files.take(remainingSlots).toList(growable: false);
    setState(() {
      _attachments.addAll(
        acceptedFiles.map(
          (file) => EvidenceAttachment(
            type: type,
            localPath: file.path,
            mimeType: _mimeTypeFor(file.name, type),
            fileName: file.name,
          ),
        ),
      );
    });

    if (acceptedFiles.length < files.length) {
      _showAttachmentLimitMessage();
    }
  }

  void _showPickError(Object error) {
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Не удалось выбрать медиа: $error')),
      );
  }

  void _showAttachmentLimitMessage() {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Можно прикрепить до 10 файлов.')),
      );
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

  String _attachmentsStatus() {
    final photos = _attachments
        .where((attachment) => attachment.type == EvidenceAttachmentType.image)
        .length;
    final videos = _attachments.length - photos;
    final parts = <String>[
      if (photos > 0) '$photos фото',
      if (videos > 0) '$videos видео',
    ];
    return '${parts.join(' и ')} выбрано.';
  }
}

class _EvidenceAttachmentsPreviewList extends StatelessWidget {
  const _EvidenceAttachmentsPreviewList({
    required this.attachments,
    required this.onRemove,
  });

  final List<EvidenceAttachment> attachments;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const EvidenceAttachmentPreview(
        attachment: null,
        emptyTitle: 'Файл не выбран',
        emptyDescription:
            'Выберите фото или видео, чтобы подтвердить выполнение цели.',
      );
    }

    return Column(
      children: <Widget>[
        for (final entry in attachments.indexed) ...<Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _labelFor(context, entry.$2, entry.$1),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              IconButton(
                onPressed: onRemove == null ? null : () => onRemove!(entry.$1),
                icon: const Icon(Icons.close),
                tooltip: 'Удалить файл',
              ),
            ],
          ),
          EvidenceAttachmentPreview(attachment: entry.$2, height: 180),
          if (entry.$1 != attachments.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  String _labelFor(
    BuildContext context,
    EvidenceAttachment attachment,
    int index,
  ) {
    final type = attachment.type == EvidenceAttachmentType.image
        ? 'Фото'
        : 'Видео';
    return '$type ${index + 1}';
  }
}
