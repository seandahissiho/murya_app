part of 'landing.dart';

class MobileLandingScreen extends StatefulWidget {
  const MobileLandingScreen({super.key});

  @override
  State<MobileLandingScreen> createState() => _MobileLandingScreenState();
}

class _MobileLandingScreenState extends State<MobileLandingScreen> {
  final GlobalKey _bodyWrapKey = GlobalKey();
  final GlobalKey _footerWrapKey = GlobalKey();
  double mainBodyHey = 0;
  double footerHey = 0;
  var safeAreaPadding = EdgeInsets.zero;
  int? _draggingIndex;
  static const Offset _dragFeedbackOffset = Offset(0, 0);
  final Map<String, GlobalKey> _tileKeys = {};

  final Set<int> concats = {};

  @override
  void initState() {
    context.read<JobBloc>().add(SearchJobs(query: "", context: context));
    super.initState();
    safeAreaPadding = context.read<AppBloc>().safeAreaPadding;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 10), () {
        if (!mounted || !context.mounted) return;
        calculus();
      });
    });
  }

  double get size_1H {
    final AppSize appSize = AppSize(context);
    final screenHeight = appSize.screenHeight;
    // remove all margins and paddings
    final availableHeight = screenHeight -
        safeAreaPadding.top -
        safeAreaPadding.bottom -
        (AppSpacing.pageMargin * 2) -
        27 -
        AppSpacing.sectionMargin;
    if (DeviceHelper.isMobile(context)) {
      return (availableHeight + AppSpacing.sectionMargin) / 4;
    } else {
      return math.max((availableHeight) / 2 - 90, 225);
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Column(
      children: [
        const CustomAppBar(),
        Expanded(
          child: BlocConsumer<ModulesBloc, ModulesState>(
            listener: (context, state) {
              setState(() {});
              Future.delayed(const Duration(seconds: 1), () {
                if (!mounted || !this.context.mounted) return;
                calculus();
              });
            },
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: LayoutBuilder(builder: (context, constraints) {
                  double mainBodyHeight = constraints.maxHeight -
                      AppSpacing.sectionMargin -
                      footerHey +
                      AppSpacing.pageMargin +
                      MediaQuery.of(context).padding.bottom;
                  if (mainBodyHey > 4 * size_1H) {
                    mainBodyHeight = 0;
                  }
                  return Stack(
                    children: [
                      CustomScrollView(
                        // reverse: true,
                        shrinkWrap: true,
                        primary: true, // ensures a ScrollPosition; prevents that null in hitTest
                        slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              // color: Colors.blue,
                              // height: mainBodyHeight,
                              constraints: BoxConstraints(
                                minHeight: mainBodyHeight,
                              ),
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Wrap(
                                    key: _bodyWrapKey,
                                    spacing: 0, // AppSpacing.groupMargin,
                                    runSpacing: 0, // AppSpacing.groupMargin,
                                    // spacing: AppSpacing.groupMargin,
                                    // runSpacing: AppSpacing.groupMargin,
                                    children: List.generate(state.modules.length, (i) {
                                      bool hasBeenContacted = concats.contains(i);
                                      if (hasBeenContacted) {
                                        return const SizedBox.shrink();
                                      }

                                      // final i = entry.value.index;
                                      final module = state.modules[i];
                                      final nextModule = i + 1 < state.modules.length ? state.modules[i + 1] : null;

                                      // Your actual tile widget
                                      bool concatRow = false;
                                      bool concatColumn = false;

                                      if (nextModule != null) {
                                        bool currentIsOneWide = module.boxType == AppModuleType.type1 ||
                                            module.boxType == AppModuleType.type2_1;
                                        bool nextIsOneWide = nextModule.boxType == AppModuleType.type1 ||
                                            nextModule.boxType == AppModuleType.type2_1;
                                        bool currentIsType1_2 = module.boxType == AppModuleType.type1_2;
                                        bool nextIsType1_2 = nextModule.boxType == AppModuleType.type1_2;

                                        if (currentIsOneWide && nextIsOneWide) {
                                          concatRow = true;
                                        } else if (currentIsType1_2 && nextIsType1_2) {
                                          concatColumn = true;
                                        }
                                      }

                                      if (concatRow || concatColumn) {
                                        concats.add(i + 1);
                                      }
                                      bool isFirstOfRow = i == 0 ||
                                          (i > 0 && concats.contains(i - 1)) ||
                                          (i > 1 && concats.contains(i - 2));
                                      double left = isFirstOfRow ? 0 : AppSpacing.elementMargin / 2;

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: left,
                                          right: AppSpacing.elementMargin / 2,
                                        ),
                                        child: SingleChildScrollView(
                                          physics: const NeverScrollableScrollPhysics(),
                                          child: Column(
                                            children: [
                                              if (concatRow)
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      _test(module, i),
                                                      AppSpacing.elementMarginBox,
                                                      _test(nextModule!, i + 1),
                                                    ],
                                                  ),
                                                )
                                              else
                                                _test(module, i),
                                              AppSpacing.elementMarginBox,
                                              if (concatColumn) ...[
                                                _test(nextModule!, i + 1),
                                                AppSpacing.elementMarginBox,
                                              ],
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: AppSpacing.sectionMarginBox,
                          ),
                          SliverToBoxAdapter(
                            child: AppFooter(key: _footerWrapKey, isLanding: true),
                          ),
                        ],
                      ),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: AddModuleButton(),
                      )
                    ],
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  void calculus() {
    final context = _bodyWrapKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      mainBodyHey = box.size.height;
      setState(() {});
    }
    final footerContext = _footerWrapKey.currentContext;
    if (footerContext != null) {
      final box = footerContext.findRenderObject() as RenderBox;
      footerHey = box.size.height;
      setState(() {});
    }
    setState(() {});
  }

  Widget _test(Module module, int i) {
    final tileKey = _tileKeys.putIfAbsent(module.id!, () => GlobalKey());
    final feedbackTile = _getTileForModule(
      module,
      dragHandle: const AppModuleDragHandle(),
    );
    final dragHandle = LongPressDraggable<int>(
      data: i,
      dragAnchorStrategy: (draggable, context, position) {
        final renderBox = tileKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) {
          return childDragAnchorStrategy(draggable, context, position) + _dragFeedbackOffset;
        }
        final tileOrigin = renderBox.localToGlobal(Offset.zero);
        final localPosition = position - tileOrigin;
        return localPosition + _dragFeedbackOffset;
      },
      onDragStarted: () => setState(() => _draggingIndex = i),
      onDragCompleted: () => setState(() => _draggingIndex = null),
      onDragEnd: (_) => setState(() => _draggingIndex = null),
      onDraggableCanceled: (_, __) => setState(() => _draggingIndex = null),
      feedback: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Opacity(opacity: 0.9, child: feedbackTile),
        ),
      ),
      childWhenDragging: const Opacity(opacity: 0.25, child: AppModuleDragHandle()),
      child: const AppModuleDragHandle(),
    );
    final tile = _getTileForModule(
      module,
      dragHandle: dragHandle,
      tileKey: tileKey,
    );
    return DragTarget<int>(
      // We drag by passing the source index as "data"
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (fromIndex) {
        if (fromIndex.data != i) {
          context.read<ModulesBloc>().add(ReorderModules(from: fromIndex.data, to: i));
        }
        setState(() => _draggingIndex = null);
      },
      builder: (context, candidate, rejected) {
        // Optional hover/highlight effect while dragging over this slot
        final isActive = candidate.isNotEmpty;
        final decorated = AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          foregroundDecoration: isActive
              ? BoxDecoration(
                  border: Border.all(width: 2, color: AppColors.borderDark),
                  borderRadius: AppRadius.borderRadius20,
                )
              : null,
          child: tile,
        );

        if (_draggingIndex == i) {
          return Opacity(opacity: 0.25, child: decorated);
        }
        return decorated;
      },
    );
  }

  _getTileForModule(Module module, {Widget? dragHandle, GlobalKey? tileKey}) {
    const cardMargin = EdgeInsets.zero;
    switch (module.id) {
      case 'leaderboard':
        return AccountModuleWidget(
          // key: ValueKey('module-${module.id}'),
          module: module,
          onSizeChanged: onSizeChanged,
          dragHandle: dragHandle,
          tileKey: tileKey,
          cardMargin: cardMargin,
        );
      case 'daily-quiz':
        return JobModuleWidget(
          key: ValueKey('module-${module.id}'),
          module: module,
          onSizeChanged: onSizeChanged,
          dragHandle: dragHandle,
          tileKey: tileKey,
          cardMargin: cardMargin,
        );
      case 'learning-resources':
        return RessourcesModuleWidget(
          // key: ValueKey('module-${module.id}'),
          module: module,
          onSizeChanged: onSizeChanged,
          dragHandle: dragHandle,
          tileKey: tileKey,
          cardMargin: cardMargin,
        );
      default:
        return AppModuleWidget(
          key: ValueKey('module-${module.id}'),
          module: module,
          onSizeChanged: onSizeChanged,
          dragHandle: dragHandle,
          tileKey: tileKey,
          cardMargin: cardMargin,
        );
    }
  }

  void onSizeChanged() {
    concats.clear();
  }
}
