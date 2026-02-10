import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/popup.dart';
import 'package:murya/components/score.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';

Future<dynamic> quizzStartModal(
  BuildContext context, {
  required String jobId,
  required String jobTitle,
}) async {
  final isMobile = DeviceHelper.isMobile(context);
  final theme = Theme.of(context);
  final locale = AppLocalizations.of(context);
  return await displayPopUp(
    context: context,
    okText: locale.common_ok,
    bgColor: const Color(0xFFE7E5DD),
    width: 450,
    // okEnabled: quizLoaded,
    noActions: true,
    contents: [
      Row(
        children: [
          Expanded(
            child: Text(
              locale.quiz_start_title_challenge,
              style: theme.textTheme.labelLarge,
            ),
          ),
          // close button
          InkWell(
            onTap: () {
              navigateToPath(
                context,
                to: AppRoutes.jobDetails.replaceFirst(':id', jobId),
                data: {'jobTitle': jobTitle},
              );
            },
            child: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
      AppSpacing.spacing12_Box,
      const Divider(color: AppColors.borderMedium, height: 0, endIndent: 0, indent: 0),
      AppSpacing.spacing16_Box,
      // Répondez à 10 questions rapides pour générer votre ressource sur-mesure.
      RichText(
          text: TextSpan(
        text: locale.quiz_start_prompt_prefix,
        style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
        children: [
          TextSpan(
            text: locale.quiz_start_prompt_emphasis,
            style: theme.textTheme.labelMedium!.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          TextSpan(
            text: locale.quiz_start_prompt_suffix,
            style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
          ),
        ],
      )),
      AppSpacing.spacing16_Box,
      // Durée : Moins de 5 min
      Text(
        locale.quiz_start_duration,
        style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
      ),
      AppSpacing.spacing16_Box,
      // 💡 Conseil
      // Répondez à l’instinct pour un résultat plus juste !
      Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: AppRadius.small,
        ),
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.quiz_start_tip_title,
              style: theme.textTheme.labelMedium!.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            AppSpacing.spacing8_Box,
            Text(
              locale.quiz_start_tip_text,
              style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      AppSpacing.spacing24_Box,
      AppXButton(
        text: locale.quiz_lets_go,
        shrinkWrap: false,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop(true);
        },
        isLoading: false,
      ),
    ],
  );
}

Future<void> quizzExitModal(
  BuildContext context, {
  required String jobId,
  required String jobTitle,
}) async {
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
                    locale.quiz_exit_title,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                AppSpacing.spacing4_Box,
                Text(
                  locale.quiz_exit_body,
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
      Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppXButton(
            text: locale.quiz_exit_quit,
            shrinkWrap: true,
            onPressed: () {
              navigateToPath(
                context,
                to: AppRoutes.jobDetails.replaceFirst(':id', jobId),
                data: {'jobTitle': jobTitle},
              );
            },
            isLoading: false,
            shadowColor: AppColors.borderMedium,
            bgColor: AppColors.backgroundColor,
            fgColor: AppColors.textPrimary,
            borderColor: AppColors.borderMedium,
            hoverColor: AppButtonColors.secondarySurfaceHover,
            onPressedColor: AppButtonColors.secondarySurfacePressed,
          ),
          AppSpacing.spacing8_Box,
          AppXButton(
            text: locale.quiz_exit_resume,
            shrinkWrap: true,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            isLoading: false,
          ),
        ],
      ),
    ],
  );
}

Future<dynamic> quizzEndModal(
  BuildContext context, {
  required int duration,
  required int score,
  required int goodAnswers,
  required int badAnswers,
}) async {
  final isMobile = DeviceHelper.isMobile(context);
  final theme = Theme.of(context);
  final locale = AppLocalizations.of(context);
  return await displayPopUp(
    context: context,
    okText: locale.common_ok,
    bgColor: const Color(0xFFE7E5DD),
    width: 450,
    // okEnabled: quizLoaded,
    noActions: true,
    contents: [
      Row(
        children: [
          Expanded(
            child: Text(
              locale.quiz_completed_title,
              style: theme.textTheme.labelLarge,
            ),
          ),
          // close button
          ScoreWidget(value: score, isReward: true),
        ],
      ),
      AppSpacing.spacing12_Box,
      const Divider(color: AppColors.borderMedium, height: 0, endIndent: 0, indent: 0),
      AppSpacing.spacing16_Box,
      Text(
        locale.quiz_completed_subtitle,
        style: theme.textTheme.labelLarge!.copyWith(color: AppColors.textPrimary),
      ),
      AppSpacing.spacing20_Box,
      Text(
        locale.quiz_completed_description,
        style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
      ),
      AppSpacing.spacing24_Box,
      Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 14),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: AppRadius.small,
                  border: Border.fromBorderSide(BorderSide(color: AppColors.borderMedium)),
                ),
                padding: const EdgeInsets.only(
                  top: AppSpacing.spacing16 + AppSpacing.spacing12,
                  bottom: AppSpacing.spacing16,
                  left: AppSpacing.spacing16,
                  right: AppSpacing.spacing16,
                ),
                width: double.infinity,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Spacer(flex: 3),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                AppIcons.checkmarkIconPath,
                                width: 40,
                                height: 40,
                                colorFilter: const ColorFilter.mode(AppColors.successText, BlendMode.srcIn),
                              ),
                              AppSpacing.spacing2_Box,
                              Text(
                                locale.quiz_result_correct,
                                style: theme.textTheme.bodyLarge!.copyWith(color: AppColors.successText),
                              ),
                            ],
                          ),
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: AppRadius.tiny,
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16, vertical: AppSpacing.spacing12),
                      child: Text(
                        "$goodAnswers - $badAnswers",
                        // font-family: Anton;
                        // font-weight: 400;
                        // font-style: Regular;
                        // font-size: 32px;
                        // leading-trim: NONE;
                        // line-height: 38px;
                        // letter-spacing: -2%;
                        // vertical-align: middle;
                        style: GoogleFonts.anton(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w400,
                          height: 38 / 32,
                          letterSpacing: -0.02 * 32,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Spacer(flex: 2),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                AppIcons.deleteDisabled1IconPath,
                                width: 40,
                                height: 40,
                                colorFilter: const ColorFilter.mode(AppColors.errorText, BlendMode.srcIn),
                              ),
                              AppSpacing.spacing2_Box,
                              Text(
                                locale.quiz_result_incorrect,
                                style: theme.textTheme.bodyLarge!.copyWith(color: AppColors.errorText),
                              ),
                            ],
                          ),
                          const Spacer(flex: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDefault,
                    borderRadius: AppRadius.tiny,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing8, vertical: AppSpacing.spacing4),
                  // Temps : 5 min
                  child: Text(
                    locale.quiz_time_minutes(duration),
                    style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.textInverted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      AppSpacing.spacing24_Box,
      AppXButton(
        text: locale.quiz_continue,
        shrinkWrap: false,
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop(true);
        },
        isLoading: false,
      ),
    ],
  );
}
