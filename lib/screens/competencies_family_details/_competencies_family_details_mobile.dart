part of 'competencies_family_details.dart';

class MobileCfDetailsScreen extends StatefulWidget {
  const MobileCfDetailsScreen({super.key});

  @override
  State<MobileCfDetailsScreen> createState() => _MobileCfDetailsScreenState();
}

class _MobileCfDetailsScreenState extends State<MobileCfDetailsScreen> {
  CompetencyFamily _cf = CompetencyFamily.empty();
  AppJob _job = Job.empty();
  late final jobId;
  late final cfId;

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
        return AppSkeletonizer(
          enabled: _cf.id.isEmptyOrNull,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        AppXReturnButton(destination: AppRoutes.jobDetails.replaceFirst(':id', jobId)),
                        AppSpacing.elementMarginBox,
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: () {
                                    navigateToPath(context, to: AppRoutes.jobDetails.replaceFirst(':id', jobId));
                                  },
                                  child: Text(
                                    _job.title,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Text(
                                ' → ',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.primaryDefault,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  _cf.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primaryDefault,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const AppXCloseButton(),
                ],
              ),
              AppSpacing.groupMarginBox,
              Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.borderLight,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      AppIcons.employeeSearchLoupePath,
                      height: mobileCTAHeight - 15,
                      width: mobileCTAHeight - 15,
                      colorFilter: const ColorFilter.mode(AppColors.primaryDefault, BlendMode.srcIn),
                    ),
                  ),
                  AppSpacing.elementMarginBox,
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        text: _cf.name,
                        style: GoogleFonts.anton(
                          color: AppColors.textPrimary,
                          fontSize: theme.textTheme.headlineMedium?.fontSize,
                          fontWeight: FontWeight.w700,
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
                          //         size: mobileCTAHeight / 1.618,
                          //         color: AppColors.primaryDefault,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              AppSpacing.containerInsideMarginBox,
              Expanded(
                child: SingleChildScrollView(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_cf.description != null && _cf.description!.isNotEmpty) ...[
                          ExpandableText(
                            _cf.description ?? '',
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
                        ],
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: AppRadius.borderRadius20,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.groupMargin),
                          child: Column(
                            children: _cf.competencies.map((competency) {
                              bool isLast = _cf.competencies.indexOf(competency) == _cf.competencies.length - 1;
                              return Padding(
                                padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.groupMargin),
                                child: CompetencyCard(competency: competency),
                              );
                            }).toList(),
                          ),
                        ),
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
}

extension on SizedBox {
  dynamic operator *(num other) {
    return SizedBox(
      width: width != null ? width! * other : null,
      height: height != null ? height! * other : null,
    );
  }
}
