import 'dart:async';
import 'dart:math' as math;

import 'package:beamer/beamer.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/modules/resources/resources_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/popup.dart';
import 'package:murya/components/score.dart';
import 'package:murya/components/skeletonizer.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/module.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/realtime/sse_service.dart';
import 'package:murya/screens/base.dart';

part '_resources_mobile.dart';
part '_resources_tablet+.dart';

class RessourcesLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.userRessourcesModule];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final Map<String, dynamic>? routeData = data as Map<String, dynamic>?;
    final dynamic payload = routeData?['data'];
    final bool openWaitingModal = payload is Map<String, dynamic> && payload['openWaitingModal'] == true;
    return [
      BeamPage(
        title: AppLocalizations.of(context).resourcesPageTitle,
        child: RessourcesScreen(openWaitingModal: openWaitingModal),
      ),
    ];
  }
}

class RessourcesScreen extends StatefulWidget {
  final bool openWaitingModal;

  const RessourcesScreen({super.key, this.openWaitingModal = false});

  @override
  State<RessourcesScreen> createState() => _RessourcesScreenState();
}

class _RessourcesScreenState extends State<RessourcesScreen> {
  bool _didShowWaitingModal = false;
  bool _isWaitingForResource = false;
  bool _sseConnected = true;
  bool _hasNavigatedToNewResource = false;
  Set<String> _knownResourceIds = {};
  DateTime? _waitingStartedAt;
  Timer? _pollTimer;
  StreamSubscription<bool>? _sseStatusSubscription;
  late final SseService _sseService;

  @override
  void initState() {
    super.initState();
    _sseService = context.read<SseService>();
    _sseConnected = _sseService.isConnected;
    _sseStatusSubscription = _sseService.connectionStatus.listen(_onSseStatus);
    _maybeShowWaitingModal();
  }

  @override
  void didUpdateWidget(covariant RessourcesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeShowWaitingModal();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _sseStatusSubscription?.cancel();
    super.dispose();
  }

  void _maybeShowWaitingModal() {
    if (!widget.openWaitingModal) {
      _stopWaitingForResource();
      return;
    }
    _startWaitingForResource();
    if (_didShowWaitingModal) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didShowWaitingModal) {
        return;
      }
      _didShowWaitingModal = true;
      _waitingModal(context, Theme.of(context));
    });
  }

  void _startWaitingForResource() {
    if (_isWaitingForResource) {
      return;
    }
    _isWaitingForResource = true;
    _waitingStartedAt = DateTime.now();
    _hasNavigatedToNewResource = false;
    _knownResourceIds = _collectResourceIds();
    _startPollingIfNeeded();
  }

  void _stopWaitingForResource() {
    _isWaitingForResource = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _onSseStatus(bool connected) {
    _sseConnected = connected;
    if (!_isWaitingForResource) {
      return;
    }
    if (_sseConnected) {
      _pollTimer?.cancel();
      _pollTimer = null;
    } else {
      _startPollingIfNeeded();
    }
  }

  void _startPollingIfNeeded() {
    if (_sseConnected || !_isWaitingForResource || _pollTimer != null) {
      return;
    }
    _pollResourcesOnce();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isWaitingForResource || _sseConnected) {
        _pollTimer?.cancel();
        _pollTimer = null;
        return;
      }
      _pollResourcesOnce();
    });
  }

  void _pollResourcesOnce() {
    final userJobId = context.read<JobBloc>().state.userCurrentJob?.id;
    if (userJobId == null || userJobId.isEmpty) {
      return;
    }
    context.read<ResourcesBloc>().add(LoadResources(userJobId: userJobId));
  }

  Set<String> _collectResourceIds() {
    final resourcesBloc = context.read<ResourcesBloc>();
    final ids = <String>{};
    for (final resource in [...resourcesBloc.articles, ...resourcesBloc.videos, ...resourcesBloc.podcasts]) {
      final id = resource.id;
      if (id != null && id.isNotEmpty) {
        ids.add(id);
      }
    }
    return ids;
  }

  void _handleResourcesState(ResourcesState state) {
    if (!_isWaitingForResource || _hasNavigatedToNewResource) {
      return;
    }
    if (state is! ResourcesLoaded) {
      return;
    }
    Resource? newResource;
    for (final resource in state.resources) {
      final id = resource.id;
      if (id == null || id.isEmpty || _knownResourceIds.contains(id)) {
        continue;
      }
      if (_knownResourceIds.isEmpty) {
        final createdAt = resource.createdAt;
        if (createdAt != null && _waitingStartedAt != null && !createdAt.isAfter(_waitingStartedAt!)) {
          continue;
        }
      }
      if (id.isNotEmpty) {
        newResource = resource;
        break;
      }
    }
    if (newResource == null) {
      return;
    }
    _hasNavigatedToNewResource = true;
    _stopWaitingForResource();
    _dismissWaitingModal();
    navigateToPath(
      context,
      to: AppRoutes.userResourceViewerModule.replaceFirst(':id', newResource.id!),
    );
  }

  void _dismissWaitingModal() {
    if (!mounted) {
      return;
    }
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ResourcesBloc, ResourcesState>(
      listener: (context, state) => _handleResourcesState(state),
      child: const BaseScreen(
        mobileScreen: MobileResourcesScreen(),
        tabletScreen: TabletResourcesScreen(),
        desktopScreen: TabletResourcesScreen(),
      ),
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
    final localizations = AppLocalizations.of(context);
    switch (widget.type) {
      case ResourceType.article:
        return localizations.resourceLabelSingular_article;
      case ResourceType.video:
        return localizations.resourceLabelSingular_video;
      case ResourceType.podcast:
        return localizations.resourceLabelSingular_podcast;
      default:
        return localizations.resourceLabelSingular_default;
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
                return await contentNotAvailablePopup(context);
                final int diamonds = context.read<ProfileBloc>().state.user.diamonds;
                final int cost = Costs.byType(widget.type);
                final canCreate = diamonds >= cost;
                final int remaining = diamonds - cost;
                final result = await displayPopUp(
                  context: this.context,
                  okText: AppLocalizations.of(context).popup_validate,
                  okEnabled: canCreate,
                  contents: [
                    SvgPicture.asset(
                      AppIcons.popupIconPath,
                    ),
                    AppSpacing.containerInsideMarginBox,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppLocalizations.of(context).popup_unlock_resource_title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: theme.textTheme.displayMedium?.fontSize,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    AppSpacing.groupMarginBox,
                    Text(
                      AppLocalizations.of(context).popup_unlock_resource_description,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.start,
                    ),
                    AppSpacing.containerInsideMarginBox,
                    _costRow(label: AppLocalizations.of(context).cost_creation_label, cost: cost),
                    AppSpacing.groupMarginBox,
                    _costRow(label: AppLocalizations.of(context).cost_current_balance_label, cost: diamonds),
                    AppSpacing.groupMarginBox,
                    _costRow(label: AppLocalizations.of(context).cost_remaining_balance_label, cost: remaining),
                    AppSpacing.sectionMarginBox,
                  ],
                );
                if (result == true && mounted && context.mounted) {
                  _waitingModal(context, theme);
                  final userJobId = context.read<JobBloc>().state.userCurrentJob?.id;
                  if (mounted && context.mounted && userJobId.isNotEmptyOrNull) {
                    Future.delayed(const Duration(seconds: 0), () {
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
                        AppLocalizations.of(context).create_resource_button(ressourceLabelSingular),
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
          final thumbnailUrl = resource.effectiveThumbnailUrl;
          return InkWell(
            onTap: () async {
              if (resource.id.isNotEmptyOrNull) {
                if (isMobile) {
                  return await contentNotAvailablePopup(context);
                }
                navigateToPath(
                  context,
                  to: AppRoutes.userResourceViewerModule.replaceFirst(
                    ':id',
                    resource.id!,
                  ),
                  data: resource,
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.groupMargin),
              decoration: const BoxDecoration(
                borderRadius: AppRadius.borderRadius28,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ThumbnailBackground(thumbnailUrl, index: index - 1),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryDefault.withValues(alpha: 0.25),
                            AppColors.primaryDefault.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.title ?? '',
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: AppColors.textInverted,
                              fontSize: theme.textTheme.displayMedium?.fontSize,
                              height: 0),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                        AppSpacing.containerInsideMarginSmallBox,
                        Text(
                          resource.createdAt?.formattedDate() ?? '',
                          style: theme.textTheme.labelLarge?.copyWith(color: AppColors.textInverted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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

void _waitingModal(BuildContext context, ThemeData theme) {
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
                  AppLocalizations.of(context).loading_creating_resource,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
          ],
        ),
      ),
      AppSpacing.groupMarginBox,
      Text(
        AppLocalizations.of(context).loading_murya_working,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.start,
      ),
      AppSpacing.elementMarginBox,
      Text(
        AppLocalizations.of(context).loading_analyzing_answers,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.start,
      ),
    ],
  );
}

Widget ThumbnailBackground(String? url, {int? index}) {
  // if (!url.isNotEmptyOrNull) {
  //   return const DecoratedBox(
  //     decoration: BoxDecoration(color: AppColors.primaryDefault),
  //   );
  // }
  if (url.isEmptyOrNull) {
    return _fallbackThumbnail(index: index);
  }

  if (((url ?? '').contains("mqdefault") || (url ?? '').contains("hqdefault") || (url ?? '').contains("sqdefault")) &&
      (url ?? '').contains("youtube")) {
    url = url?.replaceAll("mqdefault", "maxresdefault");
    url = url?.replaceAll("hqdefault", "maxresdefault");
    url = url?.replaceAll("sqdefault", "maxresdefault");
  }

  return CachedNetworkImage(
    imageUrl: url ?? '',
    fit: BoxFit.cover,
    placeholder: (context, url) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.primaryDefault),
      );
    },
    errorWidget: (context, url, error) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.primaryDefault),
      );
    },
  );
}

Widget _fallbackThumbnail({int? index}) {
  List<String> images = [
    AppImages.resourceFallback2,
    AppImages.resourceFallback4,
    AppImages.resourceFallback1,
    AppImages.resourceFallback3,
  ];
  final finalIndex = index ?? math.Random().nextInt(images.length);
  return Image.asset(
    images[finalIndex],
    fit: BoxFit.cover,
  );
}
