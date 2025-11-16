import 'dart:async';
import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/modules/app_module.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/module.dart';
import 'package:murya/models/user_job_competency_profile.dart';
import 'package:murya/screens/job_details/job_details.dart';

class JobModuleWidget extends StatefulWidget {
  final Module module;
  final VoidCallback? onSizeChanged;

  const JobModuleWidget({
    super.key,
    required this.module,
    this.onSizeChanged,
  });

  @override
  State<JobModuleWidget> createState() => _JobModuleWidgetState();
}

class _JobModuleWidgetState extends State<JobModuleWidget> {
  @override
  void initState() {
    log("JobModuleWidget initState");
    // context.read<JobBloc>().add(LoadUserCurrentJob(context: context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModulesBloc, ModulesState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        return BlocConsumer<JobBloc, JobState>(
          listener: (context, state) {
            setState(() {});
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 2500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: state.userCurrentJob != null
                  ? AppModuleWidget(
                      module: widget.module,
                      onCardTap: () {
                        navigateToPath(
                          context,
                          to: AppRoutes.jobDetails.replaceAll(':id', state.userCurrentJob!.jobId!),
                        );
                      },
                      content: JobModuleContent(userJob: state.userCurrentJob!),
                      onSizeChanged: widget.onSizeChanged,
                    )
                  : AppModuleWidget(
                      module: widget.module,
                      content: null,
                      onSizeChanged: widget.onSizeChanged,
                    ),
            );
          },
        );
      },
    );
  }
}

class JobModuleContent extends StatefulWidget {
  final UserJob userJob;

  const JobModuleContent({super.key, required this.userJob});

  @override
  State<JobModuleContent> createState() => _JobModuleContentState();
}

class _JobModuleContentState extends State<JobModuleContent> {
  UserJob _userJob = UserJob();
  Duration? nextQuizAvailableIn;
  Timer? _countdownTimer;
  Job _job = Job.empty();
  int _detailsLevel = 0;
  UserJobCompetencyProfile _userJobCompetencyProfile = UserJobCompetencyProfile.empty();

  @override
  void initState() {
    _userJob = widget.userJob;
    _job = _userJob.job!;
    context.read<JobBloc>().add(LoadUserJobCompetencyProfile(context: context, jobId: _userJob.jobId!));
    _checkQuizAvailability();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    final locale = AppLocalizations.of(context);
    var options = [locale.skillLevel_easy, locale.skillLevel_medium, locale.skillLevel_hard, locale.skillLevel_expert];

    return BlocConsumer<JobBloc, JobState>(
      listener: (context, state) {
        log("JobModuleContent JobBloc listener: $state");
        if (state is UserJobDetailsLoaded) {
          _userJob = state.userJob;
          _job = _userJob.job!;
          // context.read<JobBloc>().add(LoadJobDetails(context: context, jobId: _userJob.jobId!));
          context.read<JobBloc>().add(LoadUserJobCompetencyProfile(context: context, jobId: _userJob.jobId!));
          _checkQuizAvailability();
        }
        if (state is UserJobCompetencyProfileLoaded) {
          _userJobCompetencyProfile = state.profile;
        }
        setState(() {});
      },
      builder: (context, state) {
        return LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: 1000,
                child: InkWell(
                  onTap: () {
                    navigateToPath(
                      context,
                      to: AppRoutes.jobDetails.replaceAll(':id', _userJob.jobId!),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: SizedBox(
                          width: constraints.maxWidth * 0.85,
                          child: AutoSizeText(
                            _userJob.job?.title ?? '',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.anton(
                              color: Colors.white,
                              fontSize: isMobile
                                  ? theme.textTheme.headlineSmall!.fontSize!
                                  : theme.textTheme.displaySmall!.fontSize!,
                              fontWeight: FontWeight.w700,
                            ),
                            minFontSize: theme.textTheme.bodyLarge!.fontSize!,
                          ),
                        ),
                      ),
                      AppSpacing.groupMarginBox,
                      Expanded(flex: 2, child: _diagramBuilder(locale, theme, options)),
                    ],
                  ),
                ),
              ),
              if (constraints.maxHeight >= 163 + (isMobile ? 0 : 36)) ...[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppSpacing.groupMarginBox,
                    AppXButton(
                      autoResize: false,
                      onPressed: () {
                        log("Evaluate Skills button pressed");
                        if (nextQuizAvailableIn != null) return;
                        navigateToPath(context, to: AppRoutes.jobEvaluation.replaceAll(':id', _userJob.jobId!));
                      },
                      isLoading: false,
                      text: nextQuizAvailableIn == null
                          ? locale.evaluateSkills
                          : locale.evaluateSkillsAvailableIn(nextQuizAvailableIn!.formattedHMS),
                      disabled: nextQuizAvailableIn != null,
                      borderColor: AppColors.whiteSwatch,
                      bgColor: AppColors.whiteSwatch,
                      fgColor: AppColors.primaryDefault,
                      // disabledColor: AppColors.primaryDisabled,
                    ),
                    AppSpacing.elementMarginBox,
                  ],
                ),
              ],
            ],
          );
        });
      },
    );
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
  }

  _diagramBuilder(AppLocalizations locale, ThemeData theme, List<String> options) {
    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxWidth,
          width: constraints.maxWidth,
          child: Center(
            child: InteractiveRoundedRadarChart(
              labels: _userJobCompetencyProfile.competencyFamilies
                  //
                  .map((cf) => cf.name)
                  .toList(),
              // defaultValues: _userJobCompetencyProfile.competencyFamilies
              //     //
              //     .map((cf) => cf.averageScoreByLevel(level: _detailsLevel))
              //     .toList(),
              defaultValues: _userJobCompetencyProfile.competencyFamiliesValues,
              userValues: _userJobCompetencyProfile.competencyFamiliesValues,
              labelBgColor: AppColors.whiteSwatch,
              labelTextColor: AppColors.primaryDefault,
            ),
          ),
        );
      }),
    );
  }
}
