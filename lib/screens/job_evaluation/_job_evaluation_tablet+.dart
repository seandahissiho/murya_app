part of 'job_evaluation.dart';

class TabletJobEvaluationScreen extends StatefulWidget {
  const TabletJobEvaluationScreen({super.key});

  @override
  State<TabletJobEvaluationScreen> createState() => _TabletJobEvaluationScreenState();
}

class _TabletJobEvaluationScreenState extends State<TabletJobEvaluationScreen> with TickerProviderStateMixin {
  late final String jobId;
  Quiz quiz = Quiz(questionResponses: []);
  QuestionResponses? currentQuestion;
  int currentQuestionIndex = -1;
  bool quizLoaded = false;
  bool started = false;
  final List<QuizResponse> answers = [];
  List<int> pointsPerQuestion = [];

  // Adjust to whatever per-question time you need.
  static const _total = Duration(seconds: 30);

  AnimationController? _countdown;

  int showVerificationState = -1;

  int displayCorrectIndex = -1;

  bool locked = true;

  int indexToRotate = -1;

  int get timeLeftInSeconds {
    return ((_countdown?.duration!.inSeconds ?? 0) * (_countdown?.value ?? 0)).ceil();
  }

  late final AnimationController _confettiCtrl;
  bool _showConfetti = false;
  bool _confettiLoaded = false;

  int totalPoints = 0;

  @override
  void initState() {
    _confettiCtrl = AnimationController(vsync: this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      jobId = beamState.pathParameters['id'];
      context.read<QuizBloc>().add(LoadQuizForJob(jobId: jobId));
      final theme = Theme.of(context);
      final localizations = AppLocalizations.of(context);
      displayPopUp(
        context: context,
        okText: localizations.quiz_lets_go,
        // okEnabled: quizLoaded,
        noActions: true,
        contents: [
          SvgPicture.asset(
            AppIcons.popupIconPath,
          ),
          AppSpacing.containerInsideMarginBox,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              localizations.quiz_ready_to_evaluate,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: theme.textTheme.displayMedium?.fontSize,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          AppSpacing.groupMarginBox,
          Text(
            localizations.quiz_start_description_1,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.start,
          ),
          AppSpacing.groupMarginBox,
          Text(
            localizations.quiz_start_description_2,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.start,
          ),
          AppSpacing.groupMarginBox,
          Text(
            localizations.quiz_start_description_3,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.start,
          ),
          AppSpacing.containerInsideMarginBox,
          Text(
            localizations.quiz_start_advice,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontWeight: FontWeight.w100),
            textAlign: TextAlign.start,
          ),
          AppSpacing.sectionMarginBox,
          BlocConsumer<QuizBloc, QuizState>(
            listener: (context, state) {
              setState(() {});
            },
            builder: (context, state) {
              return Row(
                children: [
                  Flexible(
                    child: AppXButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop(true);
                      },
                      isLoading: state is! QuizLoaded,
                      disabled: state is! QuizLoaded,
                      shrinkWrap: false,
                      text: localizations.quiz_lets_go,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ).then((value) {
        if (value == true) {
          started = true;
          setState(() {});
          Future.delayed(const Duration(milliseconds: 250), () async {
            while (mounted && !quizLoaded) {
              await Future.delayed(const Duration(milliseconds: 100));
            }
            moveToNextQuestion();
          });
        } else {
          if (!mounted) return;
          navigateToPath(context, to: AppRoutes.jobDetails.replaceFirst(':id', jobId));
        }
      });

      // quiz = Quiz.fromJson(TEST_QUIZ);
      // initialized = true;
      setState(() {});
      // Future.delayed(const Duration(seconds: 5), () {
      //   context.beamBack();
      // });
    });
    // pauseTimer();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _countdown?.dispose();
    super.dispose();
  }

  void _playConfetti() {
    if (!_confettiLoaded) return;

    setState(() => _showConfetti = true);

    _confettiCtrl
      ..stop()
      ..reset()
      ..forward();

    final duration = _confettiCtrl.duration ?? const Duration(milliseconds: 1500);

    final pointsDisplayDuration = duration - const Duration(milliseconds: 1000);

    Future.delayed(pointsDisplayDuration, () {
      if (!mounted) return;
      setState(() {
        totalPoints += (currentQuestion?.question.points ?? 0) + timeLeftInSeconds;
      });
    });

    Future.delayed(duration + const Duration(milliseconds: 150), () {
      if (!mounted) return;
      setState(() => _showConfetti = false);
    });
  }

  void pauseTimer() => _countdown?.stop();

  void resumeTimer() => _countdown?.reverse(from: _countdown?.value);

  void restartTimer() => _countdown?.reverse(from: 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final deviceType = DeviceHelper.getDeviceType(context);
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizLoaded) {
          quiz = state.quiz;
          quizLoaded = true;
          currentQuestionIndex = -1;
        }
        if (state is QuizSaved) {
          navigateToPath(context, to: AppRoutes.landing);
        }
        setState(() {});
      },
      builder: (context, state) {
        // if (!quizLoaded || !started) {
        //   return const SizedBox.shrink();
        // }
        return Stack(
          children: [
            Column(
              children: [
                Container(
                  color: AppColors.backgroundDefault,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          navigateToPath(context, to: AppRoutes.jobDetails.replaceFirst(':id', jobId));
                        },
                        child: SvgPicture.asset(
                          AppIcons.exitIconPath,
                          width: tabletAndAboveCTAHeight,
                          height: tabletAndAboveCTAHeight,
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        flex: 8,
                        child: SizedBox(
                          height: 24,
                          child: ClipRRect(
                            borderRadius: AppRadius.large,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Track (background)
                                Container(color: AppColors.borderLight),
                                // Animated fill (shrinks left -> right)
                                if (_countdown != null)
                                  AnimatedBuilder(
                                    animation: _countdown!,
                                    builder: (context, _) {
                                      return Align(
                                        alignment: Alignment.centerRight,
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerRight,
                                          widthFactor: _countdown?.value, // 1.0..0.0
                                          child: Container(
                                            color: AppColors.primaryFocus,
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  left: 8,
                                                  bottom: 0,
                                                  top: 0,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Flexible(
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            '$timeLeftInSeconds',
                                                            style: theme.textTheme.labelLarge
                                                                ?.copyWith(color: AppColors.whiteSwatch),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ScoreWidget(
                        value: totalPoints,
                      ),
                    ],
                  ),
                ),
                AppSpacing.sectionMarginBox,
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Container(
                      // color: Colors.black38,
                      constraints: BoxConstraints(
                        maxWidth: _getMaxWidthForQuestionCard(deviceType),
                        minHeight: 400,
                        maxHeight: 534,
                      ),
                      child: Stack(
                        children: [
                          LayoutBuilder(
                            builder: (context, bigConstraints) {
                              return Row(
                                children: [
                                  // Expanded(
                                  //   child: Column(
                                  //     crossAxisAlignment: CrossAxisAlignment.start,
                                  //     mainAxisAlignment: MainAxisAlignment.start,
                                  //     mainAxisSize: MainAxisSize.max,
                                  //     children: [
                                  //       Text(
                                  //         localizations.quiz_question_counter(
                                  //             currentQuestionIndex + 1, quiz.questionResponses.length),
                                  //         style: theme.textTheme.labelLarge,
                                  //       ),
                                  //       AppSpacing.groupMarginBox,
                                  //       Expanded(
                                  //         child: Container(
                                  //           constraints: BoxConstraints(
                                  //             minWidth: bigConstraints.maxWidth,
                                  //             minHeight: bigConstraints.maxWidth / 1.618,
                                  //             maxWidth: bigConstraints.maxWidth,
                                  //             maxHeight: bigConstraints.maxWidth,
                                  //           ),
                                  //           decoration: const BoxDecoration(
                                  //             color: AppColors.primaryDefault,
                                  //             borderRadius: AppRadius.borderRadius20,
                                  //             image: DecorationImage(
                                  //               image: AssetImage(AppImages.CFCardBackgroundPath),
                                  //               fit: BoxFit.cover,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // AppSpacing.sectionMarginBox,
                                  Expanded(
                                    child: LayoutBuilder(builder: (context, constraints) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            localizations.quiz_question_counter(
                                                currentQuestionIndex + 1, quiz.questionResponses.length),
                                            style: theme.textTheme.labelLarge,
                                          ),
                                          AppSpacing.groupMarginBox,
                                          // AppSpacing.groupMarginBox,
                                          Expanded(
                                            child: AutoSizeText(
                                              (currentQuestion?.question.text ?? ''),
                                              style:
                                                  theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600),
                                              maxLines: 5,
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                          AppSpacing.sectionMarginBox,
                                          Center(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: constraints.maxWidth,
                                                maxHeight: constraints.maxWidth / (1.618 * 1.25),
                                              ),
                                              child: LayoutBuilder(builder: (context, constraints) {
                                                return Wrap(
                                                  spacing: AppSpacing.elementMargin,
                                                  runSpacing: AppSpacing.groupMargin,
                                                  children: List.generate(4, (index) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        if (locked) return;
                                                        if (displayCorrectIndex != -1) {
                                                          // already showing correct answer, do nothing
                                                          return;
                                                        }
                                                        if (showVerificationState != index) {
                                                          showVerificationState = index;
                                                          setState(() {});
                                                        } else {}
                                                      },
                                                      onDoubleTap: () {
                                                        if (locked) return;
                                                        showVerificationState = index;
                                                        showCorrectAnswer();
                                                      },
                                                      child: RotationTransition(
                                                        turns: (indexToRotate == index)
                                                            ? Tween(begin: 1.0, end: 0.99).animate(
                                                                CurvedAnimation(
                                                                  parent: AnimationController(
                                                                    vsync: this,
                                                                    duration: const Duration(milliseconds: 250),
                                                                  )..forward(),
                                                                  curve: Curves.easeInOut,
                                                                ),
                                                              )
                                                            : const AlwaysStoppedAnimation(0),
                                                        child: Card(
                                                          elevation: 2,
                                                          shadowColor: AppColors.borderMedium,
                                                          margin: EdgeInsetsGeometry.zero,
                                                          shape: const RoundedRectangleBorder(
                                                            borderRadius: AppRadius.borderRadius20,
                                                          ),
                                                          child: Stack(
                                                            children: [
                                                              _card(constraints, index, theme, type: "normal"),
                                                              if (showVerificationState == index &&
                                                                  displayCorrectIndex == -1) ...[
                                                                Positioned.fill(
                                                                  child: Container(
                                                                    decoration: BoxDecoration(
                                                                      color: AppColors.backgroundCard
                                                                          .withValues(alpha: .65),
                                                                      borderRadius: AppRadius.borderRadius20,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Positioned.fill(
                                                                  child: LayoutBuilder(builder: (context, constraints) {
                                                                    return Container(
                                                                      decoration: BoxDecoration(
                                                                        color: AppColors.primaryFocus
                                                                            .withValues(alpha: .15),
                                                                        borderRadius: AppRadius.borderRadius20,
                                                                        border: Border.all(
                                                                          color: AppColors.primaryFocus,
                                                                          width: 2,
                                                                        ),
                                                                      ),
                                                                      child: Center(
                                                                        child: Padding(
                                                                          padding: EdgeInsets.only(
                                                                              top: constraints.maxHeight / 3),
                                                                          child: AppXButton(
                                                                            onPressed: () {
                                                                              showCorrectAnswer();
                                                                            },
                                                                            isLoading: false,
                                                                            text: localizations.quiz_verify,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                                ),
                                                              ],
                                                              if (displayCorrectIndex != -1) ...[
                                                                Positioned.fill(
                                                                  child: Container(
                                                                    decoration: const BoxDecoration(
                                                                      color: Colors.transparent,
                                                                      borderRadius: AppRadius.borderRadius20,
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (displayCorrectIndex == index)
                                                                  _card(constraints, index, theme, type: "correct"),
                                                                if (displayCorrectIndex != index &&
                                                                    showVerificationState == index)
                                                                  _card(constraints, index, theme, type: "error"),
                                                              ]
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                );
                                              }),
                                            ),
                                          )
                                        ],
                                      );
                                    }),
                                  )
                                ],
                              );
                            },
                          ),
                          if (currentQuestion == null)
                            Positioned.fill(
                              child: Container(
                                color: Colors.transparent,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                AppSpacing.pageMarginBox,
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
            // ✅ Confetti overlay
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: AnimatedOpacity(
                  opacity: _showConfetti ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: Lottie.asset(
                    'assets/lotties/confetti on transparent background.json',
                    controller: _confettiCtrl,
                    fit: BoxFit.cover,
                    repeat: false,
                    onLoaded: (composition) {
                      _confettiCtrl.duration = composition.duration;
                      _confettiLoaded = true;
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    // return Column(
    //   children: [
    //     Container(
    //       color: AppColors.backgroundDefault,
    //       child: Row(
    //         children: [
    //           GestureDetector(
    //             onTap: () {
    //               navigateToPath(context, to: AppRoutes.jobDetails.replaceFirst(':id', jobId));
    //             },
    //             child: SvgPicture.asset(
    //               AppIcons.exitIconPath,
    //               width: tabletAndAboveCTAHeight,
    //               height: tabletAndAboveCTAHeight,
    //             ),
    //           ),
    //           const Spacer(),
    //           Expanded(
    //             flex: 8,
    //             child: SizedBox(
    //               height: 24,
    //               child: ClipRRect(
    //                 borderRadius: AppRadius.large,
    //                 child: Stack(
    //                   fit: StackFit.expand,
    //                   children: [
    //                     // Track (background)
    //                     Container(color: AppColors.borderLight),
    //                     // Animated fill (shrinks left -> right)
    //                     if (_countdown != null)
    //                       AnimatedBuilder(
    //                         animation: _countdown!,
    //                         builder: (context, _) {
    //                           return Align(
    //                             alignment: Alignment.centerRight,
    //                             child: FractionallySizedBox(
    //                               alignment: Alignment.centerRight,
    //                               widthFactor: _countdown?.value, // 1.0..0.0
    //                               child: Container(
    //                                 color: AppColors.primaryFocus,
    //                                 child: Stack(
    //                                   children: [
    //                                     Positioned(
    //                                       left: 8,
    //                                       bottom: 0,
    //                                       top: 0,
    //                                       child: Column(
    //                                         mainAxisSize: MainAxisSize.max,
    //                                         mainAxisAlignment: MainAxisAlignment.center,
    //                                         children: [
    //                                           Flexible(
    //                                             child: FittedBox(
    //                                               fit: BoxFit.scaleDown,
    //                                               child: Text(
    //                                                 '$timeLeftInSeconds',
    //                                                 style: theme.textTheme.labelLarge
    //                                                     ?.copyWith(color: AppColors.whiteSwatch),
    //                                               ),
    //                                             ),
    //                                           ),
    //                                         ],
    //                                       ),
    //                                     )
    //                                   ],
    //                                 ),
    //                               ),
    //                             ),
    //                           );
    //                         },
    //                       ),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           ),
    //           const Spacer(),
    //           Container(
    //             height: tabletAndAboveCTAHeight / 1.5,
    //             padding: const EdgeInsets.symmetric(
    //               horizontal: AppSpacing.tinyMargin,
    //             ),
    //             child: Center(
    //               child: Text(
    //                 "${answers.fold(0, (int previousValue, element) => previousValue + element.points < 0 ? 0 : previousValue + element.points)}",
    //                 style: theme.textTheme.displayMedium?.copyWith(height: 1),
    //               ),
    //             ),
    //           ),
    //           AppSpacing.elementMarginBox,
    //           SvgPicture.asset(
    //             AppIcons.diamondIconPath,
    //             width: tabletAndAboveCTAHeight / 2,
    //             height: tabletAndAboveCTAHeight / 2,
    //             colorFilter: const ColorFilter.mode(
    //               AppColors.primaryFocus,
    //               BlendMode.srcIn,
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //     AppSpacing.sectionMarginBox,
    //     Expanded(
    //       flex: 4,
    //       child: Center(
    //         child: Container(
    //           constraints: const BoxConstraints(
    //             maxWidth: 534 + 795 - 111,
    //             minHeight: 400,
    //             maxHeight: 534,
    //           ),
    //           child: Stack(
    //             children: [
    //               LayoutBuilder(builder: (context, bigConstraints) {
    //                 return Row(
    //                   children: [
    //                     Expanded(
    //                       child: Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         mainAxisAlignment: MainAxisAlignment.start,
    //                         mainAxisSize: MainAxisSize.max,
    //                         children: [
    //                           Text(
    //                             "Question ${currentQuestionIndex + 1}/${quiz.questionResponses.length}",
    //                             style: theme.textTheme.labelLarge,
    //                           ),
    //                           AppSpacing.groupMarginBox,
    //                           Expanded(
    //                             child: Container(
    //                               constraints: BoxConstraints(
    //                                 minWidth: bigConstraints.maxWidth,
    //                                 minHeight: bigConstraints.maxWidth / 1.618,
    //                                 maxWidth: bigConstraints.maxWidth,
    //                                 maxHeight: bigConstraints.maxWidth,
    //                               ),
    //                               decoration: const BoxDecoration(
    //                                 color: AppColors.primaryDefault,
    //                                 borderRadius: AppRadius.borderRadius20,
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     AppSpacing.sectionMarginBox,
    //                     Expanded(
    //                       child: LayoutBuilder(builder: (context, constraints) {
    //                         return Column(
    //                           crossAxisAlignment: CrossAxisAlignment.start,
    //                           mainAxisAlignment: MainAxisAlignment.center,
    //                           mainAxisSize: MainAxisSize.max,
    //                           children: [
    //                             AppSpacing.groupMarginBox,
    //                             AutoSizeText(
    //                               currentQuestion?.question.text ?? '',
    //                               style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600),
    //                               maxLines: 3,
    //                               textAlign: TextAlign.center,
    //                             ),
    //                             AppSpacing.sectionMarginBox,
    //                             Container(
    //                               constraints: BoxConstraints(
    //                                 maxWidth: constraints.maxWidth,
    //                                 maxHeight: constraints.maxWidth / (1.618 * 1.25),
    //                               ),
    //                               child: LayoutBuilder(builder: (context, constraints) {
    //                                 return Wrap(
    //                                   spacing: AppSpacing.elementMargin,
    //                                   runSpacing: AppSpacing.elementMargin,
    //                                   children: List.generate(4, (index) {
    //                                     return GestureDetector(
    //                                       onTap: () {
    //                                         if (locked) return;
    //                                         if (displayCorrectIndex != -1) {
    //                                           // already showing correct answer, do nothing
    //                                           return;
    //                                         }
    //                                         if (showVerificationState != index) {
    //                                           showVerificationState = index;
    //                                           setState(() {});
    //                                         } else {}
    //                                       },
    //                                       onDoubleTap: () {
    //                                         if (locked) return;
    //                                         showVerificationState = index;
    //                                         showCorrectAnswer();
    //                                       },
    //                                       child: Card(
    //                                         elevation: 2,
    //                                         shadowColor: AppColors.borderMedium,
    //                                         margin: EdgeInsetsGeometry.zero,
    //                                         shape: const RoundedRectangleBorder(
    //                                           borderRadius: AppRadius.borderRadius20,
    //                                         ),
    //                                         child: Stack(
    //                                           children: [
    //                                             _card(constraints, index, theme, type: "normal"),
    //                                             if (showVerificationState == index && displayCorrectIndex == -1) ...[
    //                                               Positioned.fill(
    //                                                 child: Container(
    //                                                   decoration: BoxDecoration(
    //                                                     color: AppColors.backgroundCard.withValues(alpha: .65),
    //                                                     borderRadius: AppRadius.borderRadius20,
    //                                                   ),
    //                                                 ),
    //                                               ),
    //                                               Positioned.fill(
    //                                                 child: LayoutBuilder(builder: (context, constraints) {
    //                                                   return Container(
    //                                                     decoration: BoxDecoration(
    //                                                       color: AppColors.primaryFocus.withValues(alpha: .15),
    //                                                       borderRadius: AppRadius.borderRadius20,
    //                                                       border: Border.all(
    //                                                         color: AppColors.primaryFocus,
    //                                                         width: 2,
    //                                                       ),
    //                                                     ),
    //                                                     child: Center(
    //                                                       child: Padding(
    //                                                         padding: EdgeInsets.only(top: constraints.maxHeight / 3),
    //                                                         child: AppXButton(
    //                                                           onPressed: () {
    //                                                             showCorrectAnswer();
    //                                                           },
    //                                                           isLoading: false,
    //                                                           text: "Vérifier",
    //                                                         ),
    //                                                       ),
    //                                                     ),
    //                                                   );
    //                                                 }),
    //                                               ),
    //                                             ],
    //                                             if (displayCorrectIndex != -1) ...[
    //                                               Positioned.fill(
    //                                                 child: Container(
    //                                                   decoration: const BoxDecoration(
    //                                                     color: Colors.transparent,
    //                                                     borderRadius: AppRadius.borderRadius20,
    //                                                   ),
    //                                                 ),
    //                                               ),
    //                                               if (displayCorrectIndex == index)
    //                                                 _card(constraints, index, theme, type: "correct"),
    //                                               if (displayCorrectIndex != index && showVerificationState == index)
    //                                                 _card(constraints, index, theme, type: "error"),
    //                                             ]
    //                                           ],
    //                                         ),
    //                                       ),
    //                                     );
    //                                   }),
    //                                 );
    //                               }),
    //                             )
    //                           ],
    //                         );
    //                       }),
    //                     )
    //                   ],
    //                 );
    //               }),
    //               if (currentQuestion == null)
    //                 Positioned.fill(
    //                   child: Container(
    //                     color: Colors.transparent,
    //                   ),
    //                 ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ),
    //     const Spacer(),
    //     AppSpacing.pageMarginBox,
    //     SizedBox(height: MediaQuery.of(context).padding.bottom),
    //   ],
    // );
  }

  void moveToNextQuestion() {
    currentQuestionIndex++;
    if (currentQuestionIndex >= quiz.questionResponses.length) {
      currentQuestionIndex;
      // Quiz is over
      final theme = Theme.of(context);
      final localizations = AppLocalizations.of(context)!;

      context.read<QuizBloc>().add(SaveQuizResults(
            jobId: jobId,
            quizId: quiz.id!,
            questions: quiz.questionResponses.map((e) => e.question).toList(),
            responses: answers,
            context: context,
          ));

      displayPopUp(
        context: context,
        okText: localizations.quiz_see_my_space,
        // okEnabled: quizLoaded,
        contentAlignment: Alignment.center,
        contents: [
          SvgPicture.asset(
            AppIcons.popupIconPath,
          ),
          AppSpacing.containerInsideMarginBox,
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              localizations.quiz_completed_title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: theme.textTheme.displayMedium?.fontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          AppSpacing.groupMarginBox,
          Text(
            localizations.quiz_completed_subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.containerInsideMarginBox,
          Text(
            localizations.quiz_completed_description,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          AppSpacing.containerInsideMarginBox,
          _todayPerformanceWidget(),
          AppSpacing.containerInsideMarginBox,
          _todayRewardsWidget(),
          AppSpacing.sectionMarginBox,
        ],
      ).then((value) {
        if (!mounted) return;
        navigateToPath(context, to: AppRoutes.landing);
      });

      // navigateToPath(context, to: AppRoutes.jobDetails.replaceFirst(':id', jobId));
      return;
    }
    currentQuestion = quiz.questionResponses[currentQuestionIndex];
    _countdown?.removeStatusListener(_listener);
    // _countdown?.dispose();
    _countdown = AnimationController(vsync: this, duration: currentQuestion?.question.timeLimit ?? _total);
    _countdown?.addStatusListener(_listener);
    displayCorrectIndex = -1;
    showVerificationState = -1;
    indexToRotate = -1;
    locked = false;
    setState(() {});
    // restartTimer();
  }

  void _listener(status) {
    if (status == AnimationStatus.dismissed) {
      // time's up — move to next question, show dialog, etc.
      showCorrectAnswer();
    }
  }

  void showCorrectAnswer() {
    final correctIndex = currentQuestion?.correctResponseIndex ?? -1;
    final bool isCorrect = (showVerificationState != -1 && showVerificationState == correctIndex);
    displayCorrectIndex = currentQuestion?.correctResponseIndex ?? -1;
    indexToRotate = displayCorrectIndex;
    pauseTimer();
    locked = true;
    setState(() {});

    if (isCorrect) {
      HapticFeedback.lightImpact(); // petit feeling console
      _playConfetti();
    }

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      answers.add(currentQuestion!.toQuizResponse(
            selectedResponseIndex: showVerificationState,
            timeLeftInSeconds: timeLeftInSeconds,
          ) ??
          QuizResponse.empty());
      if (answers.last.isCorrect) {
        pointsPerQuestion.add((currentQuestion?.question.points ?? 0) + timeLeftInSeconds);
      } else {
        pointsPerQuestion.add(0);
      }
      setState(() {});
      moveToNextQuestion();
    });
  }

  _card(BoxConstraints constraints, int index, ThemeData theme, {required String type}) {
    if (index == indexToRotate) {
      log("Rotating index: $indexToRotate");
    }
    return Container(
      height: constraints.maxHeight / 2 - AppSpacing.elementMargin / 2,
      width: constraints.maxWidth / 2 - AppSpacing.elementMargin / 2,
      decoration: BoxDecoration(
        color: type == 'normal'
            ? AppColors.backgroundCard
            : type == 'correct'
                ? AppColors.successDefault.withValues(alpha: .15)
                : AppColors.errorDefault.withValues(alpha: .15),
        border: Border.all(
          color: type == 'normal'
              ? AppColors.borderMedium
              : type == 'correct'
                  ? AppColors.successDefault
                  : AppColors.errorDefault,
          width: type == 'normal' ? 2 : 2,
        ),
        borderRadius: AppRadius.borderRadius20,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.groupMargin,
        vertical: AppSpacing.tinyTinyMargin,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: type == 'normal'
                  ? AppColors.backgroundCard
                  : type == 'correct'
                      ? AppColors.successDefault.withValues(alpha: .15)
                      : AppColors.errorDefault.withValues(alpha: .15),
              shape: BoxShape.circle,
              border: Border.all(
                color: type == 'normal'
                    ? AppColors.borderMedium
                    : type == 'correct'
                        ? AppColors.successDefault
                        : AppColors.errorDefault,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.elementMargin + AppSpacing.tinyMargin),
            child: Text(
              '${index + 1}',
              // String.fromCharCode(65 + index),
              style: theme.textTheme.labelSmall?.copyWith(
                color: type == 'normal'
                    ? AppColors.textTertiary
                    : type == 'correct'
                        ? AppColors.successDefault
                        : AppColors.errorDefault,
                height: 0.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 10,
            child: Center(
              child: AutoSizeText(
                (currentQuestion?.responses.elementAtOrNull(index)?.text ?? '\n\n\n') * 1,
                style: theme.textTheme.labelLarge,
                textAlign: TextAlign.center,
                maxLines: 8,
                minFontSize: theme.textTheme.bodySmall!.fontSize! - 2,
                maxFontSize: theme.textTheme.labelLarge!.fontSize!,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget answerCard(int index, dynamic constraints, dynamic theme) {
    return GestureDetector(
      onTap: () {
        if (locked) return;
        if (displayCorrectIndex != -1) {
          // already showing correct answer, do nothing
          return;
        }
        if (showVerificationState != index) {
          showVerificationState = index;
          setState(() {});
        } else {}
      },
      onDoubleTap: () {
        if (locked) return;
        showVerificationState = index;
        showCorrectAnswer();
      },
      child: RotationTransition(
        turns: AlwaysStoppedAnimation((index == indexToRotate ? -15 : 0) / 360),
        child: Card(
          elevation: 2,
          shadowColor: AppColors.borderMedium,
          margin: EdgeInsetsGeometry.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadius20,
          ),
          child: Stack(
            children: [
              _card(constraints, index, theme, type: "normal"),
              if (showVerificationState == index && displayCorrectIndex == -1) ...[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard.withValues(alpha: .65),
                      borderRadius: AppRadius.borderRadius20,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryFocus.withValues(alpha: .15),
                        borderRadius: AppRadius.borderRadius20,
                        border: Border.all(
                          color: AppColors.primaryFocus,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: constraints.maxHeight / 3),
                          child: AppXButton(
                            onPressed: () {
                              showCorrectAnswer();
                            },
                            isLoading: false,
                            text: "Vérifier",
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
              if (displayCorrectIndex != -1) ...[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: AppRadius.borderRadius20,
                    ),
                  ),
                ),
                if (displayCorrectIndex == index) _card(constraints, index, theme, type: "correct"),
                if (displayCorrectIndex != index && showVerificationState == index)
                  _card(constraints, index, theme, type: "error"),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _todayPerformanceWidget() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(localizations.quiz_daily_performance, style: theme.textTheme.bodyLarge),
        AppSpacing.groupMarginBox,
        Row(
          children: [
            const Spacer(flex: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${answers.whereOrEmpty((a) => a.isCorrect).length}",
                    style: theme.textTheme.displaySmall
                        ?.copyWith(color: AppColors.successDefault, fontWeight: FontWeight.bold)),
                AppSpacing.elementMarginBox,
                Text(localizations.quiz_good_answers,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary)),
              ],
            ),
            const Spacer(flex: 5),
            Container(
              color: AppColors.primaryDisabled,
              height: 50,
              width: 1,
            ),
            const Spacer(flex: 5),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("${answers.whereOrEmpty((a) => !a.isCorrect).length}",
                    style: theme.textTheme.displaySmall
                        ?.copyWith(color: AppColors.errorDefault, fontWeight: FontWeight.bold)),
                AppSpacing.elementMarginBox,
                Text(localizations.quiz_answers_to_review,
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textTertiary)),
              ],
            ),
            const Spacer(flex: 4),
          ],
        ),
      ],
    );
  }

  Widget _todayRewardsWidget() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final earnedDIAMONDS = pointsPerQuestion.fold(
        0, (int previousValue, element) => previousValue + element < 0 ? 0 : previousValue + element);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          localizations.quiz_reward,
          style: theme.textTheme.labelLarge,
        ),
        AppSpacing.groupMarginBox,
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScoreWidget(value: earnedDIAMONDS, isReward: true),
          ],
        ),
      ],
    );
  }

  double _getMaxWidthForQuestionCard(DeviceType deviceType) {
    if (deviceType == DeviceType.mobile) return 344;
    if (deviceType == DeviceType.tablet) return 644;
    return 744;
    return 534 + 795 - 111;
  }
}
