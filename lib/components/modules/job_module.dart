import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/modules/app_module.dart';
import 'package:murya/components/score.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/job_kiviat.dart';
import 'package:murya/models/module.dart';
import 'package:murya/models/user_job_competency_profile.dart';
import 'package:murya/screens/job_details/job_details.dart';

class JobModuleWidget extends StatefulWidget {
  final Module module;
  final VoidCallback? onSizeChanged;
  final Widget? dragHandle;
  final GlobalKey? tileKey;
  final EdgeInsetsGeometry cardMargin;

  const JobModuleWidget({
    super.key,
    required this.module,
    this.onSizeChanged,
    this.dragHandle,
    this.tileKey,
    this.cardMargin = const EdgeInsets.all(4),
  });

  @override
  State<JobModuleWidget> createState() => _JobModuleWidgetState();
}

class _JobModuleWidgetState extends State<JobModuleWidget> {
  UserJob _userJob = UserJob();
  Duration? nextQuizAvailableIn;
  Timer? _countdownTimer;
  Job? _job;
  JobFamily? _jobFamily;
  int _detailsLevel = 0;
  UserJobCompetencyProfile _userJobCompetencyProfile = UserJobCompetencyProfile.empty();

  @override
  void initState() {
    context.read<JobBloc>().add(LoadUserCurrentJob(context: context));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    final locale = AppLocalizations.of(context);
    var options = [locale.skillLevel_easy, locale.skillLevel_medium, locale.skillLevel_hard, locale.skillLevel_expert];
    return BlocConsumer<ModulesBloc, ModulesState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        return BlocConsumer<JobBloc, JobState>(
          listener: (context, state) {
            if (state is UserJobDetailsLoaded) {
              _userJob = state.userJob;
              if (state.userJob.jobFamily != null) {
                _jobFamily = state.userJob.jobFamily!;
              } else {
                _jobFamily = JobFamily.empty();
                _job = _userJob.job!;
              }
              context.read<JobBloc>().add(LoadUserJobCompetencyProfile(context: context, jobId: _userJob.id!));
              _checkQuizAvailability();
            }
            if (state is UserJobCompetencyProfileLoaded) {
              _userJobCompetencyProfile = state.profile;
            }
            setState(() {});
          },
          builder: (context, state) {
            final UserJob userCurrentJob = state.userCurrentJob ?? UserJob.empty();
            return Container(
              key: widget.tileKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 2500),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: AppModuleWidget(
                  key: ValueKey('job-module-${widget.module.id}-empty'),
                  module: widget.module,
                  onCardTap: () {
                    navigateToPath(
                      context,
                      to: AppRoutes.jobDetails.replaceAll(':id', userCurrentJob.jobId!),
                    );
                  },
                  hasData: state.userCurrentJob != null,
                  // titleContent: userCurrentJob.job?.title ?? '',
                  subtitleContent: ScoreWidget(
                    value: context.read<ProfileBloc>().user.diamonds,
                    // iconColor: AppColors.primaryDefault,
                    isLandingPage: true,
                  ),
                  bodyContent: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: _diagramBuilder(locale, theme, options),
                  ),
                  footerContent: AppXButton(
                    shrinkWrap: false,
                    onPressed: () {
                      // if (nextQuizAvailableIn != null) return;
                      // navigateToPath(context, to: AppRoutes.jobEvaluation.replaceAll(':id', userCurrentJob.jobId!));
                      navigateToPath(
                        context,
                        to: AppRoutes.jobDetails.replaceAll(':id', userCurrentJob.jobId ?? userCurrentJob.jobFamilyId!),
                      );
                    },
                    isLoading: false,
                    text: locale.landingSkillButtonText,
                    // disabled: nextQuizAvailableIn != null,
                  ),
                  onSizeChanged: widget.onSizeChanged,
                  dragHandle: widget.dragHandle,
                  cardMargin: widget.cardMargin,
                ),
              ),
            );
          },
        );
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
        final AppModuleType moduleType = widget.module.boxType;
        final bool isMobile = DeviceHelper.isMobile(context);
        final bool smallHeight = moduleType == AppModuleType.type1 || moduleType == AppModuleType.type1_2 || isMobile;
        return SizedBox(
          height: constraints.maxWidth,
          width: constraints.maxWidth,
          child: Center(
            child: InteractiveRoundedRadarChart(
              labels: _userJobCompetencyProfile.competencyFamilies.map((cf) => cf.name).toList(),
              defaultValues: (_job ?? _jobFamily ?? Job.empty()).kiviatValues(JobProgressionLevel.JUNIOR),
              userValues: _userJobCompetencyProfile.kiviatValues,
              // labelBgColor: AppColors.whiteSwatch,
              // labelTextColor: AppColors.primaryDefault,
              hideTexts: smallHeight,
            ),
          ),
        );
      }),
    );
  }
}
