import 'dart:async';
import 'dart:math' as math;

import 'package:beamer/beamer.dart';
import 'package:expandable_text/expandable_text.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/app_footer.dart';
import 'package:murya/components/dropdown.dart';
import 'package:murya/components/ranking.dart';
import 'package:murya/components/score.dart';
import 'package:murya/components/skeletonizer.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/job_kiviat.dart';
import 'package:murya/models/user_job_competency_profile.dart';
import 'package:murya/screens/base.dart';

part '_job_details_mobile.dart';
part '_job_details_tablet+.dart';

class JobDetailsLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.jobDetails];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    final locale = AppLocalizations.of(context);
    final Map<String, dynamic>? routeData = data as Map<String, dynamic>?;
    final dynamic payload = routeData?['data'];
    final String jobName =
        payload is Map<String, dynamic> && payload['jobTitle'] is String ? payload['jobTitle'] as String : '';
    final String pageTitle = jobName.isNotEmpty ? locale.job_profile_page_title(jobName) : 'Murya';
    return [
      BeamPage(
        key: ValueKey('jobDetails-page-$languageCode'),
        title: pageTitle,
        child: const JobDetailsScreen(),
      ),
    ];
  }
}

class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileJobDetailsScreen(),
      tabletScreen: TabletJobDetailsScreen(),
      desktopScreen: TabletJobDetailsScreen(),
    );
  }
}

class CFCard extends StatefulWidget {
  final AppJob job;
  final CompetencyFamily family;

  const CFCard({super.key, required this.job, required this.family});

  @override
  State<CFCard> createState() => _CFCardState();
}

class _CFCardState extends State<CFCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nbCompetencies = widget.job.competenciesPerFamily(widget.family).length;
    final locale = AppLocalizations.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    return AppXButton(
      onPressed: () {
        navigateToPath(
          context,
          to: AppRoutes.competencyFamilyDetails
              .replaceAll(':jobId', widget.job.id!)
              .replaceAll(':cfId', widget.family.id!),
          data: {
            'familyName': widget.family.name,
          },
        );
      },
      isLoading: false,
      shrinkWrap: false,
      height: isMobile ? mobileCTAHeight * 3 : tabletAndAboveCTAHeight * 2.25,
      bgColor: AppButtonColors.secondarySurfaceDefault,
      hoverColor: AppButtonColors.secondarySurfaceHover,
      shadowColor: AppButtonColors.secondaryShadowDefault,
      borderColor: AppButtonColors.secondaryBorderDefault,
      onPressedColor: AppButtonColors.secondarySurfaceDefault,
      children: [
        Container(
          decoration: const BoxDecoration(
            //rgba(158, 154, 166, 0.2)
            color: Color.fromRGBO(158, 154, 166, 0.3),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            getIconForFamily(widget.family),
            height: isMobile ? mobileCTAHeight - 15 : tabletAndAboveCTAHeight - 15,
            width: isMobile ? mobileCTAHeight - 15 : tabletAndAboveCTAHeight - 15,
            colorFilter: const ColorFilter.mode(AppColors.primaryDefault, BlendMode.srcIn),
          ),
        ),
        AppSpacing.spacing16_Box,
        Expanded(
          flex: 100,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.family.name,
                style: GoogleFonts.anton(
                  color: _isHovering ? AppColors.textInverted : AppColors.textPrimary,
                  fontSize:
                      isMobile ? theme.textTheme.displayMedium!.fontSize : theme.textTheme.headlineSmall!.fontSize,
                  fontWeight: FontWeight.w400,
                  // height: 1 / 3.8,
                ),
              ),
              AppSpacing.spacing2_Box,
              Text(
                locale.competencies_count(nbCompetencies),
                style: (isMobile ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)?.copyWith(
                  color: _isHovering ? AppColors.textInverted : AppColors.textSecondary,
                  // height: 1 / 2.4,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            // rightModalOpen(context, screen: const MainSearchScreen());
            navigateToPath(
              context,
              to: AppRoutes.competencyFamilyDetails
                  .replaceAll(':jobId', widget.job.id!)
                  .replaceAll(':cfId', widget.family.id!),
              data: {
                'familyName': widget.family.name,
              },
            );
          },
          child: SvgPicture.asset(
            AppIcons.dropdownArrowRightPath,
            height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
            width: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
          ),
        ),
      ],
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        _isHovering = true;
        setState(() {});
      },
      onExit: (event) {
        _isHovering = false;
        setState(() {});
      },
      child: GestureDetector(
        onTap: () {
          navigateToPath(context,
              to: AppRoutes.competencyFamilyDetails
                  .replaceAll(':jobId', widget.job.id!)
                  .replaceAll(':cfId', widget.family.id!));
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.backgroundDefault,
            border: Border.all(color: _isHovering ? AppColors.primaryHover : AppColors.borderLight, width: 2),
            borderRadius: AppRadius.large,
            boxShadow: [
              BoxShadow(
                color: _isHovering ? AppColors.primaryHover : AppColors.secondaryHover,
                blurRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
            image: _isHovering
                ? const DecorationImage(
                    image: AssetImage(AppImages.CFCardBackgroundPath),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    opacity: 1,
                  )
                : null,
          ),
          padding: const EdgeInsets.all(AppSpacing.spacing12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: _isHovering ? AppColors.backgroundSurface : AppColors.borderLight,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  getIconForFamily(widget.family),
                  height: isMobile ? mobileCTAHeight - 15 : tabletAndAboveCTAHeight - 15,
                  width: isMobile ? mobileCTAHeight - 15 : tabletAndAboveCTAHeight - 15,
                  colorFilter: const ColorFilter.mode(AppColors.primaryDefault, BlendMode.srcIn),
                ),
              ),
              AppSpacing.spacing16_Box,
              Expanded(
                flex: 100,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      widget.family.name,
                      style: GoogleFonts.anton(
                        color: _isHovering ? AppColors.textInverted : AppColors.textPrimary,
                        fontSize: isMobile
                            ? theme.textTheme.displayMedium!.fontSize
                            : theme.textTheme.headlineSmall!.fontSize,
                        fontWeight: FontWeight.w400,
                        // height: 1 / 3.8,
                      ),
                    ),
                    AppSpacing.spacing2_Box,
                    Text(
                      locale.competencies_count(nbCompetencies),
                      style: (isMobile ? theme.textTheme.bodyMedium : theme.textTheme.bodyLarge)?.copyWith(
                        color: _isHovering ? AppColors.textInverted : AppColors.textSecondary,
                        // height: 1 / 2.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // rightModalOpen(context, screen: const MainSearchScreen());
                  navigateToPath(context,
                      to: AppRoutes.competencyFamilyDetails
                          .replaceAll(':jobId', widget.job.id!)
                          .replaceAll(':cfId', widget.family.id!));
                },
                child: SvgPicture.asset(
                  AppIcons.dropdownArrowRightPath,
                  height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                  width: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String getIconForFamily(CompetencyFamily family) {
  switch (family.slug) {
    case 'conception':
      return AppIcons.handsShieldPath;
    case 'installation':
      return AppIcons.passwordKeyPath;
    case 'exploitation':
      return AppIcons.shieldProtectedPath;
    case 'maintenance':
      return AppIcons.searchLoupeAddPlusShieldPath;
    case 'gestion':
      return AppIcons.browserShieldPath;
    default:
      return AppIcons.employeeSearchLoupePath;
  }
}

// class RoundedRadarChart extends StatelessWidget {
//   final List<String> labels;
//   final List<double> values;
//   final double maxValue;
//   final double cornerRadius;
//
//   const RoundedRadarChart({
//     Key? key,
//     required this.labels,
//     required this.values,
//     this.maxValue = 5.0,
//     this.cornerRadius = 3.0,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       return CustomPaint(
//         size: Size(constraints.maxWidth, constraints.maxHeight),
//         painter: _RoundedRadarPainter(
//           labels: labels,
//           defaultValues: values,
//           userValues: [],
//           maxValue: maxValue,
//           cornerRadius: cornerRadius,
//         ),
//       );
//     });
//   }
// }

class InteractiveRoundedRadarChart extends StatefulWidget {
  final List<String> labels;
  final List<double> defaultValues;
  final List<double> userValues;
  final double maxValue;
  final double cornerRadius;
  final bool isLandingPageChart;
  final Color bgColor;

  // labelBoxColor
  final Color labelBgColor;

  // labelTextColor
  final Color labelTextColor;
  final bool hideTexts;

  const InteractiveRoundedRadarChart({
    Key? key,
    required this.labels,
    this.defaultValues = const [],
    this.userValues = const [],
    this.maxValue = 5.0,
    this.cornerRadius = 3.0,
    this.labelBgColor = AppColors.primaryDefault,
    this.labelTextColor = AppColors.textInverted,
    this.hideTexts = false,
    this.isLandingPageChart = false,
    this.bgColor = Colors.transparent,
  }) : super(key: key);

  @override
  State<InteractiveRoundedRadarChart> createState() => _InteractiveRoundedRadarChartState();
}

class _InteractiveRoundedRadarChartState extends State<InteractiveRoundedRadarChart> {
  int? _activeIndex;
  Offset? _tooltipPos; // in local coordinates

  // Computes the data-points exactly like the painter
  List<Offset> _computePoints(Size size, List<double> values) {
    final int n = values.length;
    if (n < 3) return [];
    final fit = _RadarFit.compute(size, n);

    return List.generate(n, (i) {
      final double v = (values[i] / widget.maxValue).clamp(0.0, 1.0);
      return fit.point(i, v);
    });
  }

  // Find nearest point within a threshold
  int? _hitTest(List<Offset> pts, Offset localPos, double threshold) {
    int? idx;
    double best = double.infinity;
    for (int i = 0; i < pts.length; i++) {
      final d = (pts[i] - localPos).distance;
      if (d < threshold && d < best) {
        best = d;
        idx = i;
      }
    }
    return idx;
  }

  void _updateHover(Size size, Offset localPos) {
    if (widget.isLandingPageChart) return;
    final pts = _computePoints(size, widget.defaultValues);
    // threshold scales with chart size
    final double threshold = math.max(10.0, size.width * 0.05);
    final i = _hitTest(pts, localPos, threshold);
    setState(() {
      _activeIndex = i;
      _tooltipPos = (i != null) ? pts[i] : null; // tooltip at the point center
    });
  }

  void _clearHover() {
    setState(() {
      _activeIndex = null;
      _tooltipPos = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final Size size = Size(c.maxWidth, c.maxHeight);

      return SizedBox.expand(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Pointer detector to feed local positions
            Positioned.fill(
              child: Listener(
                onPointerHover: (e) => _updateHover(size, e.localPosition),
                onPointerDown: (e) => _updateHover(size, e.localPosition),
                onPointerMove: (e) => _updateHover(size, e.localPosition),
                onPointerUp: (_) => _clearHover(),
                onPointerCancel: (_) => _clearHover(),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onLongPressStart: (details) => _updateHover(size, details.localPosition),
                  onLongPressMoveUpdate: (details) => _updateHover(size, details.localPosition),
                  onLongPressEnd: (_) => _clearHover(),
                  // onTapDown: (details) => _updateHover(size, details.localPosition),
                  child: MouseRegion(
                    opaque: false,
                    onHover: (e) => _updateHover(size, e.localPosition),
                    onExit: (_) => _clearHover(),
                    child: CustomPaint(
                      painter: _RoundedRadarPainter(
                        labels: const [],
                        defaultValues: widget.defaultValues,
                        userValues: widget.userValues,
                        maxValue: widget.maxValue,
                        cornerRadius: widget.cornerRadius,
                        highlightIndex: _activeIndex,
                        labelBgColor: widget.labelBgColor,
                        labelTextColor: widget.labelTextColor,
                        // highlight active point
                        highlightColor: Theme.of(context).colorScheme.primary,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ),

            if (!widget.hideTexts) ..._buildLabelChips(size),

            // Tooltip
            if (_activeIndex != null && _tooltipPos != null)
              Positioned(
                left: _tooltipPos!.dx,
                top: _tooltipPos!.dy,
                child: _ValueTooltip(
                  value: widget.defaultValues[_activeIndex!],
                  // nudge the tooltip so it doesn’t cover the dot
                  offset: const Offset(10, -10),
                ),
              ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildLabelChips(Size size) {
    double _clamp(double v, double min, double max) => math.max(min, math.min(v, max));

    final int n = widget.labels.length;
    if (n == 0) return [];

    final fit = _RadarFit.compute(size, n);
    final double s = fit.s;

    final double padX = 12.0 * s;
    final double padY = 8.0 * s;
    final double radius = 12.0 * s;
    final double gap = (4.0 * s) * (2.0 / 3.0);
    final double out = (5.0 * s) * (2.0 / 3.0);
    final double safePad = 10.0 * s;
    final Rect safe = Rect.fromLTWH(
      safePad,
      safePad,
      size.width - safePad * 2,
      size.height - safePad * 2,
    );

    final tp = TextPainter(textDirection: TextDirection.ltr);
    final List<Widget> children = [];

    for (int i = 0; i < n; i++) {
      final Offset dir = fit.dir(i);
      final double defaultV = widget.defaultValues.elementAtOrNull(i) ?? 0.0;
      final double userV = (widget.userValues.isNotEmpty && i < widget.userValues.length) ? widget.userValues[i] : 0.0;
      final double maxV = math.max(defaultV, userV).clamp(0.0, widget.maxValue);
      final double t = (widget.maxValue <= 0) ? 0.0 : (maxV / widget.maxValue);
      final Offset anchor = fit.point(i, t);
      final Offset pos = Offset(anchor.dx + dir.dx * out, anchor.dy + dir.dy * out);

      tp.text = TextSpan(
        text: widget.labels[i],
        style: TextStyle(
          color: widget.labelTextColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.layout();

      final double w = tp.width + padX * 2;
      final double h = tp.height + padY * 2;
      final double angle = math.atan2(dir.dy, dir.dx);
      final bool isTopCenter = (angle + (math.pi / 2)).abs() < (math.pi / 12);
      final bool isTopLeft = angle < -math.pi / 2;
      final bool isTopRight = angle > -math.pi / 2 && angle < 0;
      final double left = isTopCenter ? (pos.dx - w / 2) : (pos.dx + (dir.dx >= 0 ? gap : -w - gap));
      final double top = isTopCenter ? (pos.dy - h - gap) : (pos.dy + (dir.dy >= 0 ? gap : -h - gap));
      final double rotation = isTopLeft ? (-0 * math.pi / 180) : (isTopRight ? (0 * math.pi / 180) : 0.0);

      children.add(Positioned(
        left: _clamp(left, safe.left, safe.right - w),
        top: _clamp(top, safe.top, safe.bottom - h),
        child: Transform.rotate(
          angle: rotation,
          alignment: Alignment.center,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.labelBgColor.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(radius),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padX, vertical: padY),
              child: Text(
                widget.labels[i],
                style: TextStyle(
                  color: widget.labelTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ));
    }

    return children;
  }
}

class _ValueTooltip extends StatelessWidget {
  final double value;
  final Offset offset;

  const _ValueTooltip({
    Key? key,
    required this.value,
    this.offset = Offset.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = value.toStringAsFixed(value % 1 == 0 ? 0 : 2); // "3" or "3.25"
    return Transform.translate(
      offset: offset,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textInverted, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _RadarFit {
  final List<Offset> dirs;
  final double scale;
  final Offset origin;
  final double s;
  final double ringStroke;

  _RadarFit._(this.dirs, this.scale, this.origin, this.s, this.ringStroke);

  factory _RadarFit.compute(Size size, int n) {
    final double step = 2 * math.pi / n;

    final List<Offset> dirs = List.generate(n, (i) {
      final double a = -math.pi / 2 + i * step;
      return Offset(math.cos(a), math.sin(a));
    });

    double minX = double.infinity;
    double maxX = -double.infinity;
    double minY = double.infinity;
    double maxY = -double.infinity;

    for (final d in dirs) {
      if (d.dx < minX) minX = d.dx;
      if (d.dx > maxX) maxX = d.dx;
      if (d.dy < minY) minY = d.dy;
      if (d.dy > maxY) maxY = d.dy;
    }

    final double widthFactor = maxX - minX;
    final double heightFactor = maxY - minY;

    double ringStroke = 0.0;
    double scale = 0.0;
    double s = 1.0;

    for (int k = 0; k < 2; k++) {
      final double aw = math.max(1.0, size.width - ringStroke);
      final double ah = math.max(1.0, size.height - ringStroke);

      scale = math.min(aw / widthFactor, ah / heightFactor);
      s = (scale <= 0) ? 1.0 : (scale / 150.0);
      ringStroke = 1.0 * s;
    }

    final double tx = (size.width - widthFactor * scale) / 2 - (minX * scale);
    final double ty = (size.height - heightFactor * scale) / 2 - (minY * scale);

    return _RadarFit._(dirs, scale, Offset(tx, ty), s, ringStroke);
  }

  Offset point(int i, double t) {
    final Offset d = dirs[i];
    return Offset(origin.dx + d.dx * scale * t, origin.dy + d.dy * scale * t);
  }

  Offset dir(int i) => dirs[i];
}

class _RoundedRadarPainter extends CustomPainter {
  final List<String> labels;
  final List<double> defaultValues;
  final List<double> userValues;
  final double maxValue;
  final double cornerRadius; // base corner radius; scaled internally
  final int? highlightIndex; // NEW (optional)
  final Color highlightColor; // NEW (optional)
  final Color labelBgColor; // NEW (optional)
  final Color labelTextColor; // NEW (optional)

  _RoundedRadarPainter({
    required this.labels,
    required this.defaultValues,
    required this.userValues,
    required this.maxValue,
    required this.cornerRadius,
    this.highlightIndex,
    this.highlightColor = Colors.red,
    this.labelBgColor = AppColors.primaryDefault,
    this.labelTextColor = AppColors.textInverted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int n = defaultValues.length;
    if (n < 3) return; // need 3+ axes

    final fit = _RadarFit.compute(size, n);

    // Proportional styling scale (tweak the base divisor if you prefer)
    final double s = fit.s;

    // Scaled cosmetics
    final double ringStroke = fit.ringStroke;
    final double dataStroke = 3.0 * s;
    final double dotRadius = 3.0 * s;
    final double dotBorderW = 1.50 * s;
    final double cornerR = cornerRadius * s;

    // Paints
    final Paint ringPaint = Paint()
      ..color = AppColors.borderMedium.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke;

    // 1) Concentric rounded polygons (use actual axis count)
    _drawConcentricRoundedPolygons(
      canvas: canvas,
      fit: fit,
      nSides: n,
      cornerRadius: 16 * s,
      paint: ringPaint,
    );

    // 2) Compute data polygon points (scaled by values/maxValue)
    final List<Offset> defaultPts = List.generate(n, (i) {
      final double val = (defaultValues[i] / maxValue).clamp(0.0, 1.0);
      return fit.point(i, val);
    });
    final List<Offset> userPts = List.generate(n, (i) {
      final double val = (userValues.isNotEmpty ? (userValues[i] / maxValue).clamp(0.0, 1.0) : 0.0);
      return fit.point(i, val);
    });

    // 3) Data shape (rounded)
    _drawData(
      canvas: canvas,
      pts: defaultPts,
      cornerRadius: cornerR,
      fillColor: AppColors.primaryDefault.withValues(alpha: userValues.isEmpty ? 0.1 : 0.05),
      strokeColor: AppColors.primaryDefault.withValues(alpha: userValues.isEmpty ? 1.0 : 0.125),
      strokeWidth: dataStroke,
    );
    if (userValues.isNotEmpty) {
      _drawData(
        canvas: canvas,
        pts: userPts,
        cornerRadius: cornerR,
        fillColor: AppColors.primaryFocus.withOpacity(0.25),
        strokeColor: AppColors.primaryFocus,
        strokeWidth: dataStroke,
      );
    }

    // 4) Data points (dot + white ring)
    _drawPoints(
      canvas: canvas,
      pts: defaultPts,
      baseDotRadius: dotRadius,
      borderWidth: dotBorderW,
      fillColor: AppColors.primaryDefault.withValues(alpha: userValues.isEmpty ? 1.0 : 0.25),
      borderColor: userValues.isEmpty
          ? AppColors.textInverted
          : AppColors.primaryDefault.withValues(alpha: userValues.isEmpty ? 1.0 : 0),
      highlightIndex: highlightIndex,
      highlightScale: 1.6,
      // a bit larger
      highlightColor: highlightColor,
    );
    if (userValues.isNotEmpty) {
      _drawPoints(
        canvas: canvas,
        pts: userPts,
        baseDotRadius: dotRadius,
        borderWidth: dotBorderW,
        fillColor: AppColors.primaryFocus,
        borderColor: AppColors.textInverted,
        highlightIndex: null,
        highlightScale: 1.0,
        // no highlight for user points
        highlightColor: highlightColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoundedRadarPainter old) =>
      old.labels != labels ||
      old.defaultValues != defaultValues ||
      old.userValues != userValues ||
      old.maxValue != maxValue ||
      old.cornerRadius != cornerRadius ||
      old.highlightIndex != highlightIndex ||
      old.highlightColor != highlightColor;

  // ---------------------------
  // Helpers
  // ---------------------------

  void _drawConcentricRoundedPolygons({
    required Canvas canvas,
    required _RadarFit fit,
    required int nSides,
    required double cornerRadius,
    required Paint paint,
    int rings = 5,
  }) {
    for (int i = 1; i <= rings; i++) {
      final double t = i / rings;
      final List<Offset> ringPts = List.generate(nSides, (j) => fit.point(j, t));

      final Path ringPath = _buildRoundedPolygonPath(ringPts, cornerRadius);
      canvas.drawPath(ringPath, paint);
    }
  }

  void _drawData({
    required Canvas canvas,
    required List<Offset> pts,
    required double cornerRadius,
    required Color fillColor,
    required Color strokeColor,
    required double strokeWidth,
  }) {
    final Path path = _buildRoundedPolygonPath(pts, cornerRadius);

    final Paint fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);

    final Paint stroke = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawPath(path, stroke);
  }

  void _drawPoints({
    required Canvas canvas,
    required List<Offset> pts,
    required double baseDotRadius,
    required double borderWidth,
    required Color fillColor,
    required Color borderColor,
    int? highlightIndex,
    required double highlightScale,
    required Color highlightColor,
  }) {
    for (int i = 0; i < pts.length; i++) {
      final bool isActive = (highlightIndex != null && i == highlightIndex);
      final double dotRadius = isActive ? baseDotRadius * highlightScale : baseDotRadius;
      final Color fill = isActive ? (highlightColor ?? fillColor) : fillColor;

      final Paint fillPaint = Paint()..color = fill;
      canvas.drawCircle(pts[i], dotRadius, fillPaint);

      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawCircle(pts[i], dotRadius + borderWidth / 2, borderPaint);
    }
  }

  void _drawLabelsNearData({
    required Canvas canvas,
    required List<String> labels,
    required List<double> values,
    required double maxValue,
    required Offset center,
    required double maxRadius,
    required double angleStep,
    required Paint axisPaint,
    required double dotRadius,
    required double labelPadding,
    required double leaderLen,
    required double textPadX,
    required double textPadY,
    required double bgRadius,
  }) {
    final tp = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < labels.length; i++) {
      final double angle = -math.pi / 2 + (i * angleStep);

      // Data point position
      final double ratio = ((values[i] == 0 ? (maxValue / 1.5) : values[i]) / maxValue).clamp(0.0, 1.0);
      final double r = maxRadius * ratio;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      final Offset dataPt = center + dir * r;

      // Label anchor beyond the dot
      final Offset labelAnchor = dataPt + dir * (dotRadius + labelPadding);

      // Text layout
      tp.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: labelTextColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
      tp.layout();

      // Base placement (try to keep near the anchor, then clamp to canvas)
      double x = 0;
      double y = 0;
      if (values[i] > 3.5) {
        x = labelAnchor.dx + (dir.dx >= 0 ? -(tp.width / (i == 0 ? 2 : 1)) : -tp.width / 10);
        y = labelAnchor.dy + (dir.dy >= 0 ? 5 : -tp.height * (i == 0 ? 1 : 2.125));

        // Clamp to bounds
        final double clampPad = -tp.height;
        final double maxX = (center.dx * 2) - tp.width - clampPad;
        final double maxY = (center.dy * 2) - tp.height - clampPad;
        x = x.clamp(clampPad, maxX);
        y = y.clamp(clampPad, maxY);
      } else {
        x = labelAnchor.dx + (dir.dx >= 0 ? (i == 0 ? -tp.width / 2 : 0) : -tp.width);
        y = labelAnchor.dy + (dir.dy >= 0 ? 0.0 : -tp.height);

        // Clamp to bounds
        const double clampPad = 6.0;
        final double maxX = math.max(clampPad, (center.dx * 2) - tp.width - clampPad);
        final double maxY = math.max(clampPad, (center.dy * 2) - tp.height - clampPad);
        x = x.clamp(clampPad, maxX);
        y = y.clamp(clampPad, maxY);
      }

      final Offset textTopLeft = Offset(x, y);

      // Background rounded rect with padding
      final Rect bgRect = Rect.fromLTWH(
        textTopLeft.dx - textPadX,
        textTopLeft.dy - textPadY,
        tp.width + textPadX * 2,
        tp.height + textPadY * 2,
      );

      final Paint bgPaint = Paint()..color = labelBgColor;
      final RRect roundedRect = RRect.fromRectAndRadius(bgRect, Radius.circular(bgRadius));
      canvas.drawRRect(roundedRect, bgPaint);

      // Leader line (short)
      final Paint leader = Paint()
        ..color = axisPaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = axisPaint.strokeWidth;
      canvas.drawLine(dataPt, dataPt + dir * leaderLen, leader);

      // Draw text
      tp.paint(canvas, textTopLeft);
    }
  }

  /// Builds a rounded-corner polygon path from ordered [pts].
  /// No external vector helpers required; numerically safe with colinear guards.
  Path _buildRoundedPolygonPath(List<Offset> pts, double cornerRadius) {
    final Path path = Path();
    final int len = pts.length;
    if (len < 2) return path;

    for (int i = 0; i < len; i++) {
      final Offset prev = pts[(i + len - 1) % len];
      final Offset curr = pts[i];
      final Offset next = pts[(i + 1) % len];

      final Offset v1 = (prev - curr);
      final Offset v2 = (next - curr);
      final double v1Len = v1.distance;
      final double v2Len = v2.distance;
      if (v1Len == 0 || v2Len == 0) continue;

      final Offset v1n = v1 / v1Len;
      final Offset v2n = v2 / v2Len;

      final double dot = (v1n.dx * v2n.dx + v1n.dy * v2n.dy).clamp(-1.0, 1.0);
      final double angle = math.acos(dot);

      // Distance to cut along each edge so the arc of radius cornerRadius fits.
      double dist = cornerRadius / math.tan(angle / 2);

      // Guard: don’t overshoot tiny edges
      dist = math.min(dist, math.min(v1Len, v2Len) * 0.5);

      final Offset p1 = curr + v1n * dist;
      final Offset p2 = curr + v2n * dist;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }

      path.arcToPoint(
        Offset(p2.dx, p2.dy),
        radius: Radius.circular(cornerRadius),
        clockwise: true,
      );
    }

    path.close();
    return path;
  }
}

extension OffsetVectorOps on Offset {
  double dot(Offset other) {
    return this.dx * other.dx + this.dy * other.dy;
  }

  double get length {
    return math.sqrt(dx * dx + dy * dy);
  }

  Offset normalize() {
    final len = length;
    if (len == 0) return Offset.zero;
    return Offset(dx / len, dy / len);
  }
}
