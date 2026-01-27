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
import 'package:murya/components/app_button.dart';
import 'package:murya/components/app_footer.dart';
import 'package:murya/components/fil_arianne.dart';
import 'package:murya/components/skeletonizer.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/module.dart';
import 'package:murya/screens/base.dart';
import 'package:murya/screens/job_details/job_details.dart';

part '_competencies_family_details_mobile.dart';
part '_competencies_family_details_tablet+.dart';

class CfDetailsLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.competencyFamilyDetails];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    final Map<String, dynamic>? routeData = data as Map<String, dynamic>?;
    final dynamic payload = routeData?['data'];
    final String familyName =
        payload is Map<String, dynamic> && payload['familyName'] is String ? payload['familyName'] as String : '';
    final String pageTitle = familyName.isNotEmpty ? 'Murya - $familyName' : 'Murya';
    return [
      BeamPage(
        key: ValueKey('cfDetails-page-$languageCode'),
        title: pageTitle,
        child: const CfDetailsScreen(),
      ),
    ];
  }
}

class CfDetailsScreen extends StatelessWidget {
  const CfDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileCfDetailsScreen(),
      tabletScreen: TabletCfDetailsScreen(),
      desktopScreen: TabletCfDetailsScreen(),
    );
  }
}

class CompetencyCard extends StatelessWidget {
  final Competency competency;

  const CompetencyCard({super.key, required this.competency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    final locale = AppLocalizations.of(context);

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        decoration: const BoxDecoration(
          borderRadius: AppRadius.medium,
          color: AppColors.secondaryDefault,
        ),
        padding: const EdgeInsets.all(AppSpacing.groupMargin),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.8,
                    child: Text(
                      " ${competency.name}",
                      style: (isMobile ? theme.textTheme.labelLarge : theme.textTheme.displayMedium)
                          ?.copyWith(color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.elementMarginBox,
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TagWidget(type: competency.type),
                      AppSpacing.elementMarginBox,
                      TagWidget(type: competency.level),
                      if (isMobile) ...[
                        const Spacer(),
                        Tooltip(
                          decoration: const BoxDecoration(
                            color: AppColors.primaryDefault,
                            borderRadius: AppRadius.tinyTiny,
                          ),
                          preferBelow: false,
                          message: competency.rating?.localizedTooltipText(context) ??
                              CompetencyRating.moyen.localizedTooltipText(context),
                          // font-family: Inter;
                          // font-weight: 400;
                          // font-style: Regular;
                          // font-size: 14px;
                          // leading-trim: NONE;
                          // line-height: 20px;
                          // letter-spacing: 0%;
                          textStyle: GoogleFonts.inter(
                            color: const Color(0xFFE5E5E5),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 20 / 14,
                          ),
                          child: SvgPicture.asset(
                            competency.rating?.iconAssetPath ?? AppIcons.expressionlessFacePath,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            if (!isMobile) ...[
              AppSpacing.groupMarginBox,
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: AppXButton(
                      shrinkWrap: true,
                      onPressed: () async {
                        return await contentNotAvailablePopup(context);
                      },
                      isLoading: false,
                      text: locale.consult,
                    ),
                  ),
                  AppSpacing.groupMarginBox,
                  Tooltip(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDefault,
                      borderRadius: AppRadius.tinyTiny,
                    ),
                    textStyle: GoogleFonts.inter(
                      color: const Color(0xFFE5E5E5),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14,
                    ),
                    preferBelow: false,
                    message: competency.rating?.localizedTooltipText(context) ??
                        CompetencyRating.moyen.localizedTooltipText(context),
                    child: SvgPicture.asset(
                      competency.rating?.iconAssetPath ?? AppIcons.expressionlessFacePath,
                      width: 32,
                      height: 32,
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      );
    });
  }
}

class TagWidget extends StatelessWidget {
  final dynamic type;

  const TagWidget({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    if (type == null) {
      return const SizedBox.shrink();
    }
    if (type is! CompetencyType && type is! Level) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: _getTagColor(type),
        borderRadius: AppRadius.medium,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.elementMargin,
        vertical: AppSpacing.tinyMargin,
      ),
      child: Text(
        _getTypeLabel(type, context),
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getTextColor(type),
          // fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _getTagColor(type) {
    if (type is CompetencyType) {
      switch (type) {
        case CompetencyType.softSkill:
          return AppColors.tagSoftSkill;
        case CompetencyType.hardSkill:
          return AppColors.tagHardSkill;
      }
    } else if (type is Level) {
      switch (type) {
        case Level.beginner:
          return AppColors.tagBeginnerLevel;
        case Level.intermediate:
          return AppColors.tagIntermediateLevel;
        case Level.advanced:
          return AppColors.tagAdvancedLevel;
        case Level.expert:
          return AppColors.tagExpertLevel;
      }
    }
  }

  _getTextColor(type) {
    if (type is CompetencyType) {
      switch (type) {
        case CompetencyType.softSkill:
          return AppColors.tagSoftSkillText;
        case CompetencyType.hardSkill:
          return AppColors.tagHardSkillText;
      }
    } else if (type is Level) {
      switch (type) {
        case Level.beginner:
          return AppColors.tagBeginnerLevelText;
        case Level.intermediate:
          return AppColors.tagIntermediateLevelText;
        case Level.advanced:
          return AppColors.tagAdvancedLevelText;
        case Level.expert:
          return AppColors.tagExpertLevelText;
      }
    }
  }

  String _getTypeLabel(type, BuildContext context) {
    if (type is CompetencyType) {
      return type.localisedName(context);
    } else if (type is Level) {
      return type.localisedName(context);
    }
    return '';
  }
}
