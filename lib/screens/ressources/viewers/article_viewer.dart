part of 'viewer_handler.dart';

class ArticleViewer extends StatelessWidget {
  final Resource resource;

  const ArticleViewer({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      mobileScreen: MobileArticleViewerScreen(resource: resource),
      tabletScreen: TabletArticleViewerScreen(resource: resource),
      desktopScreen: TabletArticleViewerScreen(resource: resource),
    );
  }
}

class MobileArticleViewerScreen extends StatefulWidget {
  final Resource resource;

  const MobileArticleViewerScreen({super.key, required this.resource});

  @override
  State<MobileArticleViewerScreen> createState() => _MobileArticleViewerScreenState();
}

class _MobileArticleViewerScreenState extends State<MobileArticleViewerScreen> {
  bool _readSent = false;

  @override
  void dispose() {
    _sendReadIfNeeded();
    super.dispose();
  }

  void _sendReadIfNeeded() {
    if (_readSent) return;
    final resourceId = widget.resource.id;
    if (resourceId == null || resourceId.isEmpty) return;
    if (widget.resource.userState?.readAt != null) return;
    _readSent = true;
    context.read<ResourcesBloc>().add(ReadResource(resourceId: resourceId, progress: 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final appSize = AppSize(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        AppSpacing.spacing40_Box,
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TabletArticleViewerScreen extends StatefulWidget {
  final Resource resource;

  const TabletArticleViewerScreen({super.key, required this.resource});

  @override
  State<TabletArticleViewerScreen> createState() => _TabletArticleViewerScreenState();
}

class _TabletArticleViewerScreenState extends State<TabletArticleViewerScreen> {
  int hoveredIndex = -1;
  int selectedIndex = -1;
  final TocController tocController = TocController();
  final AutoScrollController controller = AutoScrollController();
  int currentIndex = 0;
  bool _readSent = false;
  bool fromSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history = Beamer.of(context).beamingHistory;
      if (history.length > 1) {
        final lastBeamState = history[history.length - 2];
        final lastPath = lastBeamState.state.routeInformation.uri.path.toString(); // ← ceci est le path
        fromSearch = lastPath == AppRoutes.searchModule;
        setState(() {});
        // load resource content if needed
        if (fromSearch) {
          final resourceId = widget.resource.id;
          if (resourceId != null && resourceId.isNotEmpty) {
            context.read<ResourcesBloc>().add(LoadResourceDetails(resourceId: resourceId));
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _sendReadIfNeeded();
    super.dispose();
  }

  void _sendReadIfNeeded() {
    if (_readSent) return;
    final resourceId = widget.resource.id;
    if (resourceId == null || resourceId.isEmpty) return;
    if (widget.resource.userState?.readAt != null) return;
    _readSent = true;
    context.read<ResourcesBloc>().add(ReadResource(resourceId: resourceId, progress: 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final appSize = AppSize(context);
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            AppXReturnButton(destination: fromSearch ? AppRoutes.searchModule : AppRoutes.userRessourcesModule),
            AppSpacing.spacing16_Box,
            Expanded(
              child: AppBreadcrumb(
                items: [
                  BreadcrumbItem(
                    label: AppLocalizations.of(context).mediaLibrary,
                    onTap: () => navigateToPath(context, to: AppRoutes.userRessourcesModule),
                  ),
                  BreadcrumbItem(label: widget.resource.title ?? ''),
                ],
                inactiveTextStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textTertiary,
                ),
                inactiveHoverTextStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary, // hover
                  decoration: TextDecoration.underline, // optionnel
                ),
                activeTextStyle: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
                scrollable: true,
              ),
            ),
            const AppXCloseButton(),
          ],
        ),
        AppSpacing.spacing40_Box,
        Expanded(
          child: Row(
            children: [
              Expanded(
                // child: TocWidget(controller: controller),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: AppRadius.large,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.spacing24),
                        child: Text(AppLocalizations.of(context).summary, style: theme.textTheme.labelLarge),
                      ),
                      const Divider(
                        height: 0,
                        color: AppColors.borderMedium,
                        thickness: 1,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.spacing24),
                          child: TocWidget(
                            controller: tocController,
                            itemBuilder: (data) {
                              final index = data.index;
                              final toc = data.toc;
                              final node = toc.node;
                              final level = headingTag2Level[node.headingConfig.tag] ?? 1;

                              final bool isHovered = hoveredIndex == index;
                              final bool isSelected = selectedIndex == index;

                              return MouseRegion(
                                onHover: (_) {
                                  setState(() {
                                    hoveredIndex = index;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    hoveredIndex = -1;
                                  });
                                },
                                child: InkWell(
                                  onTap: () {
                                    // scroll markdown to the corresponding heading
                                    tocController.jumpToIndex(toc.widgetIndex);

                                    // update TocWidget's current index
                                    data.refreshIndexCallback(index);

                                    // your own selected state
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: (isHovered || isSelected) ? AppColors.secondaryHover : null,
                                      borderRadius: AppRadius.tiny,
                                    ),
                                    padding: const EdgeInsets.all(
                                      AppSpacing.spacing12,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 12.0 * (level - 1) * 0),
                                      child: Row(
                                        children: [
                                          // bullet
                                          Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.secondaryDefault,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.borderMedium,
                                                width: 1,
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(AppSpacing.spacing8 + AppSpacing.spacing2),
                                            child: Center(
                                              child: Text((index + 1).toString()),
                                            ),
                                          ),
                                          AppSpacing.spacing8_Box,

                                          // actual heading title from markdown
                                          Expanded(
                                            child: ProxyRichText(
                                              node
                                                  .copy(
                                                    headingConfig: _TocHeadingConfig(
                                                      // use your theme style but you can switch for selected if you want
                                                      (isSelected
                                                              ? theme.textTheme.bodyLarge
                                                                  ?.copyWith(color: AppColors.textPrimary)
                                                              : theme.textTheme.bodyLarge
                                                                  ?.copyWith(color: AppColors.textPrimary)) ??
                                                          defaultTocTextStyle,
                                                      node.headingConfig.tag,
                                                    ),
                                                  )
                                                  .build(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              AppSpacing.spacing16_Box,
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: AppRadius.large,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.spacing24),
                        child: Text(AppLocalizations.of(context).article, style: theme.textTheme.labelLarge),
                      ),
                      const Divider(
                        height: 0,
                        color: AppColors.borderMedium,
                        thickness: 1,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.spacing24),
                          child: MarkdownWidget(
                            tocController: tocController,
                            data: widget.resource.content ?? '',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TocHeadingConfig extends HeadingConfig {
  @override
  final TextStyle style;
  @override
  final String tag;

  _TocHeadingConfig(this.style, this.tag);
}
