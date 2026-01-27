part of 'viewer_handler.dart';

class VideoViewer extends StatelessWidget {
  final Resource resource;
  const VideoViewer({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      mobileScreen: VideoViewerScreen(resource: resource),
      tabletScreen: VideoViewerScreen(resource: resource),
      desktopScreen: VideoViewerScreen(resource: resource),
    );
  }
}

class VideoViewerScreen extends StatefulWidget {
  final Resource resource;

  const VideoViewerScreen({super.key, required this.resource});

  @override
  State<VideoViewerScreen> createState() => _VideoViewerScreenState();
}

class _VideoViewerScreenState extends State<VideoViewerScreen> {
  VideoPlayerController? _controller;
  YoutubePlayerController? _youtubeController;
  _VideoViewerError? _error;
  bool _isYoutube = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _initVideo() async {
    final url = widget.resource.url;
    if (url == null || url.isEmpty) {
      setState(() {
        _error = _VideoViewerError.missingUrl;
      });
      return;
    }

    final uri = Uri.tryParse(url);
    final scheme = uri?.scheme.toLowerCase();
    if (uri == null || (scheme != 'http' && scheme != 'https')) {
      setState(() {
        _error = _VideoViewerError.invalidUrl;
      });
      return;
    }

    final youtubeId = YoutubePlayer.convertUrlToId(url);
    if (youtubeId != null && youtubeId.isNotEmpty) {
      setState(() {
        _isYoutube = true;
        _youtubeController = YoutubePlayerController(
          initialVideoId: youtubeId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    setState(() {
      _controller = controller;
    });
    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _VideoViewerError.loadFailed;
      });
      await controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const AppXReturnButton(destination: AppRoutes.userRessourcesModule),
                    AppSpacing.elementMarginBox,
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                navigateToPath(context, to: AppRoutes.userRessourcesModule);
                              },
                              child: Text(
                                AppLocalizations.of(context).mediaLibrary,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Text(
                            ' → ',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primaryDefault,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              widget.resource.name,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: AppColors.primaryDefault,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const AppXCloseButton(),
            ],
          ),
          AppSpacing.groupMarginBox,
          Expanded(
            child: _body(),
          ),
          AppSpacing.sectionMarginBox,
        ],
      ),
    );
  }

  Widget _body() {
    final theme = Theme.of(context);
    if (_error != null) {
      final message = _errorMessage(context);
      return Center(
        child: Text(
          message,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_isYoutube) {
      final youtubeController = _youtubeController;
      if (youtubeController == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: youtubeController,
            showVideoProgressIndicator: true,
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final double aspectRatio = controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio;

    return Center(
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(controller),
            _VideoControlsOverlay(controller: controller),
            VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.primaryFocus,
                bufferedColor: AppColors.borderMedium,
                backgroundColor: AppColors.borderLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _errorMessage(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (_error) {
      case _VideoViewerError.missingUrl:
        return localizations.videoViewerMissingUrl;
      case _VideoViewerError.invalidUrl:
        return localizations.videoViewerInvalidUrl;
      case _VideoViewerError.loadFailed:
        return localizations.videoViewerLoadFailed;
      default:
        return localizations.videoViewerLoadFailed;
    }
  }
}

class _VideoControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _VideoControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: controller.value.isPlaying
                  ? const SizedBox.shrink()
                  : Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    ),
            ),
            GestureDetector(
              onTap: () {
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  controller.play();
                }
              },
              child: Container(color: Colors.transparent),
            ),
          ],
        );
      },
    );
  }
}

enum _VideoViewerError { missingUrl, invalidUrl, loadFailed }
