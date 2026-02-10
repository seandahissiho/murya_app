import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/popup.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/l10n/l10n.dart';

Future<void> contentNotAvailableModal(BuildContext context) async {
  final isMobile = DeviceHelper.isMobile(context);
  final theme = Theme.of(context);
  final locale = AppLocalizations.of(context);
  return await displayPopUp(
    context: context,
    okText: locale.common_ok,
    bgColor: const Color(0xFFE7E5DD),
    // okEnabled: quizLoaded,
    noActions: true,
    contents: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: AppRadius.tiny,
                ),
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  AppIcons.warningIconPath,
                  width: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                  height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                ),
              ),
            ],
          ),
          AppSpacing.spacing8_Box,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  child: Text(
                    locale.popup_contentNotAvailable_title,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                AppSpacing.spacing4_Box,
                Text(
                  locale.popup_contentNotAvailable_body,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
      AppSpacing.spacing16_Box,
      const Divider(color: AppColors.borderMedium, height: 0, endIndent: 0, indent: 0),
      AppSpacing.spacing16_Box,
      Align(
        alignment: Alignment.centerRight,
        child: AppXButton(
          text: locale.popup_contentNotAvailable_cta,
          shrinkWrap: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          isLoading: false,
        ),
      ),
    ],
  );
}
