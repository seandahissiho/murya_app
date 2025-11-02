part of 'job_details.dart';

class MobileJobDetailsScreen extends StatefulWidget {
  const MobileJobDetailsScreen({super.key});

  @override
  State<MobileJobDetailsScreen> createState() => _MobileJobDetailsScreenState();
}

class _MobileJobDetailsScreenState extends State<MobileJobDetailsScreen> {
  Job _job = Job.empty();
  int _detailsLevel = 0;

  var options = ["Junior", "Intermédiaire", "Senior", "Expert"];

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
    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        if (state is JobDetailsLoaded) {
          _job = state.job;
          final families = _job.competenciesFamilies;
        }
        setState(() {});
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (Beamer.of(context).canBeamBack) {
                      context.beamBack();
                    } else {
                      navigateToPath(context, to: AppRoutes.searchModule);
                    }
                  },
                  child: SvgPicture.asset(
                    AppIcons.backButtonPath,
                    width: 32,
                    height: 32,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (Beamer.of(context).canBeamBack) {
                      context.beamBack();
                    }
                    navigateToPath(context, to: AppRoutes.landing);
                  },
                  child: SvgPicture.asset(
                    AppIcons.searchBarCloseIconPath,
                    width: 32,
                    height: 32,
                  ),
                ),
              ],
            ),
            AppSpacing.groupMarginBox,
            Text(
              _job.title,
              style: GoogleFonts.anton(
                color: AppColors.textPrimary,
                fontSize: theme.textTheme.displayLarge?.fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.containerInsideMarginBox,
            AppXButton(
              onPressed: () {},
              isLoading: false,
              text: "Évaluer les compétences",
              autoResize: false,
            ),
            AppSpacing.containerInsideMarginBox,
            Expanded(
              child: SingleChildScrollView(
                child: LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpandableText(
                        // _job.description,
                        FAKER.lorem.sentences(10).join(' '),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryDefault,
                          overflow: TextOverflow.ellipsis,
                        ),
                        linkStyle: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primaryDefault,
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 4,
                        expandText: '\n\nAfficher plus',
                        collapseText: '\n\nVoir moins',
                        linkEllipsis: false,
                      ),
                      AppSpacing.containerInsideMarginBox,
                      Container(
                        height: constraints.maxWidth,
                        width: constraints.maxWidth,
                        color: AppColors.backgroundColor,
                        child: RoundedRadarChart(
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
                        children: [
                          Expanded(
                            flex: 100,
                            child: Text(
                              "Diagramme des compétences",
                              style: theme.textTheme.bodyMedium!
                                  .copyWith(color: AppColors.blackSwatch, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
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
                      AppSpacing.sectionMarginBox,
                      ...familiesBuilder(),
                      AppSpacing.sectionMarginBox,
                      const AppFooter(),
                    ],
                  );
                }),
              ),
            ),
          ],
        );
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
