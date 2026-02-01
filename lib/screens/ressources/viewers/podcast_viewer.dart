part of 'viewer_handler.dart';

class PodcastViewer extends StatelessWidget {
  final Resource resource;
  const PodcastViewer({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      mobileScreen: PodcastViewerScreen(resource: resource),
      tabletScreen: PodcastViewerScreen(resource: resource),
      desktopScreen: PodcastViewerScreen(resource: resource),
    );
  }
}

class PodcastViewerScreen extends StatefulWidget {
  final Resource resource;

  const PodcastViewerScreen({super.key, required this.resource});

  @override
  State<PodcastViewerScreen> createState() => _PodcastViewerScreenState();
}

class _PodcastViewerScreenState extends State<PodcastViewerScreen> {
  final just_audio.AudioPlayer _player = just_audio.AudioPlayer();
  _AudioViewerError? _error;
  Duration? _duration;
  List<double>? _waveformPeaks;
  double _lastProgress = 0.0;
  bool _readSent = false;

  @override
  void initState() {
    super.initState();
    _loadWaveform();
    _initAudio();
  }

  @override
  void dispose() {
    _sendReadIfNeeded();
    _player.dispose();
    super.dispose();
  }

  Future<void> _initAudio() async {
    final url = widget.resource.url;
    if (url == null || url.isEmpty) {
      setState(() {
        _error = _AudioViewerError.missingUrl;
      });
      return;
    }

    final uri = Uri.tryParse(url);
    final scheme = uri?.scheme.toLowerCase();
    if (uri == null || (scheme != 'http' && scheme != 'https')) {
      setState(() {
        _error = _AudioViewerError.invalidUrl;
      });
      return;
    }

    try {
      final duration = await _player.setUrl(url);
      if (!mounted) return;
      setState(() {
        _duration = duration;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = _AudioViewerError.loadFailed;
      });
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
              const AppXReturnButton(destination: AppRoutes.userRessourcesModule),
              AppSpacing.spacing16_Box,
              Expanded(
                child: AppBreadcrumb(
                  items: [
                    BreadcrumbItem(
                      label: AppLocalizations.of(context).mediaLibrary,
                      onTap: () => navigateToPath(context, to: AppRoutes.userRessourcesModule),
                    ),
                    BreadcrumbItem(label: widget.resource.title ?? ''),
                  ],
                  inactiveTextStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  inactiveHoverTextStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryDefault, // hover
                    decoration: TextDecoration.underline, // optionnel
                  ),
                  activeTextStyle: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primaryDefault,
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
      ),
    );
  }

  Widget _body() {
    final theme = Theme.of(context);
    String message = '';
    if (_error != null) {
      message = _errorMessage(context);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.borderRadius28,
        border: Border.all(color: AppColors.borderMedium, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.spacing40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _titleBlock(theme),
          AppSpacing.spacing40_Box,
          _controls(theme),
          AppSpacing.spacing16_Box,
          _timeline(),
          if (_error != null) ...[
            Center(
              child: Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _titleBlock(ThemeData theme) {
    return Column(
      children: [
        Text(
          widget.resource.title ?? '',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        AppSpacing.spacing12_Box,
        Text(
          widget.resource.description ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _controls(ThemeData theme) {
    return StreamBuilder<just_audio.PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final isPlaying = state?.playing ?? false;
        final isLoading = state?.processingState == just_audio.ProcessingState.loading ||
            state?.processingState == just_audio.ProcessingState.buffering;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ControlIconButton(
              icon: Icons.replay_10,
              onTap: _seekBack,
            ),
            AppSpacing.spacing16_Box,
            _ControlIconButton(
              icon: isLoading ? Icons.hourglass_empty : (isPlaying ? Icons.pause_circle : Icons.play_circle),
              size: 64,
              onTap: isLoading || _error != null ? null : _togglePlay,
            ),
            AppSpacing.spacing16_Box,
            _ControlIconButton(
              icon: Icons.forward_10,
              onTap: _seekForward,
            ),
          ],
        );
      },
    );
  }

  Widget _timeline() {
    if (_waveformPeaks != null && _waveformPeaks!.isNotEmpty) {
      return _waveformTimeline();
    }
    return StreamBuilder<Duration>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _duration ?? Duration.zero;
        final maxMillis = duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);
        final value = position.inMilliseconds.toDouble().clamp(0.0, maxMillis);
        _updateProgress(position, duration);
        return Column(
          children: [
            Slider(
              value: value,
              max: maxMillis,
              onChanged: (newValue) {
                _player.seek(Duration(milliseconds: newValue.round()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position)),
                Text(_formatDuration(duration)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _waveformTimeline() {
    return StreamBuilder<Duration>(
      stream: _player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = _duration ?? Duration.zero;
        final progress = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;
        _updateProgress(position, duration);
        return Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  onTapDown: (details) => _seekToOffset(details.localPosition.dx, width),
                  onHorizontalDragUpdate: (details) => _seekToOffset(details.localPosition.dx, width),
                  child: SizedBox(
                    height: 84,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _WaveformPainter(
                        peaks: _waveformPeaks!,
                        progress: progress.clamp(0.0, 1.0),
                        color: AppColors.borderMedium,
                        progressColor: AppColors.primaryDefault,
                      ),
                    ),
                  ),
                );
              },
            ),
            AppSpacing.spacing12_Box,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(position)),
                Text(_formatDuration(duration)),
              ],
            ),
          ],
        );
      },
    );
  }

  void _seekToOffset(double dx, double width) {
    final duration = _duration ?? Duration.zero;
    if (duration == Duration.zero) return;
    final ratio = (dx / width).clamp(0.0, 1.0);
    _player.seek(Duration(milliseconds: (duration.inMilliseconds * ratio).round()));
  }

  void _togglePlay() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  void _seekBack() {
    final current = _player.position;
    final target = current - const Duration(seconds: 10);
    _player.seek(target < Duration.zero ? Duration.zero : target);
  }

  void _seekForward() {
    final current = _player.position;
    final duration = _duration ?? Duration.zero;
    final target = current + const Duration(seconds: 10);
    _player.seek(target > duration ? duration : target);
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

  void _sendReadIfNeeded() {
    if (_readSent) return;
    final resourceId = widget.resource.id;
    if (resourceId == null || resourceId.isEmpty) return;
    final existingProgress = widget.resource.userState?.progress;
    if (widget.resource.userState?.readAt != null &&
        (existingProgress == null || _lastProgress <= existingProgress + 0.01)) {
      return;
    }
    _readSent = true;
    final progress = _lastProgress > 0 ? _lastProgress : null;
    context.read<ResourcesBloc>().add(ReadResource(resourceId: resourceId, progress: progress));
  }

  String _errorMessage(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (_error) {
      case _AudioViewerError.missingUrl:
        return localizations.audioViewerMissingUrl;
      case _AudioViewerError.invalidUrl:
        return localizations.audioViewerInvalidUrl;
      case _AudioViewerError.loadFailed:
        return localizations.audioViewerLoadFailed;
      default:
        return localizations.audioViewerLoadFailed;
    }
  }

  void _loadWaveform() {
    final metadata = widget.resource.metadata;
    final waveform = metadata?['waveform'];
    if (waveform is Map) {
      final peaks = waveform['peaks'];
      if (peaks is List) {
        _waveformPeaks = peaks.whereType<num>().map((value) => value.toDouble().clamp(0.0, 1.0)).toList();
      }
    }
  }
}

class _ControlIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  const _ControlIconButton({
    required this.icon,
    this.size = 40,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size,
      child: Icon(
        icon,
        size: size,
        color: AppColors.primaryDefault,
      ),
    );
  }
}

enum _AudioViewerError { missingUrl, invalidUrl, loadFailed }

class _WaveformPainter extends CustomPainter {
  final List<double> peaks;
  final double progress;
  final Color color;
  final Color progressColor;

  _WaveformPainter({
    required this.peaks,
    required this.progress,
    required this.color,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (peaks.isEmpty || size.width <= 0 || size.height <= 0) {
      return;
    }
    final paint = Paint()..style = PaintingStyle.fill;
    final count = peaks.length;
    final barWidth = size.width / count;
    final gap = barWidth * 0.35;
    final actualWidth = (barWidth - gap).clamp(1.0, barWidth);
    for (var i = 0; i < count; i++) {
      final peak = peaks[i];
      final barHeight = (peak * size.height).clamp(2.0, size.height);
      final x = i * barWidth;
      final y = (size.height - barHeight) / 2;
      paint.color = (i / count) <= progress ? progressColor : color;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, actualWidth, barHeight),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.peaks != peaks ||
        oldDelegate.color != color ||
        oldDelegate.progressColor != progressColor;
  }
}
