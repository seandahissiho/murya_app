import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/blocs/modules/resources/resources_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/modules/app_module.dart';
import 'package:murya/components/score.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/models/module.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/screens/ressources/resources.dart';

class RessourcesModuleWidget extends StatefulWidget {
  final Module module;
  final VoidCallback? onSizeChanged;
  final Widget? dragHandle;
  final GlobalKey? tileKey;
  final EdgeInsetsGeometry cardMargin;

  const RessourcesModuleWidget({
    super.key,
    required this.module,
    this.onSizeChanged,
    this.dragHandle,
    this.tileKey,
    this.cardMargin = const EdgeInsets.all(4),
  });

  @override
  State<RessourcesModuleWidget> createState() => _RessourcesModuleWidgetState();
}

class _RessourcesModuleWidgetState extends State<RessourcesModuleWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModulesBloc, ModulesState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        return BlocConsumer<ResourcesBloc, ResourcesState>(
          listener: (context, state) {
            setState(() {});
          },
          builder: (context, state) {
            final resourcesBloc = context.read<ResourcesBloc>();
            final List<Resource> allResources = [
              ...resourcesBloc.articles,
              ...resourcesBloc.podcasts,
              ...resourcesBloc.videos,
            ];
            final List<Resource> validResources =
                allResources.where((resource) => resource.id.isNotEmptyOrNull).toList();
            if (validResources.isNotEmpty) {
              validResources.sort(
                (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                    .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
              );
            }
            final List<Resource> latestResources = getLastOfEachType(validResources);
            return AppModuleWidget(
              module: widget.module,
              onCardTap: () {
                navigateToPath(context, to: AppRoutes.userRessourcesModule);
              },
              hasData: latestResources.isNotEmpty,
              titleContent: widget.module.title(context),
              subtitleContent: FavoritesWidget(
                value: validResources.length,
                // iconColor: AppColors.primaryDefault,
                isLandingPage: true,
              ),
              bodyContent: _resourcesStack(latestResources, widget.module),
              footerContent: AppXButton(
                shrinkWrap: false,
                onPressed: widget.module.button1OnPressed(context),
                isLoading: false,
                text: widget.module.button1Text(context) ?? '',
              ),
              onSizeChanged: widget.onSizeChanged,
              dragHandle: widget.dragHandle,
              tileKey: widget.tileKey,
              cardMargin: widget.cardMargin,
            );
          },
        );
      },
    );
  }

  List<Resource> getLastOfEachType(List<Resource> validResources) {
    final Map<ResourceType, Resource> latestByType = {};

    for (var resource in validResources) {
      final type = resource.type;
      if (type != null && !latestByType.containsKey(type)) {
        latestByType[type] = resource;
      }
    }

    return latestByType.values.toList();
  }
}

class RessourcesModuleContent extends StatelessWidget {
  final Module module;
  final List<Resource> resources;

  const RessourcesModuleContent({super.key, required this.resources, required this.module});

  @override
  Widget build(BuildContext context) {
    return _RessourcesStackedResources(resources: resources, module: module);
  }
}

class _RessourcesStackedResources extends StatelessWidget {
  final Module module;
  final List<Resource> resources;

  const _RessourcesStackedResources({required this.resources, required this.module});

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final bool isMobile = DeviceHelper.isMobile(context);

        // ✅ Offset “stack” comme l’image : léger décalage bas + droite
        final double offsetBase = isMobile ? 10 : 14;
        final double offset = offsetBase * _stackScale(constraints, isMobile);

        // ✅ Important : on dessine d’abord les cartes du fond, puis celle du dessus
        final orderedResources = resources.reversed.toList();
        final topIndex = orderedResources.length - 1;

        return Stack(
          clipBehavior: Clip.none, // ✅ pour voir dépasser les cartes derrière
          children: List.generate(orderedResources.length, (index) {
            final orderedResources = resources.reversed.toList();
            final int maxDepth = orderedResources.length - 1;

            return Stack(
              clipBehavior: Clip.none,
              children: List.generate(orderedResources.length, (index) {
                final resource = orderedResources[index];

                // ✅ depth = 0 => carte du dessus (pas décalée)
                // ✅ depth augmente => cartes derrière (de + en + décalées)
                final int depth = maxDepth - index;

                final bool isTopCard = depth == 0;

                final double dx = offset * depth;
                final double dy = offset * depth;
                return Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(dx, dy),
                    child: ResourceItemWidget(
                      resource: resource,
                      module: module,
                      scale: _stackScale(constraints, isMobile),
                      // theme: theme,
                      // isTopCard: isTopCard,
                      index: index + 1,
                    ),
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }

  double _stackScale(BoxConstraints constraints, bool isMobile) {
    final double baseSize = isMobile ? 160 : 220;
    final double effectiveSize = math.min(constraints.maxHeight, constraints.maxWidth);
    if (effectiveSize <= 0) return 1.0;
    return math.min(1.0, effectiveSize / baseSize);
  }
}

class _ResourceCard extends StatelessWidget {
  final Resource resource;
  final ThemeData theme;
  final bool isTopCard;
  final int? index;

  const _ResourceCard({
    required this.resource,
    required this.theme,
    required this.isTopCard,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = resource.effectiveThumbnailUrl;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = _contentScale(constraints);
        final double padding = (18.0 * scale).clamp(12.0, 22.0);
        final double smallGap = (10.0 * scale).clamp(6.0, 14.0);

        final double titleFontSize = (28.0 * scale).clamp(16.0, 32.0);
        final double dateFontSize = (14.0 * scale).clamp(12.0, 16.0);

        final Color borderColor = AppColors.whiteSwatch;

        final double borderWidth = isTopCard ? 2.0 : 2.0;

        return Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderRadius28,
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(26.0)),
            child: Stack(
              children: [
                // Background image (pixelisée dans ton screenshot => normal)
                Positioned.fill(child: ThumbnailBackground(thumbnailUrl, index: index)),

                // Dark gradient overlay (pour lisibilité texte)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // // ✅ Top strip jaune (visible uniquement sur la carte du dessus)
                // if (isTopCard)
                //   Positioned(
                //     top: 0,
                //     left: 0,
                //     right: 0,
                //     height: (12.0 * scale).clamp(8.0, 14.0),
                //     child: DecoratedBox(
                //       decoration: BoxDecoration(
                //         color: borderColor,
                //         borderRadius: const BorderRadius.only(
                //           topLeft: Radius.circular(28),
                //           topRight: Radius.circular(28),
                //         ),
                //       ),
                //     ),
                //   ),

                // Content bottom-left
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        resource.title ?? '',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.textInverted,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w900,
                          height: 1.05, // ✅ important (ton "height: 0" cassait tout)
                        ),
                        minFontSize: 14,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: smallGap),
                      AutoSizeText(
                        resource.createdAt?.formattedDate() ?? '',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.textInverted,
                          fontSize: dateFontSize,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                        minFontSize: 10,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _contentScale(BoxConstraints constraints) {
    // Plus la card est petite, plus on réduit padding/fonts
    final h = constraints.maxHeight;
    if (h <= 0) return 1.0;
    return math.min(1.0, h / 220.0);
  }
}

// Widget _thumbnailBackground(String? url) {
//   if (url == null || url.trim().isEmpty) {
//     return const DecoratedBox(
//       decoration: BoxDecoration(color: AppColors.primaryDefault),
//     );
//   }
//
//   return Image.network(
//     url,
//     fit: BoxFit.cover,
//     errorBuilder: (_, __, ___) {
//       return const DecoratedBox(
//         decoration: BoxDecoration(color: AppColors.primaryDefault),
//       );
//     },
//     loadingBuilder: (context, child, loadingProgress) {
//       if (loadingProgress == null) return child;
//       return const DecoratedBox(
//         decoration: BoxDecoration(color: AppColors.primaryDefault),
//       );
//     },
//   );
// }

Widget _resourcesStack(List<Resource> resources, Module module) {
  return LayoutBuilder(builder: (context, constraints) {
    return Center(
      child: SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxHeight,
        child: Padding(
          padding: EdgeInsets.only(
            top: module.boxType == AppModuleType.type1 ? 0 : 12.0,
            bottom: module.boxType == AppModuleType.type1 ? 20 : 40.0,
            left: module.boxType == AppModuleType.type1 ? 0 : 8.0,
            right: module.boxType == AppModuleType.type1 ? 20 : 40.0,
          ),
          child: RessourcesModuleContent(resources: resources, module: module),
        ),
      ),
    );
  });
}
