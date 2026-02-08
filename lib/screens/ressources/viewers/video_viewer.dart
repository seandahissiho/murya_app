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
  yt_flutter.YoutubePlayerController? _youtubeController;
  yt_iframe.YoutubePlayerController? _youtubeWebController;
  _VideoViewerError? _error;
  bool _isYoutube = false;
  double _lastProgress = 0.0;
  bool _readSent = false;
  bool fromSearch = false;
  Resource resource = Resource();
  ResourcesBloc? _resourcesBloc;
  bool _videoIsPlaying = false;

  @override
  void initState() {
    resource = widget.resource;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideo();
      final history = Beamer.of(context).beamingHistory;
      if (history.length > 1) {
        final lastBeamState = history[history.length - 2];
        final lastPath = lastBeamState.state.routeInformation.uri.path.toString(); // ← ceci est le path
        fromSearch = lastPath == AppRoutes.searchModule;
        setState(() {});
        // load resource content if needed
        if (fromSearch) {
          final resourceId = resource.id;
          if (resourceId != null && resourceId.isNotEmpty) {
            context.read<ResourcesBloc>().add(LoadResourceDetails(resourceId: resourceId));
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resourcesBloc ??= context.read<ResourcesBloc>();
  }

  @override
  void dispose() {
    _sendReadIfNeeded();
    _controller?.dispose();
    _youtubeController?.dispose();
    _youtubeWebController?.close();
    super.dispose();
  }

  Future<void> _initVideo() async {
    _error = null;
    _isYoutube = false;
    _youtubeController = null;
    _youtubeWebController = null;
    _controller = null;
    final url = resource.url;
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

    final youtubeId = yt_iframe.YoutubePlayerController.convertUrlToId(url);
    if (youtubeId != null && youtubeId.isNotEmpty) {
      setState(() {
        _isYoutube = true;
        if (kIsWeb) {
          _youtubeWebController = yt_iframe.YoutubePlayerController.fromVideoId(
            videoId: youtubeId,
            autoPlay: false,
            params: const yt_iframe.YoutubePlayerParams(
              mute: false,
              showControls: false,
              showFullscreenButton: false,
              enableCaption: false,
              enableKeyboard: true,
              showVideoAnnotations: false,
              enableJavaScript: false,
            ),
          );
        } else {
          _youtubeController = yt_flutter.YoutubePlayerController(
            initialVideoId: youtubeId,
            flags: const yt_flutter.YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
              hideControls: true,
              controlsVisibleAtStart: false,
              showLiveFullscreenButton: false,
              enableCaption: false,
            ),
          );
        }
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
      child: BlocConsumer<ResourcesBloc, ResourcesState>(
        listener: (context, state) {
          if (state is ResourceDetailsLoaded) {
            if (state.resource.id == resource.id) {
              resource = state.resource;
              _initVideo();
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  AppXReturnButton(destination: fromSearch ? AppRoutes.searchModule : AppRoutes.userRessourcesModule),
                  AppSpacing.spacing16_Box,
                  Expanded(
                    child: AppBreadcrumb(
                      items: [
                        BreadcrumbItem(
                          label: !fromSearch
                              ? AppLocalizations.of(context).mediaLibrary
                              : AppLocalizations.of(context).search_filter_resource,
                          onTap: () => navigateToPath(context,
                              to: !fromSearch ? AppRoutes.userRessourcesModule : AppRoutes.searchModule),
                        ),
                        BreadcrumbItem(label: resource.title ?? ''),
                      ],
                      inactiveTextStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      inactiveHoverTextStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary, // hover
                        decoration: TextDecoration.underline, // optionnel
                      ),
                      activeTextStyle: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      scrollable: true,
                    ),
                  ),
                  const AppXCloseButton(),
                ],
              ),
              AppSpacing.spacing40_Box,
              Expanded(
                child: _body(),
              ),
              AppSpacing.spacing40_Box,
            ],
          );
        },
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

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteSwatch,
        borderRadius: AppRadius.small,
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.spacing24),
            child: Text("Video", style: theme.textTheme.labelLarge),
          ),
          const Divider(
            height: 0,
            color: AppColors.borderLight,
            thickness: 1,
          ),
          AppSpacing.spacing40_Box,
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 811),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title ?? '',
                      // font-family: Anton;
                      // font-weight: 400;
                      // font-style: Regular;
                      // font-size: 40px;
                      // leading-trim: NONE;
                      // line-height: 56px;
                      // letter-spacing: -2%;
                      style: GoogleFonts.anton(
                        fontWeight: FontWeight.w400,
                        fontSize: 40,
                        height: 56 / 40,
                        letterSpacing: -0.02 * 40,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    AppSpacing.spacing4_Box,
                    // 6 nov.  2025
                    Text(
                      resource.createdAt?.formattedDate() ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.spacing24_Box,
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteSwatch,
                          borderRadius: AppRadius.small,
                          border: Border.all(
                            color: AppColors.borderMedium,
                            width: 1,
                          ),
                        ),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final youtubeController = _youtubeController;
                          final youtubeWebController = _youtubeWebController;
                          final controller = _controller;
                          final bool showYoutube = _isYoutube &&
                              ((kIsWeb && youtubeWebController != null) || (!kIsWeb && youtubeController != null));
                          final bool showVideo = !_isYoutube && controller != null && controller.value.isInitialized;
                          return Stack(
                            children: [
                              // Default background (image from assets)
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 80,
                                child: SizedBox(
                                  height: constraints.maxHeight - 80, // leave space for controls
                                  child: ClipRRect(
                                    borderRadius: AppRadius.small,
                                    child: Image.asset(
                                      AppImages.articleHeaderPath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              // Cover image (fallback)
                              // if (!showYoutube && !showVideo && resource.thumbnailUrl != null && resource.thumbnailUrl!.isNotEmpty)
                              //   Positioned.fill(
                              //     child: ClipRRect(
                              //       borderRadius: AppRadius.small,
                              //       child: Image.network(
                              //         resource.thumbnailUrl!,
                              //         fit: BoxFit.cover,
                              //         errorBuilder: (context, error, stackTrace) => Container(
                              //           color: AppColors.borderLight,
                              //           child: const Icon(Icons.broken_image, color: AppColors.textTertiary),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              if (showYoutube)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  bottom: 80,
                                  child: SizedBox(
                                    height: constraints.maxHeight - 80, // leave space for controls
                                    child: ClipRRect(
                                      // only top corners rounded to match background
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(AppRadius.smallRadius),
                                        topRight: Radius.circular(AppRadius.smallRadius),
                                      ),
                                      child: kIsWeb
                                          ? Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: yt_iframe.YoutubePlayer(
                                                    controller: youtubeWebController!,
                                                    keepAlive: true,
                                                  ),
                                                ),
                                                // Thumbnail fallback while loading or video not playing
                                                if (_videoIsPlaying != true)
                                                  Positioned.fill(
                                                    child: SizedBox(
                                                      height: constraints.maxHeight - 80, // leave space for controls
                                                      child: ClipRRect(
                                                        borderRadius: const BorderRadius.only(
                                                          topLeft: Radius.circular(AppRadius.smallRadius),
                                                          topRight: Radius.circular(AppRadius.smallRadius),
                                                        ),
                                                        child: Image.asset(
                                                          AppImages.articleHeaderPath,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            )
                                          : yt_flutter.YoutubePlayer(
                                              controller: youtubeController!,
                                              showVideoProgressIndicator: false,
                                              thumbnail: SizedBox(
                                                height: constraints.maxHeight - 80, // leave space for controls
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(AppRadius.smallRadius),
                                                    topRight: Radius.circular(AppRadius.smallRadius),
                                                  ),
                                                  child: Image.asset(
                                                    AppImages.articleHeaderPath,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              if (showVideo)
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: AppRadius.small,
                                    child: Center(
                                      child: AspectRatio(
                                        aspectRatio:
                                            controller.value.aspectRatio == 0 ? 16 / 9 : controller.value.aspectRatio,
                                        child: VideoPlayer(controller),
                                      ),
                                    ),
                                  ),
                                ),
                              // Player controls and timeline box overlaid at the bottom
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: _builderControlsAndTimeline(
                                  height: 80,
                                  width: constraints.maxWidth,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppSpacing.spacing40_Box,
          AppSpacing.spacing48_Box,
        ],
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

  void _updateVideoProgress(VideoPlayerController controller) {
    final duration = controller.value.duration;
    if (duration.inMilliseconds <= 0) return;
    final position = controller.value.position;
    final progress = position.inMilliseconds / duration.inMilliseconds;
    _lastProgress = progress.clamp(0.0, 1.0);
  }

  void _updateYoutubeProgress(yt_flutter.YoutubePlayerController controller) {
    final duration = controller.metadata.duration;
    if (duration.inMilliseconds <= 0) return;
    final position = controller.value.position;
    final progress = position.inMilliseconds / duration.inMilliseconds;
    _lastProgress = progress.clamp(0.0, 1.0);
  }

  void _sendReadIfNeeded() {
    if (_readSent) return;
    final resourceId = resource.id;
    if (resourceId == null || resourceId.isEmpty) return;
    final existingProgress = resource.userState?.progress;
    if (resource.userState?.readAt != null && (existingProgress == null || _lastProgress <= existingProgress + 0.01)) {
      return;
    }
    _readSent = true;
    final progress = _lastProgress > 0 ? _lastProgress : null;
    _resourcesBloc?.add(ReadResource(resourceId: resourceId, progress: progress));
  }

  _builderControlsAndTimeline({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.whiteSwatch,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.smallRadius),
          bottomRight: Radius.circular(AppRadius.smallRadius),
        ),
        border: Border.all(
          color: AppColors.borderMedium,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16, vertical: AppSpacing.spacing16),
      child: Row(
        children: [
          _buildPlayButton(),
          AppSpacing.spacing16_Box,
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: _timeline(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    if (_isYoutube) {
      if (kIsWeb) {
        final youtubeWebController = _youtubeWebController;
        if (youtubeWebController != null) {
          return yt_iframe.YoutubeValueBuilder(
            controller: youtubeWebController,
            builder: (context, value) {
              final isPlaying = value.playerState == yt_iframe.PlayerState.playing;
              final isReady = value.playerState != yt_iframe.PlayerState.unknown;
              return AppXPlayButton(
                isPlaying: isPlaying,
                onPressed: isReady ? _togglePlay : null,
              );
            },
          );
        }
      } else {
        final youtubeController = _youtubeController;
        if (youtubeController != null) {
          return ValueListenableBuilder<yt_flutter.YoutubePlayerValue>(
            valueListenable: youtubeController,
            builder: (context, value, child) {
              return AppXPlayButton(
                isPlaying: value.isPlaying,
                onPressed: value.isReady ? _togglePlay : null,
              );
            },
          );
        }
      }
    }

    final controller = _controller;
    if (controller != null) {
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return AppXPlayButton(
            isPlaying: value.isPlaying,
            onPressed: value.isInitialized ? _togglePlay : null,
          );
        },
      );
    }

    return const AppXPlayButton(isPlaying: false, onPressed: null);
  }

  void _togglePlay() {
    if (_error != null) return;
    if (_isYoutube) {
      if (kIsWeb) {
        final youtubeWebController = _youtubeWebController;
        if (youtubeWebController == null) return;
        final isPlaying = youtubeWebController.value.playerState == yt_iframe.PlayerState.playing;
        if (isPlaying) {
          _videoIsPlaying = false;
          youtubeWebController.pauseVideo();
        } else {
          _videoIsPlaying = true;
          youtubeWebController.playVideo();
        }
        setState(() {});
        return;
      } else {
        final youtubeController = _youtubeController;
        if (youtubeController == null || !youtubeController.value.isReady) return;
        if (youtubeController.value.isPlaying) {
          _videoIsPlaying = false;
          youtubeController.pause();
        } else {
          _videoIsPlaying = true;
          youtubeController.play();
        }
        setState(() {});
        return;
      }
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      _videoIsPlaying = false;
      controller.pause();
    } else {
      _videoIsPlaying = true;
      controller.play();
    }
    setState(() {});
  }

  Widget _timeline() {
    if (_isYoutube) {
      if (kIsWeb) {
        final youtubeWebController = _youtubeWebController;
        if (youtubeWebController != null) {
          return StreamBuilder<yt_iframe.YoutubeVideoState>(
            stream: youtubeWebController.videoStateStream,
            builder: (context, snapshot) {
              final position = snapshot.data?.position ?? Duration.zero;
              final duration = youtubeWebController.metadata.duration;
              return _buildTimelineUi(
                position,
                duration,
                onSeek: (newValue) => youtubeWebController.seekTo(
                  seconds: newValue / 1000.0,
                  allowSeekAhead: true,
                ),
              );
            },
          );
        }
      } else {
        final youtubeController = _youtubeController;
        if (youtubeController != null) {
          return ValueListenableBuilder<yt_flutter.YoutubePlayerValue>(
            valueListenable: youtubeController,
            builder: (context, value, child) {
              final position = value.position;
              final duration = youtubeController.metadata.duration;
              return _buildTimelineUi(
                position,
                duration,
                onSeek: (newValue) => youtubeController.seekTo(Duration(milliseconds: newValue.round())),
              );
            },
          );
        }
      }
    }

    final controller = _controller;
    if (controller != null) {
      return ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final position = value.position;
          final duration = value.duration;
          return _buildTimelineUi(
            position,
            duration,
            onSeek: (newValue) => controller.seekTo(Duration(milliseconds: newValue.round())),
          );
        },
      );
    }

    return _buildTimelineUi(Duration.zero, Duration.zero);
  }

  Widget _buildTimelineUi(Duration position, Duration duration, {void Function(double)? onSeek}) {
    final maxMillis = duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);
    final value = position.inMilliseconds.toDouble().clamp(0.0, maxMillis);
    _updateProgress(position, duration);
    final canSeek = onSeek != null && duration.inMilliseconds > 0;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Slider(
              padding: EdgeInsetsGeometry.zero,
              value: value,
              max: maxMillis,
              activeColor: AppButtonColors.primarySurfaceDefault,
              inactiveColor: AppButtonColors.secondarySurfacePressed,
              onChanged: canSeek ? (newValue) => onSeek(newValue) : null,
            ),
          ),
          AppSpacing.spacing4_Box,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("${_formatDuration(position)} / ${_formatDuration(duration)}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _updateProgress(Duration position, Duration duration) {
    if (duration.inMilliseconds <= 0) return;
    final progress = position.inMilliseconds / duration.inMilliseconds;
    _lastProgress = progress.clamp(0.0, 1.0);
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
