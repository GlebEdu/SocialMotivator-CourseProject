import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/evidence_attachment.dart';

class EvidenceAttachmentPreview extends StatefulWidget {
  const EvidenceAttachmentPreview({
    required this.attachment,
    this.height = 220,
    this.emptyTitle = 'No attachment selected',
    this.emptyDescription = 'Add a photo or video to verify this goal.',
    super.key,
  });

  final EvidenceAttachment? attachment;
  final double height;
  final String emptyTitle;
  final String emptyDescription;

  @override
  State<EvidenceAttachmentPreview> createState() =>
      _EvidenceAttachmentPreviewState();
}

class _EvidenceAttachmentPreviewState extends State<EvidenceAttachmentPreview> {
  VideoPlayerController? _controller;
  String? _videoSource;

  @override
  void initState() {
    super.initState();
    _syncVideoController();
  }

  @override
  void didUpdateWidget(covariant EvidenceAttachmentPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sourceFor(widget.attachment) != _sourceFor(oldWidget.attachment)) {
      _syncVideoController();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attachment = widget.attachment;
    if (attachment == null) {
      return _AttachmentPlaceholder(
        icon: Icons.upload_file_outlined,
        title: widget.emptyTitle,
        description: widget.emptyDescription,
      );
    }

    final source = _sourceFor(attachment);
    if (attachment.type == EvidenceAttachmentType.image) {
      return _buildImagePreview(attachment, source);
    }

    return _buildVideoPreview(attachment, source);
  }

  Widget _buildImagePreview(EvidenceAttachment attachment, String? source) {
    if (source == null) {
      return _AttachmentPlaceholder(
        icon: Icons.broken_image_outlined,
        title: 'Image unavailable',
        description: _attachmentSummary(attachment),
      );
    }

    final imageWidget = _isRemoteSource(source)
        ? Image.network(
            source,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _AttachmentPlaceholder(
                  icon: Icons.broken_image_outlined,
                  title: 'Image unavailable',
                  description: _attachmentSummary(attachment),
                ),
          )
        : Image.file(
            File(source),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _AttachmentPlaceholder(
                  icon: Icons.broken_image_outlined,
                  title: 'Image unavailable',
                  description: _attachmentSummary(attachment),
                ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: imageWidget,
      ),
    );
  }

  Widget _buildVideoPreview(EvidenceAttachment attachment, String? source) {
    final controller = _controller;
    final isInitialized = controller?.value.isInitialized ?? false;

    if (source == null) {
      return _AttachmentPlaceholder(
        icon: Icons.videocam_off_outlined,
        title: 'Video unavailable',
        description: _attachmentSummary(attachment),
      );
    }

    if (!isInitialized) {
      return SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isPlaying = controller!.value.isPlaying;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ColoredBox(
              color: Colors.black,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            IconButton.filledTonal(
              onPressed: () {
                if (isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
                setState(() {});
              },
              icon: Icon(
                isPlaying ? Icons.pause_circle_outline : Icons.play_circle_fill,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncVideoController() async {
    final attachment = widget.attachment;
    final source = _sourceFor(attachment);

    if (attachment == null ||
        attachment.type != EvidenceAttachmentType.video ||
        source == null) {
      _videoSource = null;
      await _disposeController();
      if (mounted) {
        setState(() {});
      }
      return;
    }

    if (_videoSource == source && _controller != null) {
      return;
    }

    await _disposeController();
    _videoSource = source;

    final controller = _isRemoteSource(source)
        ? VideoPlayerController.networkUrl(Uri.parse(source))
        : VideoPlayerController.file(File(source));

    _controller = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
    } catch (_) {
      await _disposeController();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _disposeController() async {
    final controller = _controller;
    _controller = null;
    if (controller != null) {
      await controller.dispose();
    }
  }

  String? _sourceFor(EvidenceAttachment? attachment) {
    if (attachment == null) {
      return null;
    }

    final localPath = attachment.localPath;
    if (localPath != null && localPath.isNotEmpty) {
      return localPath;
    }

    final remoteUrl = attachment.remoteUrl;
    if (remoteUrl != null &&
        remoteUrl.isNotEmpty &&
        _isRemoteSource(remoteUrl)) {
      return remoteUrl;
    }

    return null;
  }

  bool _isRemoteSource(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  String _attachmentSummary(EvidenceAttachment attachment) {
    return attachment.type == EvidenceAttachmentType.image
        ? 'Image preview unavailable'
        : 'Video preview unavailable';
  }
}

class _AttachmentPlaceholder extends StatelessWidget {
  const _AttachmentPlaceholder({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
