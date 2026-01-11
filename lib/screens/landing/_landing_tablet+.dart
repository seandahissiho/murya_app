part of 'landing.dart';

class TabletLandingScreen extends StatefulWidget {
  const TabletLandingScreen({super.key});

  @override
  State<TabletLandingScreen> createState() => _TabletLandingScreenState();
}

class _TabletLandingScreenState extends State<TabletLandingScreen> {
  final GlobalKey _bodyWrapKey = GlobalKey();
  final GlobalKey _footerWrapKey = GlobalKey();
  double mainBodyHey = 0;
  double footerHey = 0;
  var safeAreaPadding = EdgeInsets.zero;
  int? _draggingIndex;

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
        AppSpacing.pageMargin;
    if (DeviceHelper.isMobile(context)) {
      return (availableHeight + AppSpacing.pageMargin) / 4;
    } else {
      // return ((availableHeight - AppSpacing.groupMargin) / 2) / 1.618;
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
                      AppSpacing.pageMargin -
                      footerHey +
                      AppSpacing.pageMargin +
                      MediaQuery.of(context).padding.bottom;

                  if (mainBodyHey > 2 * size_1H) {
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
                                    children: List.generate(state.modules.length, (i) {
                                      bool hasBeenContacted = concats.contains(i);
                                      if (hasBeenContacted) {
                                        return const SizedBox.shrink();
                                      }

                                      // final i = entry.value.index;
                                      final module = state.modules[i];
                                      final nextModule = i + 1 < state.modules.length ? state.modules[i + 1] : null;
                                      final nextNextModule = i + 2 < state.modules.length ? state.modules[i + 2] : null;

                                      // Your actual tile widget
                                      bool concat2 = false;
                                      bool concat3 = false;

                                      if (nextModule != null) {
                                        if ((module.boxType == AppModuleType.type1 &&
                                            nextModule.boxType == AppModuleType.type1)) {
                                          concat2 = true;
                                        }
                                        bool currentIsType1_2 = module.boxType == AppModuleType.type1_2;
                                        bool nextIsType1_2 = nextModule.boxType == AppModuleType.type1_2;
                                        if (currentIsType1_2 && nextIsType1_2) {
                                          concat2 = true;
                                        }
                                      }
                                      if (nextModule != null && nextNextModule != null) {
                                        bool currentIsType1_2 = module.boxType == AppModuleType.type1_2;
                                        bool nextIsType1 = nextModule.boxType == AppModuleType.type1;
                                        bool nextNextIsType1 = nextNextModule.boxType == AppModuleType.type1;

                                        if (currentIsType1_2 && nextIsType1 && nextNextIsType1) {
                                          concat3 = true;
                                          concat2 = false;
                                        }
                                      }

                                      if (concat2 && !concat3) {
                                        concats.add(i + 1);
                                      }
                                      if (concat3) {
                                        concats.add(i + 1);
                                        concats.add(i + 2);
                                      }
                                      bool isFirstOfRow = i == 0 ||
                                          (i > 0 && concats.contains(i - 1)) ||
                                          (i > 1 && concats.contains(i - 2));
                                      double left = isFirstOfRow ? AppSpacing.pageMargin : AppSpacing.groupMargin / 2;
                                      double right = AppSpacing.groupMargin / 2;
                                      if (i == state.modules.length - 1) {
                                        right = AppSpacing.pageMargin;
                                      }

                                      log('Building module at index $i, concat: $concat2');
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: left,
                                          right: AppSpacing.groupMargin,
                                        ),
                                        child: Column(
                                          children: [
                                            _test(module, i),
                                            AppSpacing.groupMarginBox,
                                            if (concat2) ...[
                                              _test(nextModule!, i + 1),
                                              AppSpacing.groupMarginBox,
                                            ],
                                            if (concat3) ...[
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  _test(nextModule!, i + 1),
                                                  AppSpacing.groupMarginBox,
                                                  _test(nextNextModule!, i + 2),
                                                ],
                                              ),
                                              AppSpacing.groupMarginBox,
                                            ],
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: AppSpacing.containerInsideMarginSmallBox,
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
      debugPrint('Wrap height: $mainBodyHey');
      setState(() {});
    }
    final footerContext = _footerWrapKey.currentContext;
    if (footerContext != null) {
      final box = footerContext.findRenderObject() as RenderBox;
      footerHey = box.size.height;
      debugPrint('Footer height: $footerHey');
      setState(() {});
    }
    setState(() {});
  }

  Widget _test(Module module, int i) {
    final feedbackTile = _getTileForModule(
      module,
      dragHandle: const AppModuleDragHandle(),
    );
    final dragHandle = LongPressDraggable<int>(
      data: i,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => setState(() => _draggingIndex = i),
      onDragCompleted: () => setState(() => _draggingIndex = null),
      onDragEnd: (_) => setState(() => _draggingIndex = null),
      onDraggableCanceled: (_, __) => setState(() => _draggingIndex = null),
      feedback: Material(
        elevation: 3,
        borderRadius: AppRadius.large,
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1880),
          child: Opacity(opacity: 0.9, child: feedbackTile),
        ),
      ),
      childWhenDragging: const Opacity(opacity: 0.25, child: AppModuleDragHandle()),
      child: const AppModuleDragHandle(),
    );
    final tile = _getTileForModule(module, dragHandle: dragHandle);
    return DragTarget<int>(
      // We drag by passing the source index as "data"
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (fromIndex) {
        if (i <= 2) return;
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
                  border: Border.all(width: 2, color: AppColors.borderMedium),
                  borderRadius: AppRadius.large,
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

  _getTileForModule(Module module, {Widget? dragHandle}) {
    switch (module.id) {
      case 'account':
        return AccountModuleWidget(
          module: module,
          onSizeChanged: onSizeChanged,
          dragHandle: dragHandle,
        );
      case 'job':
        return JobModuleWidget(
          module: module,
          onSizeChanged: onSizeChanged,
          dragHandle: dragHandle,
        );
      case 'ressources':
        return RessourcesModuleWidget(
          module: module,
          onSizeChanged: onSizeChanged,
          dragHandle: dragHandle,
        );
      default:
        return AppModuleWidget(
          key: ValueKey('module-${module.id}'),
          module: module,
          onSizeChanged: onSizeChanged,
          dragHandle: dragHandle,
        );
    }
  }

  void onSizeChanged() {
    concats.clear();
  }
}

extension on SizedBox {
  SizedBox operator *(int other) {
    return SizedBox(
      width: width != null ? width! * other : null,
      height: height != null ? height! * other : null,
    );
  }
}
