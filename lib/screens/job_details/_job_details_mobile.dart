part of 'job_details.dart';

class MobileJobDetailsScreen extends StatefulWidget {
  const MobileJobDetailsScreen({super.key});

  @override
  State<MobileJobDetailsScreen> createState() => _MobileJobDetailsScreenState();
}

class _MobileJobDetailsScreenState extends State<MobileJobDetailsScreen> {
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
        }
        setState(() {});
      },
      builder: (context, state) {
        return AppSkeletonizer(
          enabled: _job.id.isEmpty,
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
                      width: mobileCTAHeight,
                      height: mobileCTAHeight,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      navigateToPath(context, to: AppRoutes.landing);
                    },
                    child: SvgPicture.asset(
                      AppIcons.searchBarCloseIconPath,
                      width: mobileCTAHeight,
                      height: mobileCTAHeight,
                    ),
                  ),
                ],
              ),
              AppSpacing.groupMarginBox,
              RichText(
                text: TextSpan(
                  text: _job.title,
                  style: GoogleFonts.anton(
                    color: AppColors.textPrimary,
                    fontSize: theme.textTheme.headlineMedium?.fontSize,
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
                          child: const Icon(
                            Icons.ios_share,
                            size: mobileCTAHeight / 1.618,
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
                onPressed: () {
                  navigateToPath(context, to: AppRoutes.jobEvaluation.replaceAll(':id', _job.id));
                },
                isLoading: false,
                text: locale.evaluateSkills,
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
                          _job.description,
                          // FAKER.lorem.sentences(10).join(' '),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryDefault,
                            overflow: TextOverflow.ellipsis,
                          ),
                          linkStyle: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.primaryDefault,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 4,
                          expandText: '\n\n${locale.show_more}',
                          collapseText: '\n\n${locale.show_less}',
                          linkEllipsis: false,
                        ),
                        AppSpacing.containerInsideMarginBox,
                        Card(
                          elevation: 0,
                          color: AppColors.backgroundCard,
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.large,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              Padding(
                                padding: const EdgeInsets.only(left: AppSpacing.containerInsideMargin),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      locale.skillsDiagramTitle,
                                      style: theme.textTheme.labelLarge!.copyWith(
                                        color: AppColors.primaryDefault,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                      foregroundColor: AppColors.primaryDefault,
                                    ),
                                  ],
                                ),
                              ),
                              AppSpacing.containerInsideMarginBox,
                            ],
                          ),
                        ),
                        AppSpacing.containerInsideMarginBox,
                        ...familiesBuilder(),
                        AppSpacing.sectionMarginBox,
                        const AppFooter(),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
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

class AppSkeletonizer extends StatefulWidget {
  final bool enabled;
  final Widget child;
  const AppSkeletonizer({super.key, required this.enabled, required this.child});

  @override
  State<AppSkeletonizer> createState() => _AppSkeletonizerState();
}

class _AppSkeletonizerState extends State<AppSkeletonizer> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enableSwitchAnimation: true,
      enabled: widget.enabled,
      ignorePointers: false,
      ignoreContainers: false,
      containersColor: AppColors.secondaryPressed,
      effect: const ShimmerEffect(
        baseColor: AppColors.secondaryPressed,
        highlightColor: AppColors.secondaryFocus,
      ),
      child: widget.child,
    );
  }
}
