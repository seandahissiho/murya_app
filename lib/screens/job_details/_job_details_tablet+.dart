part of 'job_details.dart';

class TabletJobDetailsScreen extends StatefulWidget {
  const TabletJobDetailsScreen({super.key});

  @override
  State<TabletJobDetailsScreen> createState() => _TabletJobDetailsScreenState();
}

class _TabletJobDetailsScreenState extends State<TabletJobDetailsScreen> {
  Job _job = Job.empty();
  int _detailsLevel = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      final jobId = beamState.pathParameters['id'];
      context.read<JobBloc>().add(LoadJobDetails(context: context, jobId: jobId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    var options = [locale.skillLevel_easy, locale.skillLevel_medium, locale.skillLevel_hard, locale.skillLevel_expert];
    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobDetailsLoaded) {
          _job = state.job;
          final families = _job.competenciesFamilies;
        }
        setState(() {});
      },
      builder: (context, state) {
        return LayoutBuilder(builder: (context, bigConstraints) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: bigConstraints.maxHeight > 780
                      ? bigConstraints.maxHeight - 174 - AppSpacing.sectionMargin
                      : bigConstraints.maxHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              navigateToPath(context, to: AppRoutes.searchModule);
                            },
                            child: SvgPicture.asset(
                              AppIcons.backButtonPath,
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              navigateToPath(context, to: AppRoutes.landing);
                            },
                            child: SvgPicture.asset(
                              AppIcons.searchBarCloseIconPath,
                              width: 40,
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.sectionMarginBox,
                      AppSpacing.groupMarginBox,
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: _job.title,
                                      style: GoogleFonts.anton(
                                        color: AppColors.textPrimary,
                                        fontSize: theme.textTheme.displayLarge?.fontSize,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [
                                        WidgetSpan(
                                          alignment: PlaceholderAlignment.middle, // aligns icon vertically
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: AppSpacing.groupMargin),
                                            child: GestureDetector(
                                              onTap: () async {
                                                await ShareUtils.shareContent(
                                                  text: locale.discover_job_profile(_job.title),
                                                  url: ShareUtils.generateJobDetailsLink(_job.id),
                                                  subject: locale.job_profile_page_title(_job.title),
                                                );
                                                if (kIsWeb && mounted && context.mounted) {
                                                  // On web, there's a good chance we just copied to clipboard
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text(locale.link_copied)),
                                                  );
                                                }
                                              },
                                              child: Icon(
                                                Icons.ios_share,
                                                size: theme.textTheme.displayLarge!.fontSize! / 1.75,
                                                color: AppColors.primaryDefault,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppSpacing.containerInsideMarginBox,
                                  AppXButton(
                                    onPressed: () {},
                                    isLoading: false,
                                    text: locale.evaluateSkills,
                                    autoResize: false,
                                  ),
                                  AppSpacing.containerInsideMarginBox,
                                  Flexible(
                                    child: SingleChildScrollView(
                                      child: ExpandableText(
                                        _job.description,
                                        // FAKER.lorem.sentences(30).join(' '),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: AppColors.primaryDefault,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        linkStyle: theme.textTheme.labelMedium?.copyWith(
                                          color: AppColors.primaryDefault,
                                          decoration: TextDecoration.underline,
                                        ),
                                        maxLines: 100,
                                        expandText: '\n\n${locale.show_more}',
                                        collapseText: '\n\n${locale.show_less}',
                                        linkEllipsis: false,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppSpacing.groupMarginBox,
                            Flexible(
                              child: SingleChildScrollView(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.backgroundCard,
                                    borderRadius: AppRadius.large,
                                  ),
                                  padding: const EdgeInsets.only(
                                    top: AppSpacing.sectionMargin,
                                    left: AppSpacing.elementMargin,
                                    right: AppSpacing.elementMargin,
                                    bottom: AppSpacing.groupMargin,
                                  ),
                                  child: LayoutBuilder(builder: (context, constraints) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // AppSpacing.sectionMarginBox,
                                        // AppSpacing.sectionMarginBox,
                                        // AppSpacing.sectionMarginBox,
                                        SizedBox(
                                          height: constraints.maxWidth,
                                          width: constraints.maxWidth,
                                          child: InteractiveRoundedRadarChart(
                                            labels: _job.competenciesFamilies
                                                .whereOrEmpty((cf) => cf.parent == null)
                                                .map((cf) => cf.name)
                                                .toList(),
                                            values: _job.competenciesFamilies
                                                .whereOrEmpty((cf) => cf.parent == null)
                                                .map((cf) => cf.averageScoreByLevel(level: _detailsLevel))
                                                .toList(),
                                          ),
                                        ),
                                        AppSpacing.groupMarginBox,
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          // spacing: AppSpacing.elementMargin,
                                          // runSpacing: AppSpacing.groupMargin,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                locale.skillsDiagramTitle,
                                                style: theme.textTheme.bodyMedium!.copyWith(
                                                    color: AppColors.blackSwatch, fontWeight: FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            AppSpacing.groupMarginBox,
                                            AppXDropdown<int>(
                                              controller: TextEditingController(text: options[_detailsLevel]),
                                              items: options.map((level) => DropdownMenuEntry(
                                                    value: options.indexOf(level),
                                                    label: level,
                                                  )),
                                              onSelected: (level) {
                                                setState(() {
                                                  _detailsLevel = level!;
                                                });
                                              },
                                              labelInside: null,
                                              autoResize: true,
                                              foregroundColor: AppColors.blackSwatch,
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                            AppSpacing.groupMarginBox,
                            Flexible(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...familiesBuilder(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.sectionMarginBox,
                const AppFooter(),
              ],
            ),
          );
        });
      },
    );
  }

  List<Widget> familiesBuilder() {
    final List<Widget> widgets = [];
    for (final family in _job.competenciesFamilies.whereOrEmpty((cf) => cf.parent == null)) {
      widgets.add(CFCard(job: _job, family: family));
      widgets.add(AppSpacing.groupMarginBox);
    }
    return widgets;
  }
}
