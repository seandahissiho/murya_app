import 'package:beamer/beamer.dart';
import 'package:carousel_slider/carousel_slider.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/modules/resources/resources_bloc.dart';
import 'package:murya/components/popup.dart';
import 'package:murya/components/score.dart';
import 'package:murya/components/skeletonizer.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/screens/base.dart';

part '_resources_mobile.dart';
part '_resources_tablet+.dart';

class RessourcesLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.userRessourcesModule];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('ressources-page-$languageCode'),
        title: 'Ressources Page',
        child: const RessourcesScreen(),
      ),
    ];
  }
}

class RessourcesScreen extends StatelessWidget {
  const RessourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileResourcesScreen(),
      tabletScreen: TabletResourcesScreen(),
      desktopScreen: TabletResourcesScreen(),
    );
  }
}

class ResourcesCarousel extends StatefulWidget {
  final ResourceType type;
  final List<Resource> resources;

  const ResourcesCarousel({super.key, required this.resources, required this.type});

  @override
  State<ResourcesCarousel> createState() => _ResourcesCarouselState();
}

class _ResourcesCarouselState extends State<ResourcesCarousel> {
  String get ressourceLabelSingular {
    switch (widget.type) {
      case ResourceType.article:
        return "un article";
      case ResourceType.video:
        return "une vidéo";
      case ResourceType.podcast:
        return "un podcast";
      default:
        return "une ressource";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    final appSize = AppSize(context);

    final double height = isMobile ? (appSize.screenWidth * .8) / 1.618 : 288;
    return SizedBox(
      height: height,
      width: appSize.screenWidth,
      child: CarouselSlider.builder(
        itemCount: widget.resources.length + 1,
        options: CarouselOptions(
          // scrollPhysics: const NeverScrollableScrollPhysics(),
          height: height,
          enableInfiniteScroll: false,
          disableCenter: true,
          pageSnapping: true,
          padEnds: false,
          viewportFraction: (height * (isMobile ? 1.168 : 1.393)) / appSize.screenWidth,
          // aspectRatio: 1,
        ),
        itemBuilder: (context, index, realIndex) {
          if (index == 0) {
            return InkWell(
              onTap: () async {
                final int diamonds = context.read<ProfileBloc>().state.user.diamonds;
                final int cost = Costs.byType(widget.type);
                final canCreate = diamonds >= cost;
                final int remaining = diamonds - cost;
                final result = await displayPopUp(
                  context: this.context,
                  okText: "Valider",
                  okEnabled: canCreate,
                  contents: [
                    SvgPicture.asset(
                      AppIcons.popupIconPath,
                    ),
                    AppSpacing.containerInsideMarginBox,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Débloquer votre ressource ?",
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: theme.textTheme.displayMedium?.fontSize,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    AppSpacing.groupMarginBox,
                    Text(
                      "Utilisez vos points pour générer votre article personnalisé. L'IA de Murya l'adaptera instantanément à vos réponses du jour.",
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.start,
                    ),
                    AppSpacing.containerInsideMarginBox,
                    _costRow(label: "Coût de la création", cost: cost),
                    AppSpacing.groupMarginBox,
                    _costRow(label: "Votre solde actuel", cost: diamonds),
                    AppSpacing.groupMarginBox,
                    _costRow(label: "Votre solde restant (après création)", cost: remaining),
                    AppSpacing.sectionMarginBox,
                  ],
                );
                if (result == true && mounted && context.mounted) {
                  displayPopUp(
                    context: context,
                    barrierDismissible: false,
                    noActions: true,
                    contents: [
                      SizedBox(
                        height: 32,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SvgPicture.asset(
                                      AppIcons.appIcon2Path,
                                      width: 16,
                                      height: 16,
                                      colorFilter: const ColorFilter.mode(AppColors.primaryFocus, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryFocus),
                                    constraints: BoxConstraints(
                                      maxHeight: 32,
                                      maxWidth: 26,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.groupMarginBox,
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Création de votre ressource...",
                                  style: theme.textTheme.labelLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.groupMarginBox,
                      Text(
                        "Murya est au travail !",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      AppSpacing.elementMarginBox,
                      Text(
                        "Nous analysons vos 10 réponses pour rédiger un article unique, parfaitement adapté aux compétences que vous devez renforcer.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  );
                  final userJobId = context.read<JobBloc>().state.userCurrentJob?.id;
                  if (mounted && context.mounted && userJobId.isNotEmptyOrNull) {
                    Future.delayed(const Duration(seconds: 5), () {
                      if (mounted && context.mounted) {
                        context.read<ResourcesBloc>().add(GenerateResource(type: widget.type, userJobId: userJobId!));
                      }
                    });
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.groupMargin),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: AppRadius.borderRadius28,
                  border: Border.all(color: AppColors.borderMedium, width: 1),
                ),
                padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderMedium, width: 2),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.elementMargin),
                      child: SvgPicture.asset(
                        AppIcons.addResourceIconPath,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                      ),
                    ),
                    AppSpacing.containerInsideMarginSmallBox,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Créer $ressourceLabelSingular",
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: theme.textTheme.displayMedium?.fontSize,
                            height: 0),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final resource = widget.resources[index - 1];
          return Container(
            margin: const EdgeInsets.only(right: AppSpacing.groupMargin),
            decoration: const BoxDecoration(
              color: AppColors.primaryDefault,
              borderRadius: AppRadius.borderRadius28,
            ),
            padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title ?? '',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: Colors.white, fontSize: theme.textTheme.displayMedium?.fontSize, height: 0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
                AppSpacing.containerInsideMarginSmallBox,
                Text(
                  resource.createdAt?.formattedDate ?? '',
                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _costRow({required String label, required int cost}) {
    final theme = Theme.of(context);
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.labelLarge,
              maxLines: 2,
            ),
          ),
          AppSpacing.groupMarginBox,
          ScoreWidget(
            value: cost,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class Costs {
  static const int articleCreationCost = 1000;
  static const int videoCreationCost = 3500;
  static const int podcastCreationCost = 2000;

  static int byType(ResourceType type) {
    switch (type) {
      case ResourceType.article:
        return articleCreationCost;
      case ResourceType.video:
        return videoCreationCost;
      case ResourceType.podcast:
        return podcastCreationCost;
      default:
        return articleCreationCost;
    }
  }
}
