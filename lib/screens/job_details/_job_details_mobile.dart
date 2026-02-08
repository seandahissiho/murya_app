part of 'job_details.dart';

class MobileJobDetailsScreen extends StatefulWidget {
  const MobileJobDetailsScreen({super.key});

  @override
  State<MobileJobDetailsScreen> createState() => _MobileJobDetailsScreenState();
}

class _MobileJobDetailsScreenState extends State<MobileJobDetailsScreen> {
  AppJob _job = Job.empty();
  UserJob _userJob = UserJob.empty();
  UserJobCompetencyProfile _userJobCompetencyProfile = UserJobCompetencyProfile.empty();
  User _user = User.empty();

  JobProgressionLevel _detailsLevel = JobProgressionLevel.BEGINNER;
  Duration? nextQuizAvailableIn;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      final jobId = beamState.pathParameters['id'];
      context.read<ProfileBloc>().add(ProfileLoadEvent(notifyIfNotFound: false));
      context.read<JobBloc>().add(LoadJobDetails(context: context, jobId: jobId));
      context.read<JobBloc>().add(LoadUserJobDetails(context: context, jobId: jobId));
      // context.read<JobBloc>().add(LoadUserJobCompetencyProfile(context: context, jobId: jobId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    var options = [locale.skillLevel_easy, locale.skillLevel_medium, locale.skillLevel_hard, locale.skillLevel_expert];
    bool hideBackButton = false;
    final history = Beamer.of(context).beamingHistory;

    if (history.length > 1) {
      final lastBeamState = history[history.length - 2];
      final lastPath = lastBeamState.state.routeInformation.uri.path.toString(); // ← ceci est le path
      hideBackButton = lastPath == AppRoutes.landing;
    }
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _user = state.user;
        }
        setState(() {});
      },
      child: BlocConsumer<JobBloc, JobState>(
        listener: (context, state) {
          if (state is JobDetailsLoaded) {
            _job = state.job;
          }
          if (state is UserJobCompetencyProfileLoaded) {
            _userJobCompetencyProfile = state.profile;
          }
          if (state is UserJobDetailsLoaded) {
            _userJob = state.userJob;
            context.read<JobBloc>().add(LoadUserJobCompetencyProfile(context: context, jobId: _userJob.id!));
            final DateTime now = DateTime.now();
            final DateTime? lastQuizAt = _userJob.lastQuizAt;
            if (lastQuizAt == null) {
              nextQuizAvailableIn = null;
              return;
            }
            if (now.date.isAfter(lastQuizAt.date)) {
              nextQuizAvailableIn = null;
              return;
            }
            final DateTime lastQuizAt2 = DateTime(
              lastQuizAt.year,
              lastQuizAt.month,
              lastQuizAt.day,
              lastQuizAt.hour,
            );
            nextQuizAvailableIn = lastQuizAt2.add(Duration(hours: 24 - lastQuizAt2.hour)).difference(now);
            _countdownTimer?.cancel();
            _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (!mounted) {
                timer.cancel();
                return;
              }
              setState(() {
                final DateTime now = DateTime.now();
                final DateTime lastQuizAt = _userJob.lastQuizAt!;
                final DateTime lastQuizAt2 = DateTime(
                  lastQuizAt.year,
                  lastQuizAt.month,
                  lastQuizAt.day,
                  lastQuizAt.hour,
                );
                if (now.date.isAfter(lastQuizAt.date)) {
                  nextQuizAvailableIn = null;
                  timer.cancel();
                  return;
                }
                nextQuizAvailableIn = lastQuizAt2.add(Duration(hours: 24 - lastQuizAt2.hour)).difference(now);
              });
            });
          }
          setState(() {});
        },
        builder: (context, state) {
          return AppSkeletonizer(
            enabled: _job.id.isEmptyOrNull,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    // if (!hideBackButton)
                    //   GestureDetector(
                    //     onTap: () {
                    //       navigateToPath(context, to: AppRoutes.jobModule);
                    //     },
                    //     child: SvgPicture.asset(
                    //       AppIcons.backButtonPath,
                    //       width: mobileCTAHeight,
                    //       height: mobileCTAHeight,
                    //     ),
                    //   ),
                    Spacer(),
                    AppXCloseButton(),
                  ],
                ),
                AppSpacing.spacing16_Box,
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 2,
                        text: TextSpan(
                          text: _job.title,
                          style: GoogleFonts.anton(
                            color: AppColors.textPrimary,
                            fontSize: theme.textTheme.headlineMedium!.fontSize!,
                            fontWeight: FontWeight.w700,
                          ),
                          children: [
                            // WidgetSpan(
                            //   alignment: PlaceholderAlignment.middle, // aligns icon vertically
                            //   child: Padding(
                            //     padding: const EdgeInsets.only(left: AppSpacing.groupMargin),
                            //     child: GestureDetector(
                            //       onTap: () async {
                            //         await ShareUtils.shareContent(
                            //           text: locale.discover_job_profile(_job.title),
                            //           url: ShareUtils.generateJobDetailsLink(_job.id!),
                            //           subject: locale.job_profile_page_title(_job.title),
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
                      ),
                    ),
                    if (_user.isNotEmpty) ...[
                      AppSpacing.spacing16_Box,
                      ScoreWidget(value: _user.diamonds),
                    ],
                  ],
                ),
                AppSpacing.spacing24_Box,
                AppXButton(
                  onPressed: () {
                    navigateToPath(
                      context,
                      to: AppRoutes.jobEvaluation.replaceAll(':id', _job.id!),
                      data: {'jobTitle': _job.title},
                    );
                  },
                  isLoading: false,
                  disabled: nextQuizAvailableIn != null,
                  text: nextQuizAvailableIn == null
                      ? locale.evaluateSkills
                      : locale.evaluateSkillsAvailableIn(nextQuizAvailableIn!.formattedHMS),
                  shrinkWrap: false,
                ),
                AppSpacing.spacing24_Box,
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
                              color: AppColors.textPrimary,
                              overflow: TextOverflow.ellipsis,
                            ),
                            linkStyle: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textPrimary,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 4,
                            expandText: '\n\n${locale.show_more}',
                            collapseText: '\n\n${locale.show_less}',
                            linkEllipsis: false,
                          ),
                          AppSpacing.spacing24_Box,
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (_userJob.isNotEmpty && _job.id.isNotEmptyOrNull) ...[
                                _rankingBuilder(constraints, locale, theme),
                                AppSpacing.spacing16_Box,
                              ],
                              _diagramBuilder(constraints, locale, theme, options),
                            ],
                          ),
                          AppSpacing.spacing24_Box,
                          ...familiesBuilder(),
                          AppSpacing.spacing40_Box,
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
      ),
    );
  }

  List<Widget> familiesBuilder() {
    final List<Widget> widgets = [];
    for (final family in _job.competenciesFamilies) {
      widgets.add(CFCard(job: _job, family: family));
      widgets.add(AppSpacing.spacing16_Box);
    }
    return widgets;
  }

  _diagramBuilder(BoxConstraints constraints, AppLocalizations locale, ThemeData theme, List<String> options) {
    return Card(
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
              labels: _job.competenciesFamilies.map((cf) => cf.name).toList(),
              defaultValues: _job.kiviatValues(_detailsLevel),
              userValues: _userJobCompetencyProfile.kiviatValues,
            ),
          ),
          AppSpacing.spacing16_Box,
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.skillsDiagramTitle,
                  style: theme.textTheme.labelLarge!.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.spacing16_Box,
                AppXDropdown<int>(
                  controller: TextEditingController(text: options[_detailsLevel.index]),
                  items: options.map((level) => DropdownMenuEntry(
                        value: options.indexOf(level),
                        label: level,
                      )),
                  onSelected: (level) {
                    setState(() {
                      _detailsLevel = JobProgressionLevel.values[level!];
                    });
                  },
                  // labelInside: null,
                  shrinkWrap: true,
                  fgColor: AppColors.textPrimary,
                ),
              ],
            ),
          ),
          AppSpacing.spacing24_Box,
        ],
      ),
    );
  }

  _rankingBuilder(BoxConstraints constraints, AppLocalizations locale, ThemeData theme) {
    return Card(
      elevation: 0,
      color: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.large,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxWidth / 1.618,
              child: RankingChart(jobId: _job.id!),
            )
          ],
        ),
      ),
    );
  }
}
