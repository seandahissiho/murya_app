part of 'competencies_family_details.dart';

class TabletCfDetailsScreen extends StatefulWidget {
  const TabletCfDetailsScreen({super.key});

  @override
  State<TabletCfDetailsScreen> createState() => _TabletCfDetailsScreenState();
}

class _TabletCfDetailsScreenState extends State<TabletCfDetailsScreen> {
  CompetencyFamily _cf = CompetencyFamily.empty();
  AppJob _job = Job.empty();
  String jobId = '';
  late final cfId;
  final ScrollController _competenciesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      jobId = beamState.pathParameters['jobId'];
      cfId = beamState.pathParameters['cfId'];
      final userJobId = context.read<JobBloc>().state.userCurrentJob?.id;
      context.read<JobBloc>().add(LoadCFDetails(context: context, jobId: jobId, cfId: cfId, userJobId: userJobId));
    });
  }

  @override
  void dispose() {
    _competenciesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        if (state is CFDetailsLoaded) {
          _cf = state.cfamily;
          _job = state.job;
        }
        setState(() {});
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AppXReturnButton(
                        destination: AppRoutes.jobDetails.replaceFirst(':id', jobId),
                        data: {'jobTitle': _job.title},
                      ),
                      AppSpacing.spacing16_Box,
                      AppBreadcrumb(
                        items: [
                          BreadcrumbItem(
                            label: _job.title,
                            onTap: () => navigateToPath(
                              context,
                              to: AppRoutes.jobDetails.replaceFirst(':id', jobId),
                              data: {'jobTitle': _job.title},
                            ),
                          ),
                          BreadcrumbItem(label: _cf.name),
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
                    ],
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
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: AppColors.borderLight,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset(
                                getIconForFamily(_cf),
                                height: tabletAndAboveCTAHeight - 15,
                                width: tabletAndAboveCTAHeight - 15,
                                colorFilter: const ColorFilter.mode(AppColors.primaryDefault, BlendMode.srcIn),
                              ),
                            ),
                            AppSpacing.spacing8_Box,
                            RichText(
                              text: TextSpan(
                                text: _cf.name,
                                style: GoogleFonts.anton(
                                  color: AppColors.textPrimary,
                                  fontSize: theme.textTheme.headlineLarge?.fontSize,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  // WidgetSpan(
                                  //   alignment: PlaceholderAlignment.middle, // aligns icon vertically
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.only(left: AppSpacing.groupMargin),
                                  //     child: GestureDetector(
                                  //       onTap: () async {
                                  //         return await contentNotAvailablePopup(context);
                                  //         await ShareUtils.shareContent(
                                  //           text: locale.discover_cf_profile(_cf.name),
                                  //           url: ShareUtils.generateJobDetailsLink(_cf.id!),
                                  //           subject: locale.job_profile_page_title(_cf.name),
                                  //         );
                                  //         if (kIsWeb && mounted && context.mounted) {
                                  //           // On web, there's a good chance we just copied to clipboard
                                  //           ScaffoldMessenger.of(context).showSnackBar(
                                  //             SnackBar(content: Text(locale.link_copied)),
                                  //           );
                                  //         }
                                  //       },
                                  //       child: const Icon(
                                  //         Icons.ios_share,
                                  //         size: tabletAndAboveCTAHeight / 1.618,
                                  //         color: AppColors.primaryDefault,
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.spacing24_Box,
                        Expanded(
                          child: MarkdownWidget(
                            data: _cf.description ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.spacing16_Box,
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: const BoxDecoration(
                        // color: AppColors.backgroundCard,
                        borderRadius: AppRadius.borderRadius20,
                      ),
                      padding: const EdgeInsets.only(
                        top: AppSpacing.spacing16,
                        left: AppSpacing.spacing16,
                        bottom: AppSpacing.spacing16,
                      ),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          scrollbars: true,
                        ),
                        child: Scrollbar(
                          controller: _competenciesScrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _competenciesScrollController,
                            child: Column(
                              children: _cf.competencies.map((competency) {
                                bool isLast = _cf.competencies.indexOf(competency) == _cf.competencies.length - 1;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.spacing16),
                                  child: CompetencyCard(competency: competency),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // AppSpacing.sectionMarginBox,
            const AppFooter(),
          ],
        );
      },
    );
  }
}
