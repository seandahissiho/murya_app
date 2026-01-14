import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/config/DS.dart';

class FavoritesWidget extends StatelessWidget {
  final int value;
  final bool compact;
  final Color textColor;
  final bool isReward;

  const FavoritesWidget({
    super.key,
    required this.value,
    this.compact = false,
    this.textColor = AppColors.primaryDefault,
    this.isReward = false,
  });

  TextStyle? _style(bool isMobile, ThemeData theme) {
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
        Icon(
          Icons.star_border_rounded,
          size: iconSize,
          color: AppColors.primaryFocus,
        ),
      ],
    );
  }
}
