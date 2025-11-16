import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';

class ScoreWidget extends StatelessWidget {
  final int value;

  const ScoreWidget({super.key, required this.value});

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
                  ? theme.textTheme.labelLarge?.copyWith(height: 0)
                  : theme.textTheme.displayMedium?.copyWith(height: 1),
            ),
          ),
        ),
        AppSpacing.tinyMarginBox,
        SvgPicture.asset(
          AppIcons.diamondIconPath,
          width: isMobile ? mobileCTAHeight / 2 : tabletAndAboveCTAHeight / 2,
          height: isMobile ? mobileCTAHeight / 2 : tabletAndAboveCTAHeight / 2,
          colorFilter: const ColorFilter.mode(
            AppColors.primaryFocus,
            BlendMode.srcIn,
          ),
        ),
      ],
    );
  }
}
