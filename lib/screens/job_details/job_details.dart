import 'dart:math' as math;

import 'package:beamer/beamer.dart';
import 'package:expandable_text/expandable_text.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/app_footer.dart';
import 'package:murya/components/dropdown.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/main.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/screens/base.dart';

part '_job_details_mobile.dart';
part '_job_details_tablet+.dart';

class JobDetailsLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.jobDetails];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    return [
      const BeamPage(
        key: ValueKey('jobDetails-page'),
        title: 'JobDetails Page',
        child: JobDetailsScreen(),
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

class CFCard extends StatelessWidget {
  final Job job;
  final CompetencyFamily family;

  const CFCard({super.key, required this.job, required this.family});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nbCompetencies = job.competenciesPerFamily(family).length;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryDefault,
        border: Border.all(color: AppColors.borderMedium, width: 2),
        borderRadius: AppRadius.large,
      ),
      padding: const EdgeInsets.all(AppSpacing.containerInsideMarginSmall),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.borderLight,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              AppIcons.employeeSearchLoupePath,
              height: 20,
              width: 20,
              colorFilter: const ColorFilter.mode(AppColors.primaryDefault, BlendMode.srcIn),
            ),
          ),
          AppSpacing.groupMarginBox,
          Expanded(
            flex: 100,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  family.name,
                  style: GoogleFonts.anton(
                    color: AppColors.textInverted,
                    fontSize: theme.textTheme.displaySmall?.fontSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                AppSpacing.tinyMarginBox,
                Text(
                  '$nbCompetencies compétence${nbCompetencies > 1 ? 's' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
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
                  to: AppRoutes.competencyFamilyDetails.replaceAll(':jobId', job.id).replaceAll(':cfId', family.id));
            },
            child: SvgPicture.asset(
              AppIcons.buttonsButtonPath,
              height: 32,
              width: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedRadarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final double maxValue;
  final double cornerRadius;

  const RoundedRadarChart({
    Key? key,
    required this.labels,
    required this.values,
    this.maxValue = 5.0,
    this.cornerRadius = 3.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _RoundedRadarPainter(
          labels: labels,
          values: values,
          maxValue: maxValue,
          cornerRadius: cornerRadius,
        ),
      );
    });
  }
}

class InteractiveRoundedRadarChart extends StatefulWidget {
  final List<String> labels;
  final List<double> values;
  final double maxValue;
  final double cornerRadius;

  const InteractiveRoundedRadarChart({
    Key? key,
    required this.labels,
    required this.values,
    this.maxValue = 5.0,
    this.cornerRadius = 3.0,
  }) : super(key: key);

  @override
  State<InteractiveRoundedRadarChart> createState() => _InteractiveRoundedRadarChartState();
}

class _InteractiveRoundedRadarChartState extends State<InteractiveRoundedRadarChart> {
  int? _activeIndex;
  Offset? _tooltipPos; // in local coordinates

  // Computes the data-points exactly like the painter
  List<Offset> _computePoints(Size size) {
    final int n = widget.values.length;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width / 2) - 8.0; // small padding
    final double step = 2 * math.pi / n;

    return List.generate(n, (i) {
      final double v = (widget.values[i] / widget.maxValue).clamp(0.0, 1.0);
      final double r = radius * v;
      final double a = -math.pi / 2 + i * step;
      return Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
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
    final pts = _computePoints(size);
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
      final side = math.min(c.maxWidth, c.maxHeight);

      return SizedBox(
        width: side,
        height: side,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Pointer detector to feed local positions
            Listener(
              onPointerHover: (e) => _updateHover(Size.square(side), e.localPosition),
              onPointerDown: (e) => _updateHover(Size.square(side), e.localPosition),
              onPointerMove: (e) => _updateHover(Size.square(side), e.localPosition),
              onPointerUp: (_) => _clearHover(),
              onPointerCancel: (_) => _clearHover(),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onLongPressStart: (details) => _updateHover(Size.square(side), details.localPosition),
                onLongPressMoveUpdate: (details) => _updateHover(Size.square(side), details.localPosition),
                onLongPressEnd: (_) => _clearHover(),
                // onTapDown: (details) => _updateHover(Size.square(side), details.localPosition),
                child: MouseRegion(
                  opaque: false,
                  onHover: (e) => _updateHover(Size.square(side), e.localPosition),
                  onExit: (_) => _clearHover(),
                  child: CustomPaint(
                    size: Size.square(side),
                    painter: _RoundedRadarPainter(
                      labels: widget.labels,
                      values: widget.values,
                      maxValue: widget.maxValue,
                      cornerRadius: widget.cornerRadius,
                      highlightIndex: _activeIndex, // highlight active point
                      highlightColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            // Tooltip
            if (_activeIndex != null && _tooltipPos != null)
              Positioned(
                left: _tooltipPos!.dx,
                top: _tooltipPos!.dy,
                child: _ValueTooltip(
                  value: widget.values[_activeIndex!],
                  // nudge the tooltip so it doesn’t cover the dot
                  offset: const Offset(10, -10),
                ),
              ),
          ],
        ),
      );
    });
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
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _RoundedRadarPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final double maxValue;
  final double cornerRadius; // base corner radius; scaled internally
  final int? highlightIndex; // NEW (optional)
  final Color highlightColor; // NEW (optional)

  _RoundedRadarPainter({
    required this.labels,
    required this.values,
    required this.maxValue,
    required this.cornerRadius,
    this.highlightIndex,
    this.highlightColor = Colors.red,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int n = values.length;
    if (n < 3) return; // need 3+ axes

    // Parent is square ⇒ width == height. Use (width / 2) minus padding.
    const double edgePadding = AppSpacing.containerInsideMargin;
    final Offset center = Offset(size.width / 2, size.height / 1.85);
    final double radius = (size.width / 2) - edgePadding;

    // Global angle step
    final double angleStep = 2 * math.pi / n;

    // Proportional styling scale (tweak the base divisor if you prefer)
    final double s = (radius <= 0) ? 1.0 : (radius / 150.0);

    // Scaled cosmetics
    final double ringStroke = 1.0 * s;
    final double dataStroke = 3.0 * s;
    final double dotRadius = 3.0 * s;
    final double dotBorderW = 1.0 * s;
    final double labelPad = 16.0 * s;
    final double leaderLen = 0.0 * s;
    final double textPadX = 12.0 * s;
    final double textPadY = 8.0 * s;
    final double labelRadius = 12.0 * s;
    final double cornerR = cornerRadius * s;

    // Paints
    final Paint gridPaint = Paint()
      ..color = AppColors.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke;

    final Paint ringPaint = Paint()
      ..color = AppColors.borderMedium.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke;

    // 1) Concentric rounded polygons (use actual axis count)
    _drawConcentricRoundedPolygons(
      canvas: canvas,
      center: center,
      maxRadius: radius,
      nSides: n,
      cornerRadius: 16,
      paint: ringPaint,
    );

    // 2) Compute data polygon points (scaled by values/maxValue)
    final List<Offset> pts = List.generate(n, (i) {
      final double val = (values[i] / maxValue).clamp(0.0, 1.0);
      final double r = radius * val;
      final double angle = -math.pi / 2 + (i * angleStep);
      return Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
    });

    // 3) Data shape (rounded)
    _drawData(
      canvas: canvas,
      pts: pts,
      cornerRadius: cornerR,
      fillColor: Colors.black.withOpacity(0.1),
      strokeColor: Colors.black,
      strokeWidth: dataStroke,
    );

    // 4) Data points (dot + white ring)
    _drawPoints(
      canvas: canvas,
      pts: pts,
      baseDotRadius: dotRadius,
      borderWidth: dotBorderW,
      fillColor: Colors.black,
      borderColor: Colors.white,
      highlightIndex: highlightIndex,
      highlightScale: 1.6, // a bit larger
      highlightColor: highlightColor,
    );

    // 5) Labels near data points with background and a short leader
    _drawLabelsNearData(
      canvas: canvas,
      labels: labels,
      values: values,
      maxValue: maxValue,
      center: center,
      maxRadius: radius,
      angleStep: angleStep,
      axisPaint: gridPaint,
      dotRadius: dotRadius,
      labelPadding: labelPad,
      leaderLen: leaderLen,
      textPadX: textPadX,
      textPadY: textPadY,
      bgRadius: labelRadius,
    );
  }

  @override
  bool shouldRepaint(covariant _RoundedRadarPainter old) =>
      old.labels != labels ||
      old.values != values ||
      old.maxValue != maxValue ||
      old.cornerRadius != cornerRadius ||
      old.highlightIndex != highlightIndex ||
      old.highlightColor != highlightColor;
  // ---------------------------
  // Helpers
  // ---------------------------

  void _drawConcentricRoundedPolygons({
    required Canvas canvas,
    required Offset center,
    required double maxRadius,
    required int nSides,
    required double cornerRadius,
    required Paint paint,
    int rings = 5,
  }) {
    for (int i = 1; i <= rings; i++) {
      final double r = (maxRadius * i / rings);
      final double angleStep = 2 * math.pi / nSides;

      final List<Offset> ringPts = List.generate(nSides, (j) {
        final double angle = -math.pi / 2 + (j * angleStep);
        return Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
      });

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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
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
        final double maxX = (center.dx * 2) - tp.width - clampPad;
        final double maxY = (center.dy * 2) - tp.height - clampPad;
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

      final Paint bgPaint = Paint()..color = AppColors.primaryDefault;
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
