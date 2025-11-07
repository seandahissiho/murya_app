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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 10), () {
        if (!mounted || !context.mounted) return;
        calculus();
      });
    });
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
              Future.delayed(const Duration(microseconds: 1), () {
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
                  if (mainBodyHey > constraints.maxHeight / 2) {
                    mainBodyHeight = constraints.maxHeight;
                  }
                  log('MaxHeight: ${constraints.maxHeight}, mainBodyHey: $mainBodyHey, footerHey: $footerHey');
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
                                    spacing: AppSpacing.groupMargin,
                                    runSpacing: AppSpacing.groupMargin,
                                    children: state.modules.asMap().entries.map((entry) {
                                      final i = entry.value.index;
                                      final module = entry.value;

                                      // Your actual tile widget
                                      final tile = ModuleBuilder(context).getBy(module);

                                      return DragTarget<int>(
                                        // We drag by passing the source index as "data"
                                        onWillAcceptWithDetails: (_) => true,
                                        onAcceptWithDetails: (fromIndex) {
                                          if (i <= 2) return;
                                          if (fromIndex.data != i) {
                                            context
                                                .read<ModulesBloc>()
                                                .add(ReorderModules(from: fromIndex.data, to: i));
                                          }
                                        },
                                        builder: (context, candidate, rejected) {
                                          // Optional hover/highlight effect while dragging over this slot
                                          final isActive = candidate.isNotEmpty;
                                          final decorated = AnimatedContainer(
                                            duration: const Duration(milliseconds: 120),
                                            foregroundDecoration: isActive
                                                ? BoxDecoration(
                                                    border: Border.all(width: 2),
                                                    borderRadius: AppRadius.borderRadius20,
                                                  )
                                                : null,
                                            child: tile,
                                          );

                                          // Make the tile draggable on long-press
                                          return LongPressDraggable<int>(
                                            data: i,
                                            // <— we carry the index of this module
                                            dragAnchorStrategy: pointerDragAnchorStrategy,
                                            // smoother grab
                                            feedback: Material(
                                              elevation: 8,
                                              borderRadius: BorderRadius.circular(12),
                                              clipBehavior: Clip.antiAlias,
                                              child: ConstrainedBox(
                                                // Give the feedback a reasonable size; it doesn’t have to be perfect
                                                constraints: const BoxConstraints(maxWidth: 320),
                                                child: Opacity(opacity: 0.9, child: tile),
                                              ),
                                            ),
                                            // Keep tap working: Long-press starts drag; normal tap still hits child
                                            childWhenDragging: Opacity(opacity: 0.25, child: tile),
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                onTap: () {
                                                  context.read<ModulesBloc>().add(UpdateModule(
                                                        module: Module(
                                                          id: module.id,
                                                          index: module.index,
                                                          boxType: module.nextBoxType(),
                                                        ),
                                                      ));

                                                  // Future.delayed(const Duration(milliseconds: 300), () {
                                                  // });
                                                },
                                                child: decorated,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: AppSpacing.sectionMarginBox,
                          ),
                          SliverToBoxAdapter(
                            child: AppFooter(key: _footerWrapKey),
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
}

extension on SizedBox {
  SizedBox operator *(int other) {
    return SizedBox(
      width: width != null ? width! * other : null,
      height: height != null ? height! * other : null,
    );
  }
}
