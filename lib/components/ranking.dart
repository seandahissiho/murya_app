import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/components/dropdown.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/job_ranking.dart';

class RankingChart extends StatefulWidget {
  final String jobId;
  final String? userId;

  const RankingChart({super.key, required this.jobId, this.userId});

  @override
  State<RankingChart> createState() => _RankingChartState();
}

class _RankingChartState extends State<RankingChart> {
  // ── Constants ──────────────────────────────────────────────────────────
  static const double _goldenRatio = 1.618;
  static const double _lineStrokeWidth = 7.0;
  static const double _lineInset = 2.0;
  static const double _verticalSpanFactor = 0.65;

  // ── State ──────────────────────────────────────────────────────────────
  JobRankings _ranking = JobRankings.empty();
  int _detailsLevel = 0;
  late TextEditingController _dropdownController;

  DateTime get from {
    final DateTime now = DateTime.now();
    switch (_detailsLevel) {
      case 0:
        return now.dateStart;
      case 1:
        return now.firstDayOfTheWeek;
      case 2:
        return now.firstDayOfTheMonth;
      default:
        return now.date;
    }
  }

  DateTime get to {
    final DateTime now = DateTime.now();
    switch (_detailsLevel) {
      case 0:
        return now.dateEnd;
      case 1:
        return now.lastDayOfTheWeek;
      case 2:
        return now.lastDayOfTheMonth;
      default:
        return now.date;
    }
  }

  void _loadRanking() {
    context.read<JobBloc>().add(LoadRankingForJob(
          context: context,
          jobId: widget.jobId,
          from: from,
          to: to,
        ));
  }

  @override
  void initState() {
    super.initState();
    _dropdownController = TextEditingController();
    _loadRanking();
  }

  @override
  void dispose() {
    _dropdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final options = [
      locale.ranking_per_day,
      locale.ranking_per_week,
      locale.ranking_per_month,
    ];

    // Keep dropdown text in sync with current level
    _dropdownController.text = options[_detailsLevel];

    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        if (state is UserJobDetailsLoaded) {
          _loadRanking();
        }
        if (state is JobRankingLoaded) {
          setState(() {
            _ranking = state.ranking;
            if (_ranking.isNotEmptyOrNull) {
              _ranking.rankings.sort((a, b) => a.rank.compareTo(b.rank));
            }
          });
        }
      },
      builder: (context, state) {
        final isMobile = DeviceHelper.isMobile(context);
        final currentUserId =
            widget.userId ?? context.read<ProfileBloc>().state.user.id;

        // ── Quartile rankings ──────────────────────────────────────
        final rankings = _ranking.rankings;
        final rankCount = rankings.length;
        JobRanking? firstRanking =
            rankings.firstWhereOrNull((r) => r.rank == 1);
        JobRanking? firstQuartileRanking = rankings
            .firstWhereOrNull((r) => r.rank == (rankCount / 4).ceil());
        JobRanking? secondQuartileRanking = rankings
            .firstWhereOrNull((r) => r.rank == (rankCount / 2).ceil());
        JobRanking? thirdQuartileRanking = rankings.firstWhereOrNull(
            (r) => r.rank == (3 * rankCount / 4).ceil());
        JobRanking? userRanking =
            rankings.firstWhereOrNull((r) => r.userId == currentUserId);

        // ── Percentages ───────────────────────────────────────────
        int max = rankCount + 1;
        double rankToPercent(int? rank) =>
            1.0 * (max - (rank ?? 0)) / (math.max(max, 2) - 1);

        final firstPercentage = rankToPercent(firstRanking?.rank);
        final firstQuartilePercentage =
            rankToPercent(firstQuartileRanking?.rank);
        final secondQuartilePercentage =
            rankToPercent(secondQuartileRanking?.rank);
        final thirdQuartilePercentage =
            rankToPercent(thirdQuartileRanking?.rank);
        final userPercentage = rankToPercent(userRanking?.rank);

        return Column(
          children: [
            // ── Header row ──────────────────────────────────────
            Container(
              height:
                  isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
              margin: const EdgeInsets.only(top: AppSpacing.spacing24),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacing24),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    locale.ranking,
                    style: GoogleFonts.anton(
                      fontSize: isMobile ? 24 : 32,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.6,
                    ),
                  ),
                  AppXDropdown<int>(
                    controller: _dropdownController,
                    items: options.asMap().entries.map(
                          (entry) => DropdownMenuEntry(
                            value: entry.key,
                            label: entry.value,
                          ),
                        ),
                    onSelected: (level) {
                      setState(() {
                        _detailsLevel = level!;
                        _dropdownController.text =
                            options[_detailsLevel];
                      });
                      _loadRanking();
                    },
                    shrinkWrap: false,
                    maxDropdownWidth: 150,
                    fgColor: AppColors.textPrimary,
                  ),
                ],
              ),
            ),

            // ── Chart area ──────────────────────────────────────
            // Vertical padding = ~half a card height, so cards positioned
            // at the top/bottom of the line never overflow into the header
            // or get clipped at the bottom.
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: (isMobile
                          ? mobileCTAHeight
                          : tabletAndAboveCTAHeight) /
                      2,
                ),
                child: LayoutBuilder(
                builder: (context, chartConstraints) {
                  final chartSize = Size(
                    chartConstraints.maxWidth,
                    chartConstraints.maxHeight,
                  );
                  final painter = _DiagonalLinePainter(
                    userPercentage,
                    lineInset: _lineInset,
                    verticalSpanFactor: _verticalSpanFactor,
                  );

                  Offset pos(double pct) =>
                      painter.pointOnLine(chartSize, pct);

                  final firstRank = pos(firstPercentage);
                  final firstQuartileRank = pos(firstQuartilePercentage);
                  final secondQuartileRank = pos(secondQuartilePercentage);
                  final thirdQuartileRank = pos(thirdQuartilePercentage);
                  final userRank = pos(userPercentage);

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(size: chartSize, painter: painter),
                      // First place
                      _buildPositionedCard(
                        offset: firstRank,
                        rank: 1,
                      ),
                      // First quartile
                      if (firstQuartileRanking != null)
                        _buildPositionedCard(
                          offset: firstQuartileRank,
                          rank: firstQuartileRanking.rank ?? -1,
                        ),
                      // Second quartile (median)
                      if (secondQuartileRanking != null)
                        _buildPositionedCard(
                          offset: secondQuartileRank,
                          rank: secondQuartileRanking.rank ?? -1,
                        ),
                      // Third quartile
                      if (thirdQuartileRanking != null)
                        _buildPositionedCard(
                          offset: thirdQuartileRank,
                          rank: thirdQuartileRanking.rank ?? -1,
                        ),
                      // User's rank (highlighted)
                      _buildPositionedCard(
                        offset: userRank,
                        rank: userRanking?.rank ?? -1,
                        color: AppColors.primaryFocus,
                        shadowColor: AppColors.primaryPressed,
                        imageBorderColor: AppColors.backgroundCard,
                        textColor: AppColors.textInverted,
                      ),
                    ],
                  );
                },
                ),
              ),
            ),
            AppSpacing.spacing12_Box,
          ],
        );
      },
    );
  }

  /// Helper to build a positioned [RankingCard] centered on [offset].
  Widget _buildPositionedCard({
    required Offset offset,
    required int rank,
    Color? color,
    Color? shadowColor,
    Color? imageBorderColor,
    Color? textColor,
  }) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: RankingCard(
          rank: rank,
          color: color ?? AppColors.secondaryFocus,
          shadowColor: shadowColor ?? AppColors.primaryDisabled,
          imageBorderColor: imageBorderColor ?? AppColors.backgroundCard,
          textColor: textColor ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Diagonal line painter
// ═══════════════════════════════════════════════════════════════════════════

class _DiagonalLinePainter extends CustomPainter {
  final double progress;
  final double lineInset;
  final double verticalSpanFactor;

  const _DiagonalLinePainter(
    this.progress, {
    required this.lineInset,
    required this.verticalSpanFactor,
  });

  static const double _strokeWidth = 7.0;
  static const double _maxInsetFactor = 0.45;

  double _effectiveInset(Size size, double inset) =>
      math.min(inset, math.min(size.width, size.height) * _maxInsetFactor);

  Offset _start(Size size, double inset) {
    final effectiveInset = _effectiveInset(size, inset);
    final center = Offset(size.width / 2, size.height / 2);
    final dxSpan = math.max(0.0, size.width - (2 * effectiveInset));
    final dySpan = math.max(0.0, size.height * verticalSpanFactor);
    return Offset(
      center.dx - dxSpan / 2,
      center.dy + dySpan / 2,
    );
  }

  Offset _end(Size size, double inset) {
    final effectiveInset = _effectiveInset(size, inset);
    final center = Offset(size.width / 2, size.height / 2);
    final dxSpan = math.max(0.0, size.width - (2 * effectiveInset));
    final dySpan = math.max(0.0, size.height * verticalSpanFactor);
    return Offset(
      center.dx + dxSpan / 2,
      center.dy - dySpan / 2,
    );
  }

  /// Returns a point on the **drawn** diagonal line for a given [percent]
  /// (0.0 → start / bottom-left, 1.0 → end / top-right).
  ///
  /// Uses [lineInset] so that cards sit exactly on the visible line.
  /// A small margin (5 %) is applied at both ends to keep cards from
  /// being clipped at the edges.
  Offset pointOnLine(Size size, double percent) {
    // Same diagonal as the painted line
    final start = _start(size, lineInset);
    final end = _end(size, lineInset);

    // Keep a 5 % margin at each end so edge cards stay visible
    const double edgeMargin = 0.05;
    final double clampedPercent =
        percent.clamp(edgeMargin, 1.0 - edgeMargin);

    return Offset.lerp(start, end, clampedPercent)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final start = _start(size, lineInset);
    final end = _end(size, lineInset);
    canvas.drawLine(start, end, backgroundPaint);

    final foregroundPaint = Paint()
      ..color = AppColors.primaryFocus
      ..strokeWidth = _strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final foregroundEnd = Offset.lerp(start, end, progress)!;
    canvas.drawLine(start, foregroundEnd, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalLinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.lineInset != lineInset ||
      oldDelegate.verticalSpanFactor != verticalSpanFactor;
}

// ═══════════════════════════════════════════════════════════════════════════
// Ranking card widget
// ═══════════════════════════════════════════════════════════════════════════

class RankingCard extends StatelessWidget {
  final String pictureUrl;
  final int rank;
  final Color color;
  final Color shadowColor;
  final Color imageBorderColor;
  final Color textColor;

  static const double _goldenRatio = 1.618;

  const RankingCard({
    super.key,
    this.pictureUrl = '',
    required this.rank,
    this.color = AppColors.secondaryFocus,
    this.shadowColor = AppColors.primaryDisabled,
    this.imageBorderColor = AppColors.backgroundCard,
    this.textColor = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    final avatarSize = isMobile
        ? mobileCTAHeight / _goldenRatio
        : tabletAndAboveCTAHeight / _goldenRatio;
    final iconSize = isMobile
        ? mobileCTAHeight / 2
        : tabletAndAboveCTAHeight / 2;

    return FittedBox(
      fit: BoxFit.fitHeight,
      child: Stack(
        children: [
          // ── Background card with shadow ──────────────────────────────
          Container(
            padding: const EdgeInsets.only(
              left: AppSpacing.spacing12,
              right: AppSpacing.spacing12,
              top: AppSpacing.spacing12,
              bottom: AppSpacing.spacing8,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.small,
              boxShadow: [
                BoxShadow(
                  blurRadius: 2,
                  offset: const Offset(0, 5),
                  color: shadowColor,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildAvatar(avatarSize, iconSize, imageBorderColor),
                AppSpacing.spacing8_Box,
                Text(
                  "#$rank",
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: textColor),
                ),
              ],
            ),
          ),

          // ── Stars overlay for rank 1 ────────────────────────────────
          if (rank == 1)
            Positioned.fill(
              child: Image.asset(
                AppImages.starsPath,
                colorBlendMode: BlendMode.srcATop,
                color: AppColors.primaryFocus.withValues(alpha: 10),
                fit: BoxFit.cover,
              ),
            ),

          // ── Foreground content (above stars, transparent bg) ─────────
          if (rank == 1)
            Container(
              padding: const EdgeInsets.only(
                left: AppSpacing.spacing12,
                right: AppSpacing.spacing12,
                top: AppSpacing.spacing12,
                bottom: AppSpacing.spacing8,
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: AppRadius.small,
              ),
              child: Column(
                children: [
                  _buildAvatar(
                      avatarSize, iconSize, Colors.transparent,
                      placeholderColor: Colors.transparent),
                  AppSpacing.spacing8_Box,
                  Container(
                    color: color,
                    child: Text(
                      "#$rank",
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: textColor),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the circular avatar widget, factored out to avoid duplication.
  Widget _buildAvatar(
    double size,
    double iconSize,
    Color borderColor, {
    Color? placeholderColor,
  }) {
    final effectivePlaceholder = placeholderColor ?? color;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 4,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: SizedBox(
        height: size,
        width: size,
        child: ClipOval(
          child: pictureUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: pictureUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: effectivePlaceholder),
                  errorWidget: (context, url, error) =>
                      Container(color: effectivePlaceholder),
                )
              : Container(
                  color: effectivePlaceholder,
                  child: Icon(
                    Icons.person,
                    size: iconSize,
                    color: AppColors.primaryDisabled,
                  ),
                ),
        ),
      ),
    );
  }
}
