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
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _syncLikeState();
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
  void didUpdateWidget(covariant TabletArticleViewerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resource.userState?.isLikedAt != widget.resource.userState?.isLikedAt) {
      _syncLikeState();
    }
  }

  void _syncLikeState() {
    _isLiked = widget.resource.userState?.isLikedAt != null;
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
                    label: !fromSearch
                        ? AppLocalizations.of(context).mediaLibrary
                        : AppLocalizations.of(context).search_filter_resource,
                    onTap: () => navigateToPath(context,
                        to: !fromSearch ? AppRoutes.userRessourcesModule : AppRoutes.searchModule),
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
                  decoration: BoxDecoration(
                    color: AppColors.whiteSwatch,
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
                        color: AppColors.borderLight,
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
                  decoration: BoxDecoration(
                    color: AppColors.whiteSwatch,
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
                        color: AppColors.borderLight,
                        thickness: 1,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.spacing24),
                          child: _ArticleScrollableContent(
                            tocController: tocController,
                            data: widget.resource.content ?? '',
                            header: Container(
                              height: 348,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: AppRadius.small,
                                border: Border(
                                  top: BorderSide(
                                    // rgba(255, 214, 0, 1)
                                    color: Color.fromRGBO(255, 214, 0, 1),
                                    width: AppRadius.smallRadius + 10,
                                  ),
                                ),
                                // asset image
                                image: DecorationImage(
                                  image: AssetImage(AppImages.articleHeaderPath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              padding: const EdgeInsets.all(AppSpacing.spacing24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  AppSpacing.spacing20_Box,
                                  ResourceIconWidget(
                                      resource: widget.resource, outlined: true, color: AppColors.whiteSwatch),
                                  AppSpacing.spacing16_Box,
                                  Text(
                                    (widget.resource.title ?? ''),
                                    style: GoogleFonts.anton(
                                      color: AppColors.whiteSwatch,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w400,
                                      height: 64 / 48,
                                      letterSpacing: -0.02 * 48,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AppSpacing.spacing16_Box,
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // 3 minutes - Mardi 6 janvier 2026
                                      Text(
                                        (() {
                                          final locale = AppLocalizations.of(context);
                                          return '${_formatDurationFromSeconds(locale, widget.resource.estimatedDuration)} - ${DateFormat('EEEE d MMMM y', locale.localeName).format(widget.resource.createdAt ?? DateTime.now())}';
                                        })(),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: AppColors.whiteSwatch,
                                        ),
                                      ),
                                      const Spacer(),
                                      // like button
                                      AppXLikeButton(
                                        liked: _isLiked,
                                        onPressed: () {
                                          final resourceId = widget.resource.id ?? '';
                                          if (resourceId.isEmpty) return;
                                          final nextLiked = !_isLiked;
                                          setState(() {
                                            _isLiked = nextLiked;
                                          });
                                          context.read<ResourcesBloc>().add(
                                                LikeResource(
                                                  resourceId: resourceId,
                                                  like: nextLiked,
                                                ),
                                              );
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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

class _ArticleScrollableContent extends StatefulWidget {
  final TocController tocController;
  final String data;
  final Widget header;
  final MarkdownConfig? config;
  final MarkdownGenerator? markdownGenerator;

  const _ArticleScrollableContent({
    required this.tocController,
    required this.data,
    required this.header,
    this.config,
    this.markdownGenerator,
  });

  @override
  State<_ArticleScrollableContent> createState() => _ArticleScrollableContentState();
}

class _ArticleScrollableContentState extends State<_ArticleScrollableContent> {
  static const int _headerCount = 1;
  final AutoScrollController _controller = AutoScrollController();
  final SplayTreeSet<int> _indexTreeSet = SplayTreeSet<int>((a, b) => a - b);
  final List<Widget> _widgets = [];
  late MarkdownGenerator _markdownGenerator;
  bool _isForward = true;

  @override
  void initState() {
    super.initState();
    widget.tocController.jumpToIndexCallback = (index) {
      _controller.scrollToIndex(index + _headerCount, preferPosition: AutoScrollPosition.begin);
    };
    _updateState();
  }

  void _updateState() {
    _indexTreeSet.clear();
    _markdownGenerator = widget.markdownGenerator ?? MarkdownGenerator();
    final result = _markdownGenerator.buildWidgets(
      widget.data,
      onTocList: (tocList) {
        widget.tocController.setTocList(tocList);
      },
      config: widget.config,
    );
    _widgets.addAll(result);
  }

  void _clearState() {
    _indexTreeSet.clear();
    _widgets.clear();
  }

  @override
  void didUpdateWidget(covariant _ArticleScrollableContent oldWidget) {
    _clearState();
    _updateState();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _clearState();
    _controller.dispose();
    widget.tocController.jumpToIndexCallback = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listView = NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        _isForward = notification.direction == ScrollDirection.forward;
        return true;
      },
      child: ListView.builder(
        controller: _controller,
        itemCount: _widgets.length + _headerCount,
        itemBuilder: (ctx, index) {
          if (index == 0) {
            return widget.header;
          }
          final mdIndex = index - _headerCount;
          final child = _widgets[mdIndex];
          return wrapByAutoScroll(index, _wrapByVisibilityDetector(mdIndex, child), _controller);
        },
      ),
    );
    return SelectionArea(child: listView);
  }

  Widget _wrapByVisibilityDetector(int index, Widget child) {
    return VisibilityDetector(
      key: ValueKey('md-$index'),
      onVisibilityChanged: (info) {
        final visibleFraction = info.visibleFraction;
        if (_isForward) {
          visibleFraction == 0 ? _indexTreeSet.remove(index) : _indexTreeSet.add(index);
        } else {
          visibleFraction == 1.0 ? _indexTreeSet.add(index) : _indexTreeSet.remove(index);
        }
        if (_indexTreeSet.isNotEmpty) {
          widget.tocController.onIndexChanged(_indexTreeSet.first);
        }
      },
      child: child,
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
