part of 'landing.dart';

class MobileLandingScreen extends StatefulWidget {
  const MobileLandingScreen({super.key});

  @override
  State<MobileLandingScreen> createState() => _MobileLandingScreenState();
}

class _MobileLandingScreenState extends State<MobileLandingScreen> {
  final GlobalKey _wrapKey = GlobalKey();
  double mainBodyHey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setMainBodyHey();
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
              setMainBodyHey();
              setState(() {});
            },
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: LayoutBuilder(builder: (context, constraints) {
                  return Stack(
                    children: [
                      CustomScrollView(
                        primary: true, // ensures a ScrollPosition; prevents that null in hitTest
                        slivers: [
                          SliverToBoxAdapter(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: StaggeredGrid.count(
                                key: _wrapKey,
                                crossAxisCount: 2,
                                mainAxisSpacing: AppSpacing.groupMargin,
                                crossAxisSpacing: AppSpacing.groupMargin,
                                children: state.modules.asMap().entries.map((entry) {
                                  final i = entry.value.index;
                                  final module = entry.value;

                                  // Your actual tile widget
                                  final tile = ModuleBuilder(context).getBy(module);

                                  return StaggeredGridTile.count(
                                    crossAxisCellCount: module.boxType.crossAxisCellCount,
                                    mainAxisCellCount: module.boxType.mainAxisCellCount / 1.05,
                                    child: DragTarget<int>(
                                      // We drag by passing the source index as "data"
                                      onWillAcceptWithDetails: (_) => true,
                                      onAcceptWithDetails: (fromIndex) {
                                        if (i <= 2) return;
                                        if (fromIndex.data != i) {
                                          context.read<ModulesBloc>().add(ReorderModules(from: fromIndex.data, to: i));
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
                                          child: GestureDetector(
                                            onTap: () {
                                              context.read<ModulesBloc>().add(UpdateModule(
                                                    module: Module(
                                                      id: module.id,
                                                      index: module.index,
                                                      boxType: module.nextBoxType(),
                                                    ),
                                                  ));
                                            },
                                            child: decorated,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: constraints.maxHeight - mainBodyHey < 0 ? 0 : constraints.maxHeight - mainBodyHey,
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: AppSpacing.sectionMarginBox,
                          ),
                          const SliverToBoxAdapter(
                            child: AppFooter(),
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

  void setMainBodyHey() {
    setState(() {});
    final context = _wrapKey.currentContext;
    if (context != null) {
      final box = context.findRenderObject() as RenderBox;
      mainBodyHey = box.size.height;
      debugPrint('Wrap height: $mainBodyHey');
      setState(() {});
    }
  }
}
