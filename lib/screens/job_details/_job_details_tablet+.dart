part of 'job_details.dart';

class TabletJobDetailsScreen extends StatefulWidget {
  const TabletJobDetailsScreen({super.key});

  @override
  State<TabletJobDetailsScreen> createState() => _TabletJobDetailsScreenState();
}

class _TabletJobDetailsScreenState extends State<TabletJobDetailsScreen> {
  Job _job = Job.empty();
  JobProgressionLevel _detailsLevel = JobProgressionLevel.JUNIOR;
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
      context.read<JobBloc>().add(LoadUserJobCompetencyProfile(context: context, jobId: jobId));
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
            _checkQuizAvailability();
          }
          setState(() {});
        },
        builder: (context, state) {
          return AppSkeletonizer(
            enabled: _job.id.isEmptyOrNull,
            child: LayoutBuilder(builder: (context, bigConstraints) {
              return SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      height: bigConstraints.maxHeight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (!hideBackButton)
                                GestureDetector(
                                  onTap: () {
                                    navigateToPath(context, to: AppRoutes.jobModule);
                                  },
                                  child: SvgPicture.asset(
                                    AppIcons.backButtonPath,
                                    width: tabletAndAboveCTAHeight,
                                    height: tabletAndAboveCTAHeight,
                                  ),
                                ),
                              AppSpacing.groupMarginBox,
                              Expanded(
                                flex: 10,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: RichText(
                                        text: TextSpan(
                                          text: _job.title,
                                          style: GoogleFonts.anton(
                                            color: AppColors.textPrimary,
                                            fontSize: theme.textTheme.headlineLarge?.fontSize,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          children: [
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.middle, // aligns icon vertically
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: AppSpacing.elementMargin),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    await ShareUtils.shareContent(
                                                      text: locale.discover_job_profile(_job.title),
                                                      url: ShareUtils.generateJobDetailsLink(_job.id!),
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
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                      ),
                                    ),
                                    if (_user.isNotEmpty) ...[
                                      AppSpacing.groupMarginBox,
                                      ScoreWidget(value: _user.diamonds),
                                    ],
                                  ],
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  navigateToPath(context, to: AppRoutes.landing);
                                },
                                child: SvgPicture.asset(
                                  AppIcons.searchBarCloseIconPath,
                                  width: tabletAndAboveCTAHeight,
                                  height: tabletAndAboveCTAHeight,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.sectionMarginBox,
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
                                      // AppSpacing.containerInsideMarginBox,
                                      AppXButton(
                                        onPressed: () {
                                          navigateToPath(context,
                                              to: AppRoutes.jobEvaluation.replaceAll(':id', _job.id!));
                                        },
                                        isLoading: false,
                                        disabled: nextQuizAvailableIn != null,
                                        text: nextQuizAvailableIn == null
                                            ? locale.evaluateSkills
                                            : locale.evaluateSkillsAvailableIn(nextQuizAvailableIn!.formattedHMS),
                                        shrinkWrap: false,
                                      ),
                                      AppSpacing.containerInsideMarginBox,
                                      Expanded(
                                        child: MarkdownWidget(
                                          data: _job.description,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppSpacing.groupMarginBox,
                                Flexible(
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          if (_userJob.isNotEmpty && _job.id.isNotEmptyOrNull) ...[
                                            _rankingBuilder(locale, theme),
                                            AppSpacing.elementMarginBox,
                                          ],
                                          _diagramBuilder(locale, theme, options),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                AppSpacing.groupMarginBox,
                                Flexible(
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
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
                    AppSpacing.sectionMarginBox,
                    const AppFooter(),
                  ],
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
    for (final family in _job.competenciesFamilies) {
      widgets.add(CFCard(job: _job, family: family));
      widgets.add(AppSpacing.groupMarginBox);
    }
    return widgets;
  }

  _diagramBuilder(AppLocalizations locale, ThemeData theme, List<String> options) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.large,
      ),
      padding: const EdgeInsets.only(
        // top: AppSpacing.containerInsideMargin,
        left: AppSpacing.elementMargin,
        right: AppSpacing.elementMargin,
        bottom: AppSpacing.containerInsideMargin,
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
                labels: _job.competenciesFamilies.map((cf) => cf.name).toList(),
                defaultValues: _job.kiviatValues(_detailsLevel),
                userValues: _userJobCompetencyProfile.kiviatValues,
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
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: AppColors.primaryDefault, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.groupMarginBox,
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
                  labelInside: null,
                  autoResize: true,
                  foregroundColor: AppColors.primaryDefault,
                ),
              ],
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
        color: AppColors.backgroundCard,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.large,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth / (1.618 * 2.5),
                child: RankingChart(jobId: _job.id!),
              )
            ],
          ),
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
