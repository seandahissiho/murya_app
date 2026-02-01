import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/l10n/l10n.dart';

class ScoreWidget extends StatefulWidget {
  final int value;
  final bool compact;
  final Color textColor;
  final bool isReward;
  final bool isLandingPage;
  final Color iconColor;
  final bool reverse;
  final double? iconSize;

  const ScoreWidget({
    super.key,
    required this.value,
    this.compact = false,
    this.isLandingPage = false,
    this.textColor = AppColors.textSecondary,
    this.iconColor = AppButtonColors.primarySurfaceDefault,
    this.isReward = false,
    this.reverse = false,
    this.iconSize,
  });

  @override
  State<ScoreWidget> createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<ScoreWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _popCtrl;
  late final Animation<double> _scale;

  int _lastValue = 0;
  int? _delta;
  bool _flash = false;
  int _animStamp = 0;

  TextStyle? _style(bool isMobile, ThemeData theme) {
    if (widget.isLandingPage) return _landingPageStyle(isMobile, theme, widget.textColor);

    if (widget.isReward) {
      return isMobile
          ? theme.textTheme.labelLarge?.copyWith(
              height: 0.0,
              color: widget.textColor,
              fontWeight: FontWeight.bold,
            )
          : GoogleFonts.anton(
              textStyle: theme.textTheme.displayLarge?.copyWith(
                height: 1.0,
                color: widget.textColor,
                fontWeight: FontWeight.bold,
              ),
            );
    }

    return isMobile
        ? theme.textTheme.labelLarge?.copyWith(height: 0.0, color: widget.textColor)
        : (!widget.compact
            ? theme.textTheme.displayMedium?.copyWith(
                height: 1.0,
                color: widget.textColor,
                fontSize: 24,
              )
            : theme.textTheme.labelLarge?.copyWith(height: 0.0, color: widget.textColor));
  }

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;

    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 170),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _popCtrl, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant ScoreWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final diff = widget.value - _lastValue;
    _lastValue = widget.value;

    // ✅ On anime uniquement quand ça monte (effet "score up")
    if (diff > 0 && !widget.isReward) {
      _triggerGain(diff);
    }
  }

  void _triggerGain(int diff) {
    final stamp = ++_animStamp;

    setState(() {
      _delta = diff;
      _flash = true;
    });

    _popCtrl.forward(from: 0).then((_) => _popCtrl.reverse());

    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted || stamp != _animStamp) return;
      setState(() => _flash = false);
    });

    Future.delayed(const Duration(milliseconds: 850), () {
      if (!mounted || stamp != _animStamp) return;
      setState(() => _delta = null);
    });
  }

  @override
  void dispose() {
    _popCtrl.dispose(); // ✅ toujours avant super.dispose() :contentReference[oaicite:2]{index=2}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    final style = _style(isMobile, theme);

    final double defaultIconSize = _getDefaultIconSize(isMobile);
    final double iconSize = widget.iconSize != null ? widget.iconSize! : defaultIconSize;

    final scoreText = Container(
      height: widget.isReward ? null : (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) / 1.5,
      padding: const EdgeInsets.only(right: AppSpacing.spacing4),
      child: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isReward) ...[
                Text("+ ", style: style),
              ],
              AnimatedFlipCounter(
                value: widget.value,
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                textStyle: style,
              ),
            ],
          ),
        ),
      ),
    );
    final diamondIcon = ScaleTransition(
      scale: _scale,
      child: SvgPicture.asset(
        AppIcons.diamondIconPath,
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(widget.iconColor, BlendMode.srcATop),
      ),
    );
    final gainWidget = AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.6),
          end: const Offset(0, -0.35),
        ).animate(anim);

        return FadeTransition(
          opacity: anim,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: (_delta != null)
          ? Container(
              key: ValueKey(_delta),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: widget.iconColor,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: widget.iconColor.withOpacity(0.40),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Text(
                "+$_delta",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            )
          : const SizedBox(key: ValueKey("empty")),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: _flash ? widget.iconColor.withOpacity(0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.reverse == false) ...[
            // ✅ SCORE + ICON
            Row(
              children: [
                scoreText,
                widget.isLandingPage ? AppSpacing.spacing4_Box : AppSpacing.spacing8_Box,
                diamondIcon,
              ],
            ),
            // ✅ +X FLOATING (effet arcade)
            Positioned(
              right: -6,
              top: -18,
              child: gainWidget,
            ),
          ] else ...[
            // ✅ ICON + SCORE
            Row(
              children: [
                diamondIcon,
                AppSpacing.spacing12_Box,
                scoreText,
              ],
            ),
            // ✅ +X FLOATING (effet arcade)
            Positioned(
              left: -6,
              top: -18,
              child: gainWidget,
            ),
          ],
        ],
      ),
    );
  }

  double _getDefaultIconSize(bool isMobile) {
    if (widget.iconSize != null) {
      return widget.iconSize!;
    }
    if (isMobile) {
      if (widget.isReward) {
        return 20;
      } else if (widget.isLandingPage) {
        return 14;
      } else {
        return 18;
      }
    } else {
      if (widget.isReward) {
        return 24;
      } else if (widget.isLandingPage) {
        return tabletAndAboveCTAHeight / (widget.compact ? 3 : 2.5) * (widget.isReward ? 1.75 : 1);
      } else {
        return 20;
      }
    }
  }
}

class GoalWidget extends StatelessWidget {
  final int value;
  final bool compact;
  final bool isLandingPage;
  final Color textColor;
  final Color iconColor;

  const GoalWidget({
    super.key,
    required this.value,
    this.compact = false,
    this.isLandingPage = false,
    this.textColor = AppColors.textPrimary,
    this.iconColor = AppColors.primaryFocus,
  });

  TextStyle? _style(bool isMobile, ThemeData theme) {
    if (isLandingPage) return _landingPageStyle(isMobile, theme, textColor);

    return isMobile
        ? (!compact
            ? theme.textTheme.labelLarge?.copyWith(height: 0.0, color: textColor)
            : theme.textTheme.labelLarge?.copyWith(height: 0.0, color: textColor))
        : (!compact
            ? theme.textTheme.displayMedium?.copyWith(height: 1.0, color: textColor)
            : theme.textTheme.labelLarge?.copyWith(height: 0.0, color: textColor));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    final iconSize = isMobile ? mobileCTAHeight / (compact ? 2.5 : 2) : tabletAndAboveCTAHeight / (compact ? 2.5 : 2);
    return Row(
      children: [
        Container(
          height: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) / 1.5,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing4,
          ),
          child: Center(
            child: Text(
              '$value%',
              style: _style(isMobile, theme),
            ),
          ),
        ),
        AppSpacing.spacing4_Box,
        SvgPicture.asset(
          AppIcons.targetGoalIconPath,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcATop,
          ),
        ),
      ],
    );
  }
}

class FavoritesWidget extends StatelessWidget {
  final int value;
  final bool compact;
  final bool isLandingPage;
  final Color textColor;
  final Color iconColor;
  final bool isReward;

  const FavoritesWidget({
    super.key,
    required this.value,
    this.compact = false,
    this.isLandingPage = false,
    this.textColor = AppColors.textPrimary,
    this.iconColor = AppColors.primaryFocus,
    this.isReward = false,
  });

  TextStyle? _style(bool isMobile, ThemeData theme) {
    if (isLandingPage) return _landingPageStyle(isMobile, theme, textColor);

    if (isReward) {
      return isMobile
          ? theme.textTheme.labelLarge?.copyWith(height: 0.0, color: textColor, fontWeight: FontWeight.bold)
          : GoogleFonts.anton(
              textStyle:
                  theme.textTheme.displayLarge?.copyWith(height: 1.0, color: textColor, fontWeight: FontWeight.bold),
            );
    }

    return isMobile
        ? theme.textTheme.labelLarge?.copyWith(height: 0.0, color: textColor)
        : (!compact
            ? theme.textTheme.displayMedium?.copyWith(height: 1.0, color: textColor)
            : theme.textTheme.labelLarge?.copyWith(height: 0.0, color: textColor));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    final double iconSize = isMobile
        ? mobileCTAHeight / (compact ? 2.5 : 2)
        : tabletAndAboveCTAHeight / (compact ? 2.5 : 2) * (isReward ? 1.75 : 1);
    return Row(
      children: [
        Container(
          height: isReward ? null : (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) / 1.5,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4),
          child: Center(
            child: Text(
              "${isReward ? "+ " : ""}$value",
              style: _style(isMobile, theme),
            ),
          ),
        ),
        AppSpacing.spacing4_Box,
        SvgPicture.asset(
          AppIcons.starIconPath,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcATop,
          ),
        ),
      ],
    );
  }
}

class StreakWidget extends StatelessWidget {
  final int streakDays;
  final bool isLandingPage;
  final double? iconSize;

  const StreakWidget({super.key, required this.streakDays, this.isLandingPage = false, this.iconSize});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    const textColor = AppColors.textSecondary;
    const iconColor = AppButtonColors.primarySurfaceDefault;
    final locale = AppLocalizations.of(context);

    final double defaultIconSize = isLandingPage ? (isMobile ? 16 : 20) : 16;
    final double finalIconSize = iconSize != null ? iconSize! : defaultIconSize;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppIcons.streakPath,
          width: finalIconSize,
          height: finalIconSize,
          colorFilter: const ColorFilter.mode(iconColor, BlendMode.srcATop),
        ),
        AppSpacing.spacing4_Box,
        Text(
          locale.streakDays(streakDays),
          style: isLandingPage
              ? _landingPageStyle(isMobile, theme, textColor)
              : theme.textTheme.labelLarge?.copyWith(color: textColor),
        ),
      ],
    );
  }
}

TextStyle? _landingPageStyle(bool isMobile, ThemeData theme, Color textColor) {
  return isMobile
      ? theme.textTheme.labelLarge?.copyWith(height: 0.0, color: textColor, fontWeight: FontWeight.bold)
      : theme.textTheme.headlineSmall?.copyWith(
          letterSpacing: -0.4,
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 23,
          height: 1.0,
        );
}
