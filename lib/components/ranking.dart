import 'dart:developer';
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
  JobRankings _ranking = JobRankings.empty();
  int _detailsLevel = 0;

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

  @override
  void initState() {
    context.read<JobBloc>().add(LoadRankingForJob(
          context: context,
          jobId: widget.jobId,
          from: from,
          to: to,
        ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    List<String> options = [
      locale.ranking_per_day,
      locale.ranking_per_week,
      locale.ranking_per_month,
    ];

    return LayoutBuilder(builder: (context, constraints) {
      return BlocConsumer<JobBloc, JobState>(
        listener: (context, state) {
          if (state is UserJobDetailsLoaded) {
            context.read<JobBloc>().add(LoadRankingForJob(context: context, jobId: widget.jobId, from: from, to: to));
          }
          if (state is JobRankingLoaded) {
            _ranking = state.ranking;
            if (_ranking.isNotEmptyOrNull) {
              // sort
              _ranking.rankings.sort((a, b) => a.rank.compareTo(b.rank));
            }
          }
          setState(() {});
        },
        builder: (context, state) {
          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = DeviceHelper.isMobile(context);
                  final currentUserId = widget.userId ?? context.read<ProfileBloc>().state.user.id;
                  log("Current user ID: $currentUserId");
                  JobRanking? firstRanking = _ranking.rankings.firstWhereOrNull((r) => r.rank == 1);
                  // first quartile
                  JobRanking? firstQuartileRanking =
                      _ranking.rankings.firstWhereOrNull((r) => r.rank == (_ranking.rankings.length / 4).ceil());
                  // second quartile
                  JobRanking? secondQuartileRanking =
                      _ranking.rankings.firstWhereOrNull((r) => r.rank == (_ranking.rankings.length / 2).ceil());
                  // third quartile
                  JobRanking? thirdQuartileRanking =
                      _ranking.rankings.firstWhereOrNull((r) => r.rank == (3 * _ranking.rankings.length / 4).ceil());
                  JobRanking? userRanking = _ranking.rankings.firstWhereOrNull((r) => r.userId == currentUserId);

                  int max = _ranking.rankings.length + 1;

                  final firstPercentage = 1.0 * (max - (firstRanking?.rank ?? 0)) / (math.max(max, 2) - 1);
                  final firstQuartilePercentage =
                      1.0 * (max - (firstQuartileRanking?.rank ?? 0)) / (math.max(max, 2) - 1);
                  final secondQuartilePercentage =
                      1.0 * (max - (secondQuartileRanking?.rank ?? 0)) / (math.max(max, 2) - 1);
                  final thirdQuartilePercentage =
                      1.0 * (max - (thirdQuartileRanking?.rank ?? 0)) / (math.max(max, 2) - 1);
                  final userPercentage = 1.0 * (max - (userRanking?.rank ?? 0)) / (math.max(max, 2) - 1);

                  final size = Size(constraints.maxWidth, constraints.maxHeight);
                  final baseInset = (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) * 0.45;
                  final pointInset = baseInset + 4;
                  final painter = _DiagonalLinePainter(
                    userPercentage,
                    lineInset: 2,
                    pointInset: pointInset,
                    verticalSpanFactor: 0.65,
                  );

                  // Positions along the line (0.0 → left/bottom, 1.0 → right/top)
                  final firstRank = painter.pointOnLine(size, firstPercentage, isMobile: isMobile); // #1
                  final firstQuartileRank =
                      painter.pointOnLine(size, firstQuartilePercentage, isMobile: isMobile); // #max/4
                  final secondQuartileRank =
                      painter.pointOnLine(size, secondQuartilePercentage, isMobile: isMobile); // #max/2
                  final thirdQuartileRank =
                      painter.pointOnLine(size, thirdQuartilePercentage, isMobile: isMobile); // #3max/4
                  final userRank = painter.pointOnLine(size, userPercentage, isMobile: isMobile); // user's rank

                  return Column(
                    children: [
                      Container(
                        height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                        margin: const EdgeInsets.only(
                          top: AppSpacing.spacing24,
                        ),
                        padding: const EdgeInsets.only(
                          left: AppSpacing.spacing24,
                          right: AppSpacing.spacing24,
                        ),
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
                              controller: TextEditingController(text: options[_detailsLevel]),
                              items: options.map(
                                (level) => DropdownMenuEntry(
                                  value: options.indexOf(level),
                                  label: level,
                                ),
                              ),
                              onSelected: (level) {
                                setState(() {
                                  _detailsLevel = level!;
                                });
                              },
                              // labelInside: null,
                              shrinkWrap: false,
                              maxDropdownWidth: 150,
                              fgColor: AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // The line
                            CustomPaint(
                              size: size,
                              painter: painter,
                            ),

                            // First place
                            Positioned(
                              left: firstRank.dx,
                              top: firstRank.dy,
                              child: const FractionalTranslation(
                                translation: Offset(-0.5, -0.5),
                                child: RankingCard(rank: 1),
                              ),
                            ),
                            // First quartile place
                            if (firstQuartileRanking != null)
                              Positioned(
                                left: firstQuartileRank.dx,
                                top: firstQuartileRank.dy,
                                child: FractionalTranslation(
                                  translation: const Offset(-0.5, -0.5),
                                  child: RankingCard(
                                    rank: firstQuartileRanking.rank ?? -1,
                                  ),
                                ),
                              ),
                            // Second quartile place
                            if (secondQuartileRanking != null)
                              Positioned(
                                left: secondQuartileRank.dx,
                                top: secondQuartileRank.dy,
                                child: FractionalTranslation(
                                  translation: const Offset(-0.5, -0.5),
                                  child: RankingCard(
                                    rank: secondQuartileRanking.rank ?? -1,
                                  ),
                                ),
                              ),
                            // Third quartile place
                            if (thirdQuartileRanking != null)
                              Positioned(
                                left: thirdQuartileRank.dx,
                                top: thirdQuartileRank.dy,
                                child: FractionalTranslation(
                                  translation: const Offset(-0.5, -0.5),
                                  child: RankingCard(
                                    rank: thirdQuartileRanking.rank ?? -1,
                                  ),
                                ),
                              ),

                            // User's place
                            Positioned(
                              left: userRank.dx,
                              top: userRank.dy,
                              child: FractionalTranslation(
                                translation: const Offset(-0.5, -0.5), // center card on the point
                                child: RankingCard(
                                  rank: userRanking?.rank ?? -1,
                                  color: AppColors.primaryFocus,
                                  shadowColor: AppColors.primaryPressed,
                                  imageBorderColor: AppColors.backgroundCard,
                                  textColor: AppColors.textInverted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.spacing12_Box,
                    ],
                  );
                },
              ),
            ],
          );
        },
      );
    });
  }
}

class _DiagonalLinePainter extends CustomPainter {
  final double progress;
  final double lineInset;
  final double pointInset;
  final double verticalSpanFactor;

  const _DiagonalLinePainter(
    this.progress, {
    required this.lineInset,
    required this.pointInset,
    required this.verticalSpanFactor,
  });

  double _effectiveInset(Size size, double inset) => math.min(inset, math.min(size.width, size.height) * 0.45);

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

  /// Returns a point on the diagonal line for a given [percent] (0.0 → start, 1.0 → end)
  Offset pointOnLine(Size size, double percent, {bool isMobile = false}) {
    final start = _start(size, pointInset);
    final end = _end(size, pointInset);

    final double adjustedPercent = percent > .5 ? percent - (isMobile ? .05 : .065) : percent + (isMobile ? .06 : .015);
    final double clampedPercent = adjustedPercent.clamp(0.0, 1.0);

    return Offset(
      start.dx + (end.dx - start.dx) * clampedPercent,
      start.dy + (end.dy - start.dy) * clampedPercent,
    );
    // or: return Offset.lerp(start, end, percent)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = AppColors.borderLight
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final start = _start(size, lineInset);
    final end = _end(size, lineInset);
    canvas.drawLine(start, end, backgroundPaint);

    final foregroundPaint = Paint()
      ..color = AppColors.primaryFocus
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final foregroundStart = start;
    final foregroundEnd = Offset(
      foregroundStart.dx + (end.dx - foregroundStart.dx) * progress,
      foregroundStart.dy + (end.dy - foregroundStart.dy) * progress,
    );

    canvas.drawLine(foregroundStart, foregroundEnd, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RankingCard extends StatelessWidget {
  final String pictureUrl;
  final int rank;
  final Color color;
  final Color shadowColor;
  final Color imageBorderColor;
  final Color textColor;

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
    return Stack(
      children: [
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
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: imageBorderColor,
                    width: 4,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: SizedBox(
                  height: isMobile ? mobileCTAHeight / 1.618 : tabletAndAboveCTAHeight / 1.618,
                  width: isMobile ? mobileCTAHeight / 1.618 : tabletAndAboveCTAHeight / 1.618,
                  child: ClipOval(
                    child: pictureUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: pictureUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return Container(color: color);
                            },
                            errorWidget: (context, url, error) {
                              return Container(color: color);
                            },
                          )
                        : Container(
                            color: color,
                            child: Icon(
                              Icons.person,
                              size: isMobile ? mobileCTAHeight / 2 : tabletAndAboveCTAHeight / 2,
                              color: AppColors.primaryDisabled,
                            ),
                          ),
                  ),
                ),
              ),
              AppSpacing.spacing8_Box,
              Text("#$rank", style: theme.textTheme.labelMedium?.copyWith(color: textColor)),
            ],
          ),
        ),
        if (rank == 1) ...[
          Positioned.fill(
            child: Image.asset(
              AppImages.starsPath,
              colorBlendMode: BlendMode.srcATop,
              color: AppColors.primaryFocus.withValues(alpha: 10),
              fit: BoxFit.cover,
              // width: isMobile ? mobileCTAHeight / 2 : tabletAndAboveCTAHeight / 2,
              // height: isMobile ? mobileCTAHeight / 2 : tabletAndAboveCTAHeight / 2,
            ),
          ),
        ],
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
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.transparent,
                    width: 4,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: SizedBox(
                  height: isMobile ? mobileCTAHeight / 1.618 : tabletAndAboveCTAHeight / 1.618,
                  width: isMobile ? mobileCTAHeight / 1.618 : tabletAndAboveCTAHeight / 1.618,
                  child: ClipOval(
                    child: pictureUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: pictureUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return Container(color: Colors.transparent);
                            },
                            errorWidget: (context, url, error) {
                              return Container(color: Colors.transparent);
                            },
                          )
                        : Container(
                            color: Colors.transparent,
                            child: Icon(
                              Icons.person,
                              size: isMobile ? mobileCTAHeight / 2 : tabletAndAboveCTAHeight / 2,
                              color: AppColors.primaryDisabled,
                            ),
                          ),
                  ),
                ),
              ),
              AppSpacing.spacing8_Box,
              Container(
                color: color,
                child: Text("#$rank", style: theme.textTheme.labelMedium?.copyWith(color: textColor)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
