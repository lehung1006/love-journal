import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/media/memory_video_controller_factory.dart';
import '../../../../core/media/memory_video_thumbnail_loader.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/journal_entities.dart';
import 'media_components.dart';

enum MemoryVideoCompletionAction { replay, stop }

class MemoryVideoReplayPolicy {
  MemoryVideoReplayPolicy({required this.automaticPlayCount})
    : assert(automaticPlayCount >= 0);

  final int automaticPlayCount;
  int _completedPlays = 0;

  int get completedPlays => _completedPlays;
  bool get hasAutomaticReplay => _completedPlays < automaticPlayCount;

  MemoryVideoCompletionAction registerCompletion() {
    if (!hasAutomaticReplay) {
      return MemoryVideoCompletionAction.stop;
    }

    _completedPlays += 1;
    return _completedPlays < automaticPlayCount
        ? MemoryVideoCompletionAction.replay
        : MemoryVideoCompletionAction.stop;
  }
}

class _MemoryVideoPlaybackCoordinator {
  static final Set<VoidCallback> _pauseCallbacks = <VoidCallback>{};

  static void register(VoidCallback callback) => _pauseCallbacks.add(callback);

  static void unregister(VoidCallback callback) {
    _pauseCallbacks.remove(callback);
  }

  static void pauseAll({VoidCallback? except}) {
    for (final callback in _pauseCallbacks.toList(growable: false)) {
      if (callback != except) {
        callback();
      }
    }
  }
}

class MemoryVideoThumbnail extends StatefulWidget {
  const MemoryVideoThumbnail({
    required this.uri,
    this.thumbnailUri,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String uri;
  final String? thumbnailUri;
  final BoxFit fit;

  @override
  State<MemoryVideoThumbnail> createState() => _MemoryVideoThumbnailState();
}

class _MemoryVideoThumbnailState extends State<MemoryVideoThumbnail> {
  Uint8List? _thumbnailBytes;
  bool _hasError = false;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant MemoryVideoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri ||
        oldWidget.thumbnailUri != widget.thumbnailUri) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    _thumbnailBytes = null;
    _hasError = false;
    if (widget.thumbnailUri != null) {
      if (mounted) {
        setState(() {});
      }
      return;
    }
    final bytes = await loadMemoryVideoThumbnail(widget.uri);
    if (!mounted || generation != _loadGeneration) {
      return;
    }
    setState(() {
      _thumbnailBytes = bytes;
      _hasError = bytes == null || bytes.isEmpty;
    });
  }

  @override
  void dispose() {
    _loadGeneration += 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUri = widget.thumbnailUri;
    if (thumbnailUri != null) {
      return AssetCoverImage(imagePath: thumbnailUri, fit: widget.fit);
    }
    if (_hasError) {
      return const _VideoFallback();
    }
    final bytes = _thumbnailBytes;
    if (bytes == null) {
      return const ColoredBox(
        color: AppColors.surfaceWarm,
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Image.memory(
      bytes,
      fit: widget.fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const _VideoFallback(),
    );
  }
}

class MemoryVideoPreview extends StatelessWidget {
  const MemoryVideoPreview({
    required this.uri,
    this.thumbnailUri,
    this.fit = BoxFit.cover,
    this.showPlayIcon = true,
    super.key,
  });

  final String uri;
  final String? thumbnailUri;
  final BoxFit fit;
  final bool showPlayIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MemoryVideoThumbnail(uri: uri, thumbnailUri: thumbnailUri, fit: fit),
        if (showPlayIcon)
          const Center(
            child: CircleAvatar(
              backgroundColor: Color(0xAA20191D),
              child: Icon(Icons.play_arrow_rounded, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class MemoryVideoPlayer extends StatefulWidget {
  const MemoryVideoPlayer({
    required this.uri,
    this.autoPlay = false,
    this.automaticPlayCount = 1,
    this.fit = BoxFit.contain,
    this.showControls = true,
    super.key,
  });

  final String uri;
  final bool autoPlay;
  final int automaticPlayCount;
  final BoxFit fit;
  final bool showControls;

  @override
  State<MemoryVideoPlayer> createState() => _MemoryVideoPlayerState();
}

class _MemoryVideoPlayerState extends State<MemoryVideoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  late MemoryVideoReplayPolicy _replayPolicy;
  bool _hasError = false;
  bool _completionHandled = false;
  bool _lastPlaying = false;
  int _loadGeneration = 0;
  late final VoidCallback _pauseCallback;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pauseCallback = _pauseForPeer;
    _MemoryVideoPlaybackCoordinator.register(_pauseCallback);
    _resetPolicy();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant MemoryVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri ||
        oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.automaticPlayCount != widget.automaticPlayCount) {
      _resetPolicy();
      unawaited(_load());
    }
  }

  void _resetPolicy() {
    _replayPolicy = MemoryVideoReplayPolicy(
      automaticPlayCount: widget.autoPlay ? widget.automaticPlayCount : 0,
    );
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    final previousController = _controller;
    if (previousController != null) {
      previousController.removeListener(_handleValueChanged);
      await previousController.dispose();
    }

    final controller = createMemoryVideoController(widget.uri);
    _controller = controller;
    _hasError = controller == null;
    _completionHandled = false;
    _lastPlaying = false;
    if (mounted) {
      setState(() {});
    }
    if (controller == null) {
      return;
    }

    controller.addListener(_handleValueChanged);
    try {
      await controller.initialize();
      await controller.setLooping(false);
      await controller.seekTo(Duration.zero);
      if (!mounted || generation != _loadGeneration) {
        controller.removeListener(_handleValueChanged);
        await controller.dispose();
        return;
      }
      setState(() {});
      if (widget.autoPlay) {
        _MemoryVideoPlaybackCoordinator.pauseAll(except: _pauseCallback);
        await controller.play();
      }
    } catch (_) {
      if (mounted && generation == _loadGeneration) {
        setState(() => _hasError = true);
      }
    }
  }

  void _handleValueChanged() {
    final controller = _controller;
    if (!mounted || controller == null) {
      return;
    }
    final value = controller.value;
    if (value.hasError && !_hasError) {
      setState(() => _hasError = true);
      return;
    }

    if (!value.isCompleted) {
      _completionHandled = false;
    } else if (!_completionHandled) {
      _completionHandled = true;
      unawaited(_handleCompletion(controller));
    }

    if (_lastPlaying != value.isPlaying) {
      _lastPlaying = value.isPlaying;
      setState(() {});
    }
  }

  Future<void> _handleCompletion(VideoPlayerController controller) async {
    final action = _replayPolicy.registerCompletion();
    if (action == MemoryVideoCompletionAction.replay &&
        identical(controller, _controller)) {
      await controller.seekTo(Duration.zero);
      _completionHandled = false;
      _MemoryVideoPlaybackCoordinator.pauseAll(except: _pauseCallback);
      await controller.play();
      return;
    }
    await controller.pause();
    if (mounted && identical(controller, _controller)) {
      setState(() {});
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (controller.value.isPlaying) {
      await controller.pause();
      return;
    }
    if (controller.value.isCompleted ||
        controller.value.position >= controller.value.duration) {
      await controller.seekTo(Duration.zero);
      _completionHandled = false;
    }
    _MemoryVideoPlaybackCoordinator.pauseAll(except: _pauseCallback);
    await controller.play();
  }

  void _pauseForPeer() {
    unawaited(_controller?.pause());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_controller?.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _MemoryVideoPlaybackCoordinator.unregister(_pauseCallback);
    _loadGeneration += 1;
    final controller = _controller;
    controller?.removeListener(_handleValueChanged);
    unawaited(controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_hasError) {
      return const _VideoFallback(showLabel: true);
    }
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final isPlaying = controller.value.isPlaying;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.showControls ? _togglePlayback : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: _FittedVideo(controller: controller, fit: widget.fit),
          ),
          if (widget.showControls)
            Positioned(
              right: 12,
              bottom: 12,
              child: Material(
                color: const Color(0xAA20191D),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: isPlaying ? 'Tạm dừng video' : 'Phát video',
                  onPressed: _togglePlayback,
                  color: Colors.white,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FittedVideo extends StatelessWidget {
  const _FittedVideo({required this.controller, required this.fit});

  final VideoPlayerController controller;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.size;
    return ClipRect(
      child: FittedBox(
        fit: fit,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

class _VideoFallback extends StatelessWidget {
  const _VideoFallback({this.showLabel = false});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceWarm,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off_outlined,
              color: AppColors.mutedLight,
            ),
            if (showLabel) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Không thể mở video',
                style: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> showMemoryMediaViewer({
  required BuildContext context,
  required List<MemoryMedia> media,
  int initialIndex = 0,
}) {
  if (media.isEmpty) {
    return Future.value();
  }
  _MemoryVideoPlaybackCoordinator.pauseAll();
  final safeIndex = initialIndex.clamp(0, media.length - 1);
  return Navigator.of(context, rootNavigator: true).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => MemoryMediaViewer(media: media, initialIndex: safeIndex),
    ),
  );
}

class MemoryMediaViewer extends StatefulWidget {
  const MemoryMediaViewer({
    required this.media,
    required this.initialIndex,
    super.key,
  });

  final List<MemoryMedia> media;
  final int initialIndex;

  @override
  State<MemoryMediaViewer> createState() => _MemoryMediaViewerState();
}

class _MemoryMediaViewerState extends State<MemoryMediaViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.media.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final item = widget.media[index];
              if (item.type == MemoryMediaType.video) {
                final isActive = index == _currentIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 72),
                  child: MemoryVideoPlayer(
                    key: ValueKey('${item.id}-$isActive'),
                    uri: item.uri,
                    autoPlay: isActive,
                    automaticPlayCount: 1,
                  ),
                );
              }
              return SafeArea(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: SizedBox.expand(
                    child: AssetCoverImage(
                      imagePath: item.uri,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s),
              child: Row(
                children: [
                  Material(
                    color: const Color(0x9920191D),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Đóng',
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.white,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x9920191D),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${widget.media.length}',
                      style: AppTextStyles.bodyS.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
