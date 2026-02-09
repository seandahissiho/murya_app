part of 'job_details.dart';

class TabletJobDetailsScreen extends StatefulWidget {
  const TabletJobDetailsScreen({super.key});

  @override
  State<TabletJobDetailsScreen> createState() => _TabletJobDetailsScreenState();
}

class _TabletJobDetailsScreenState extends State<TabletJobDetailsScreen> {
  AppJob _job = AppJob.empty();
  JobProgressionLevel _detailsLevel = JobProgressionLevel.BEGINNER;
  UserJob _userJob = UserJob.empty();
  UserJobCompetencyProfile _userJobCompetencyProfile = UserJobCompetencyProfile.empty();
  User _user = User.empty();

  Duration? nextQuizAvailableIn;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      final jobId = beamState.pathParameters['id'];
      context.read<JobBloc>().add(LoadJobDetails(context: context, jobId: jobId));
      context.read<ProfileBloc>().add(ProfileLoadEvent(notifyIfNotFound: false));
      context.read<JobBloc>().add(LoadUserJobDetails(context: context, jobId: jobId));
      _checkQuizAvailability();
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
      // get last 3 paths
      final last3Paths = history
          .sublist(history.length - 4 < 0 ? 0 : history.length - 4, history.length - 1)
          .map((beamState) => beamState.state.routeInformation.uri.path.toString())
          .toList();
      // if last 3 paths contain landing, hide back button
      hideBackButton = true;
      if (last3Paths.contains(AppRoutes.searchModule)) {
        hideBackButton = false;
      }
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
            _checkQuizAvailability();
          }
          setState(() {});
        },
        builder: (context, state) {
          return AppSkeletonizer(
            enabled: _job?.id.isEmptyOrNull ?? false,
            child: LayoutBuilder(builder: (context, bigConstraints) {
              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        height: bigConstraints.maxHeight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (!hideBackButton) const AppXReturnButton(destination: AppRoutes.searchModule),
                                // AppSpacing.groupMarginBox,
                                // Expanded(
                                //   flex: 10,
                                //   child: Row(
                                //     mainAxisSize: MainAxisSize.max,
                                //     mainAxisAlignment: MainAxisAlignment.start,
                                //     children: [
                                //       Flexible(
                                //         child: RichText(
                                //           text: TextSpan(
                                //             text: _job.title,
                                //             style: GoogleFonts.anton(
                                //               color: AppColors.textPrimary,
                                //               fontSize: theme.textTheme.headlineLarge?.fontSize,
                                //               fontWeight: FontWeight.w700,
                                //             ),
                                //             children: [
                                //               WidgetSpan(
                                //                 alignment: PlaceholderAlignment.middle, // aligns icon vertically
                                //                 child: Padding(
                                //                   padding: const EdgeInsets.only(left: AppSpacing.elementMargin),
                                //                   child: GestureDetector(
                                //                     onTap: () async {
                                //                       await ShareUtils.shareContent(
                                //                         text: locale.discover_job_profile(_job.title),
                                //                         url: ShareUtils.generateJobDetailsLink(_job.id!),
                                //                         subject: locale.job_profile_page_title(_job.title),
                                //                       );
                                //                       if (kIsWeb && mounted && context.mounted) {
                                //                         // On web, there's a good chance we just copied to clipboard
                                //                         ScaffoldMessenger.of(context).showSnackBar(
                                //                           SnackBar(content: Text(locale.link_copied)),
                                //                         );
                                //                       }
                                //                     },
                                //                     child: Icon(
                                //                       Icons.ios_share,
                                //                       size: theme.textTheme.displayLarge!.fontSize! / 1.75,
                                //                       color: AppColors.primaryDefault,
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //           textAlign: TextAlign.start,
                                //           maxLines: 2,
                                //         ),
                                //       ),
                                //       if (_user.isNotEmpty) ...[
                                //         AppSpacing.groupMarginBox,
                                //         ScoreWidget(value: _user.diamonds),
                                //       ],
                                //     ],
                                //   ),
                                // ),
                                const Spacer(),
                                const AppXCloseButton(),
                              ],
                            ),
                            AppSpacing.spacing40_Box,
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
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: RichText(
                                                text: TextSpan(
                                                  text: _job?.title,
                                                  style: GoogleFonts.anton(
                                                    color: AppColors.textPrimary,
                                                    fontSize: theme.textTheme.headlineLarge?.fontSize,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  children: [
                                                    // WidgetSpan(
                                                    //   alignment: PlaceholderAlignment.middle, // aligns icon vertically
                                                    //   child: Padding(
                                                    //     padding: const EdgeInsets.only(left: AppSpacing.elementMargin),
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
                                                    //       child: Icon(
                                                    //         Icons.ios_share,
                                                    //         size: theme.textTheme.displayLarge!.fontSize! / 1.75,
                                                    //         color: AppColors.primaryDefault,
                                                    //       ),
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                textAlign: TextAlign.start,
                                                maxLines: 2,
                                              ),
                                            ),
                                            if (_user.isNotEmpty) ...[
                                              AppSpacing.spacing16_Box,
                                              Padding(
                                                padding: const EdgeInsets.only(top: 20.0),
                                                child: ScoreWidget(value: _user.diamonds),
                                              ),
                                            ],
                                          ],
                                        ),
                                        AppSpacing.spacing24_Box,
                                        AppXButton(
                                          onPressed: () {
                                            navigateToPath(
                                              context,
                                              to: AppRoutes.jobEvaluation.replaceAll(':id', _job!.id!),
                                              data: {'jobTitle': _job!.title},
                                            );
                                          },
                                          isLoading: false,
                                          // disabled: nextQuizAvailableIn != null,
                                          text: nextQuizAvailableIn == null
                                              ? locale.evaluateSkills
                                              : locale.evaluateSkillsAvailableIn(nextQuizAvailableIn!.formattedHMS),
                                          shrinkWrap: false,
                                        ),
                                        AppSpacing.spacing24_Box,
                                        Expanded(
                                          child: MarkdownWidget(
                                            data: _job?.description ?? '',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppSpacing.spacing16_Box,
                                  Flexible(
                                    child: ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            _diagramBuilder(locale, theme, options),
                                            if (_userJob.isNotEmpty &&
                                                (_job?.id.isNotEmptyOrNull ?? false) &&
                                                (_userJob.jobId == _job?.id || _userJob.jobFamilyId == _job?.id) &&
                                                _userJob.completedQuizzes > 0) ...[
                                              AppSpacing.spacing16_Box,
                                              _rankingBuilder(locale, theme),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  AppSpacing.spacing16_Box,
                                  Flexible(
                                    child: ScrollConfiguration(
                                      behavior: ScrollConfiguration.of(context).copyWith(
                                        scrollbars: false,
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ...familiesBuilder(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.spacing40_Box,
                      const AppFooter(),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  List<Widget> familiesBuilder() {
    final List<Widget> widgets = [];
    for (final family in (_job?.competenciesFamilies ?? [])) {
      widgets.add(CFCard(job: _job ?? Job.empty(), family: family));
      widgets.add(AppSpacing.spacing16_Box);
    }
    return widgets;
  }

  _diagramBuilder(AppLocalizations locale, ThemeData theme, List<String> options) {
    return Container(
      decoration: const BoxDecoration(
        // color: AppColors.backgroundCard,
        color: Colors.white,
        borderRadius: AppRadius.large,
      ),
      padding: const EdgeInsets.only(
        // top: AppSpacing.containerInsideMargin,
        left: AppSpacing.spacing8,
        right: AppSpacing.spacing8,
        bottom: AppSpacing.spacing24,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.spacing24,
                left: AppSpacing.spacing24 - AppSpacing.spacing8,
                right: AppSpacing.spacing24 - AppSpacing.spacing8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      locale.skillsDiagramTitle,
                      style: GoogleFonts.anton(
                        fontSize: 32,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
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
                    shrinkWrap: false,
                    maxDropdownWidth: 150,
                    fgColor: AppColors.textPrimary,
                    bgColor: AppColors.backgroundColor,
                  ),
                ],
              ),
            ),
            AppSpacing.spacing16_Box,
            SizedBox(
              height: constraints.maxWidth,
              width: constraints.maxWidth,
              child: InteractiveRoundedRadarChart(
                labels: _job.competenciesFamilies.map((cf) => cf.name).toList() ?? [],
                defaultValues: _job.kiviatValues(_detailsLevel) ?? [],
                userValues: _userJob.kiviatsValues,
              ),
            ),
          ],
        );
      }),
    );
  }

  _rankingBuilder(AppLocalizations locale, ThemeData theme) {
    return LayoutBuilder(builder: (context, constraints) {
      return Card(
        elevation: 0,
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.large,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxWidth / (1.618 * 1.5),
              child: RankingChart(jobId: _job?.id! ?? ''),
            )
          ],
        ),
      );
    });
  }

  void _checkQuizAvailability() {
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

    setState(() {});
  }
}
