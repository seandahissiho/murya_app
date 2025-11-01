import 'dart:developer';
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
    return CustomPaint(
      size: const Size(350, 350),
      painter: _RoundedRadarPainter(
        labels: labels,
        values: values,
        maxValue: maxValue,
        cornerRadius: cornerRadius,
      ),
    );
  }
}

class _RoundedRadarPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final double maxValue;
  final double cornerRadius;

  _RoundedRadarPainter({
    required this.labels,
    required this.values,
    required this.maxValue,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int n = values.length;
    if (n < 3) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) * 0.4;

    final double angleStep = 2 * math.pi / n;
    final Paint gridPaint = Paint()
      ..color = AppColors.borderLight
      ..style = PaintingStyle.stroke;

    // draw concentric rings
    _drawConcentricRoundedPolygons(canvas, size, center, angleStep);

    // compute polygon points
    final List<Offset> pts = [];
    for (int i = 0; i < n; i++) {
      final double val = (values[i] / maxValue).clamp(0.0, 1.0);
      final double r = radius * val;
      final double angle = -math.pi / 2 + (i * angleStep);
      pts.add(Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle)));
    }

    _drawData(canvas, pts);

    _drawPoints(canvas, pts);

    // draw axis lines + labels
    _drawLabelsNearData(canvas, angleStep, n, radius, center, gridPaint);
  }

  Path _buildRoundedPolygonPath(List<Offset> pts, double r) {
    final int len = pts.length;
    if (len == 0) return Path();

    Path path = Path();
    for (int i = 0; i < len; i++) {
      final Offset prev = pts[(i + len - 1) % len];
      final Offset curr = pts[i];
      final Offset next = pts[(i + 1) % len];

      // compute direction vectors
      final Offset v1 = (prev - curr);
      final Offset v2 = (next - curr);
      final double v1Len = v1.distance;
      final double v2Len = v2.distance;

      if (v1Len < 0.0001 || v2Len < 0.0001) {
        continue;
      }

      final Offset v1norm = v1 / v1Len;
      final Offset v2norm = v2 / v2Len;

      // compute the outside bisector
      final Offset bisector = (v1norm + v2norm).normalize();
      // compute the angle between v1 and v2
      final double angleBetween = math.acos((v1norm.dot(v2norm)).clamp(-1.0, 1.0));
      // compute distance from corner to start arc
      final double dist = r / math.tan(angleBetween / 2);

      final Offset p1 = curr + v1norm * dist;
      final Offset p2 = curr + v2norm * dist;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.arcToPoint(
        p2,
        radius: Radius.circular(r),
        clockwise: true,
      );
    }
    path.close();
    return path;
  }

  Path buildRoundedPolygonPath(List<Offset> pts, double cornerRadius) {
    final Path path = Path();
    final int len = pts.length;
    if (len < 2) return path;

    for (int i = 0; i < len; i++) {
      final Offset prev = pts[(i + len - 1) % len];
      final Offset curr = pts[i];
      final Offset next = pts[(i + 1) % len];

      // direction vectors
      final Offset v1 = (prev - curr);
      final Offset v2 = (next - curr);

      final double v1Len = v1.distance;
      final double v2Len = v2.distance;
      if (v1Len == 0 || v2Len == 0) {
        continue;
      }
      final Offset v1n = v1 / v1Len;
      final Offset v2n = v2 / v2Len;

      final double angle = math.acos((v1n.dx * v2n.dx + v1n.dy * v2n.dy).clamp(-1.0, 1.0));
      final double dist = cornerRadius / math.tan(angle / 2);

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

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;

  void _drawConcentricRoundedPolygons(Canvas canvas, Size size, Offset center, double angleStep) {
    const int nSides = 5;
    final double maxRadius = math.min(size.width, size.height) * 0.4;
    const double cornerRadius = 16.0;
    // final double angleStep = 2 * math.pi / nSides;
    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.borderLight
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      final double r = (maxRadius * i / 5);
      final List<Offset> pts = List.generate(nSides, (j) {
        final double angle = -math.pi / 2 + (j * angleStep);
        return Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
      });
      final Path ringPath = buildRoundedPolygonPath(pts, cornerRadius);
      canvas.drawPath(ringPath, ringPaint);
    }
  }

  void _drawData(Canvas canvas, List<Offset> pts) {
    // build rounded-corner path
    Path path = _buildRoundedPolygonPath(pts, this.cornerRadius);

    // fill
    final Paint fillPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // stroke
    final Paint borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, borderPaint);
  }

  void _drawPoints(Canvas canvas, List<Offset> pts) {
    final Paint dotPaint = Paint()
      ..color = Colors.black // or whatever color you like for the dot
      ..style = PaintingStyle.fill;

    const double dotRadius = 5.0; // radius of the small circle
    const double borderWidth = 2.0; // width of white border
    for (int i = 0; i < pts.length; i++) {
      final Offset point = pts[i];

      // 1) Draw the filled circle (your data-dot color)
      final Paint fillPaint = Paint()
        ..color = Colors.black // set your fill color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, dotRadius, fillPaint);

      // 2) Draw the white border circle on top
      final Paint borderPaint = Paint()
        ..color = Colors.white // white border color
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawCircle(point, dotRadius + borderWidth / 2, borderPaint);
    }
  }

  void _drawLabelsNearData(
    Canvas canvas,
    double angleStep,
    int n,
    double maxRadius,
    Offset center,
    Paint axisPaint,
  ) {
    final tp = TextPainter(textAlign: TextAlign.left, textDirection: TextDirection.ltr);

    const double dotRadius = 5; // same as your data dot
    const double labelPadding = 16; // distance from dot to label
    const double leaderLen = 6; // optional leader line length
    const double textPadding = 8; // inner padding for background box
    const double borderRadius = 10; // rounded corners for background

    for (int i = 0; i < n; i++) {
      final double angle = -math.pi / 2 + (i * angleStep);

      // 1) Data point position
      final double ratio = ((values[i] == 0 ? (maxValue / 1.5) : values[i]) / maxValue).clamp(0.0, 1.0);
      final double r = maxRadius * ratio;
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      final Offset dataPt = center + dir * r;

      // 2) Label anchor point (just beyond the dot)
      final Offset labelAnchor = dataPt + dir * (dotRadius + labelPadding);

      // 3) Layout text
      tp.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      );
      tp.layout();

      // 4) Compute background box position
      final bool right = dir.dx >= 0;
      final bool down = dir.dy >= 0;
      final double x = labelAnchor.dx + (right ? -40.0 : -tp.width + 40.0);
      final double y = labelAnchor.dy + (down ? 4.0 : -tp.height - (i == 0 ? 0.0 : 12.0));
      final Offset textTopLeft = Offset(x, y);

      // 5) Define padded rect
      final Rect bgRect = Rect.fromLTWH(
        textTopLeft.dx - textPadding,
        textTopLeft.dy - textPadding / 2,
        tp.width + textPadding * 2,
        tp.height + textPadding,
      );

      // 6) Draw black rounded background
      final Paint bgPaint = Paint()..color = AppColors.primaryDefault;
      final RRect roundedRect = RRect.fromRectAndRadius(bgRect, const Radius.circular(borderRadius));
      canvas.drawRRect(roundedRect, bgPaint);

      // 7) Optional small leader line
      final Paint leader = Paint()
        ..color = axisPaint.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(dataPt, dataPt + dir * leaderLen, leader);

      // 8) Draw white text centered in padded box
      final Offset paddedTextOffset = Offset(
        textTopLeft.dx,
        textTopLeft.dy,
      );
      tp.paint(canvas, paddedTextOffset);
    }
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
