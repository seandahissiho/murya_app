import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';

class ScoreWidget extends StatelessWidget {
  final int value;
  final bool compact;
  final Color textColor;
  const ScoreWidget({
    super.key,
    required this.value,
    this.compact = false,
    this.textColor = AppColors.primaryDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    return Row(
      children: [
        Container(
          height: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) / 1.5,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.tinyMargin,
          ),
          child: Center(
            child: Text(
              "$value",
              style: isMobile
                  ? (!compact
                      ? theme.textTheme.labelLarge?.copyWith(height: 0, color: textColor)
                      : theme.textTheme.labelLarge?.copyWith(height: 0, color: textColor))
                  : (!compact
                      ? theme.textTheme.displayMedium?.copyWith(height: 1, color: textColor)
                      : theme.textTheme.labelLarge?.copyWith(height: 0, color: textColor)),
            ),
          ),
        ),
        AppSpacing.tinyMarginBox,
        SvgPicture.asset(
          AppIcons.diamondIconPath,
          width: isMobile ? mobileCTAHeight / (compact ? 2.5 : 2) : tabletAndAboveCTAHeight / (compact ? 2.5 : 2),
          height: isMobile ? mobileCTAHeight / (compact ? 2.5 : 2) : tabletAndAboveCTAHeight / (compact ? 2.5 : 2),
          colorFilter: const ColorFilter.mode(
            AppColors.primaryFocus,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }
}
