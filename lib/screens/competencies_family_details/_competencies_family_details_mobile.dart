part of 'competencies_family_details.dart';

class MobileCfDetailsScreen extends StatefulWidget {
  const MobileCfDetailsScreen({super.key});

  @override
  State<MobileCfDetailsScreen> createState() => _MobileCfDetailsScreenState();
}

class _MobileCfDetailsScreenState extends State<MobileCfDetailsScreen> {
  CompetencyFamily _cf = CompetencyFamily.empty();
  Job _job = Job.empty();
  late final jobId;
  late final cfId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      jobId = beamState.pathParameters['jobId'];
      cfId = beamState.pathParameters['cfId'];
      context.read<JobBloc>().add(LoadCFDetails(context: context, jobId: jobId, cfId: cfId));
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          navigateToPath(context, to: AppRoutes.jobDetails.replaceFirst(':id', jobId));
                        },
                        child: SvgPicture.asset(
                          AppIcons.backButtonPath,
                          width: 32,
                          height: 32,
                        ),
                      ),
                      AppSpacing.elementMarginBox,
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _job.title,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              ' → ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryDefault,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _cf.name,
                                style: theme.textTheme.bodySmall?.copyWith(
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
                GestureDetector(
                  onTap: () {
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
                    height: 28,
                    width: 28,
                    colorFilter: const ColorFilter.mode(AppColors.primaryDefault, BlendMode.srcIn),
                  ),
                ),
                AppSpacing.elementMarginBox,
                RichText(
                  text: TextSpan(
                    text: _cf.name,
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
                                text: locale.discover_cf_profile(_cf.name),
                                url: ShareUtils.generateJobDetailsLink(_cf.id),
                                subject: locale.job_profile_page_title(_cf.name),
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
