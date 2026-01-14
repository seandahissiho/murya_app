import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/blocs/modules/resources/resources_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/favorites.dart';
import 'package:murya/components/modules/app_module.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/models/module.dart';
import 'package:murya/models/resource.dart';

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
            validResources.sort(
              (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                  .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
            );
            final List<Resource> latestResources =
                validResources.isNotEmpty ? validResources.take(3).toList() : const <Resource>[];
            return AppModuleWidget(
              module: widget.module,
              onCardTap: () {
                navigateToPath(context, to: AppRoutes.userRessourcesModule);
              },
              hasData: latestResources.isNotEmpty,
              titleContent: widget.module.title(context),
              subtitleContent: FavoritesWidget(value: validResources.length),
              bodyContent: _resourcesStack(latestResources),
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
}

class RessourcesModuleContent extends StatelessWidget {
  final List<Resource> resources;

  const RessourcesModuleContent({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    return _RessourcesStackedResources(resources: resources);
  }
}

class _RessourcesStackedResources extends StatelessWidget {
  final List<Resource> resources;

  const _RessourcesStackedResources({required this.resources});

  @override
  Widget build(BuildContext context) {
    if (resources.isEmpty) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, _) {
        final theme = Theme.of(context);
        final bool isMobile = DeviceHelper.isMobile(context);
        final double offset = isMobile ? 10 : 14;
        final List<Resource> orderedResources = resources.reversed.toList();
        return Stack(
          children: List.generate(orderedResources.length, (index) {
            final resource = orderedResources[index];
            final double inset = offset * index;
            return Positioned(
              top: inset,
              left: inset,
              right: inset,
              bottom: inset,
              child: _ResourceCard(resource: resource, theme: theme),
            );
          }),
        );
      },
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final Resource resource;
  final ThemeData theme;

  const _ResourceCard({required this.resource, required this.theme});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = resource.effectiveThumbnailUrl;
    return Container(
      decoration: const BoxDecoration(
        borderRadius: AppRadius.borderRadius28,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: _thumbnailBackground(thumbnailUrl),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryDefault.withOpacity(0.05),
                    AppColors.primaryDefault.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: AutoSizeText(
                    resource.title ?? '',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.textInverted,
                      fontSize: theme.textTheme.displayMedium?.fontSize,
                      height: 0,
                    ),
                    minFontSize: 16,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
                AppSpacing.containerInsideMarginSmallBox,
                Flexible(
                  child: AutoSizeText(
                    resource.createdAt?.formattedDate ?? '',
                    style: theme.textTheme.labelLarge?.copyWith(color: AppColors.textInverted),
                    minFontSize: 12,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _thumbnailBackground(String? url) {
  if (!url.isNotEmptyOrNull) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: AppColors.primaryDefault),
    );
  }

  return Image.network(
    url!,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.primaryDefault),
      );
    },
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        return child;
      }
      return const DecoratedBox(
        decoration: BoxDecoration(color: AppColors.primaryDefault),
      );
    },
  );
}

Widget _resourcesStack(List<Resource> resources) {
  return RessourcesModuleContent(resources: resources);
}
