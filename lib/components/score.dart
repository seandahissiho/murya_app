import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';

class ScoreWidget extends StatelessWidget {
  final int value;
  final bool compact;
  final Color textColor;
  final bool isReward;
  final bool isLandingPage;
  final Color iconColor;

  const ScoreWidget({
    super.key,
    required this.value,
    this.compact = false,
    this.isLandingPage = false,
    this.textColor = AppColors.primaryDefault,
    this.iconColor = AppColors.primaryFocus,
    this.isReward = false,
  });

  TextStyle? _style(isMobile, theme) {
    if (isLandingPage) return _landingPageStyle(isMobile, theme, textColor);

    if (isReward) {
      return isMobile
          ? theme.textTheme.labelLarge?.copyWith(height: 0.0, color: textColor, fontWeight: FontWeight.bold)
          : GoogleFonts.anton(
              textStyle:
                  theme.textTheme.displayLarge?.copyWith(height: 1.0, color: textColor, fontWeight: FontWeight.bold));
    }

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
    return Row(
      children: [
        Container(
          height: isReward ? null : (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) / 1.5,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.tinyMargin,
          ),
          child: Center(
            child: Text(
              "${isReward ? "+ " : ""}$value",
              style: _style(isMobile, theme),
            ),
          ),
        ),
        AppSpacing.tinyMarginBox,
        SvgPicture.asset(
          AppIcons.diamondIconPath,
          width: isMobile
              ? mobileCTAHeight / (compact ? 2.5 : 2)
              : tabletAndAboveCTAHeight / (compact ? 2.5 : 2) * (isReward ? 1.75 : 1),
          height: isMobile
              ? mobileCTAHeight / (compact ? 2.5 : 2)
              : tabletAndAboveCTAHeight / (compact ? 2.5 : 2) * (isReward ? 1.75 : 1),
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
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
    this.textColor = AppColors.primaryDefault,
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
            horizontal: AppSpacing.tinyMargin,
          ),
          child: Center(
            child: Text(
              '$value%',
              style: _style(isMobile, theme),
            ),
          ),
        ),
        AppSpacing.tinyMarginBox,
        SvgPicture.asset(
          AppIcons.targetGoalIconPath,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
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
    this.textColor = AppColors.primaryDefault,
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.tinyMargin),
          child: Center(
            child: Text(
              "${isReward ? "+ " : ""}$value",
              style: _style(isMobile, theme),
            ),
          ),
        ),
        AppSpacing.tinyMarginBox,
        SvgPicture.asset(
          AppIcons.starIconPath,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            iconColor,
            BlendMode.srcIn,
          ),
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
