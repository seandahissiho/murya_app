part of 'job_evaluation.dart';

class MobileJobEvaluationScreen extends StatefulWidget {
  const MobileJobEvaluationScreen({super.key});

  @override
  State<MobileJobEvaluationScreen> createState() => _MobileJobEvaluationScreenState();
}

class _MobileJobEvaluationScreenState extends State<MobileJobEvaluationScreen> with SingleTickerProviderStateMixin {
  late final String jobId;
  late final Quizz quizz;
  QuestionResponses? currentQuestion;
  int currentQuestionIndex = -1;
  bool initialized = false;

  // Adjust to whatever per-question time you need.
  static const _total = Duration(seconds: 30);

  AnimationController? _countdown;

  int get timeLeftInSeconds {
    return ((_countdown?.duration!.inSeconds ?? 0) * (_countdown?.value ?? 0)).ceil();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      jobId = beamState.pathParameters['id'];
      quizz = Quizz.fromJson(TEST_QUIZZ);
      moveToNextQuestion();
      initialized = true;
      setState(() {});
    });
    // pauseTimer();
  }

  @override
  void dispose() {
    _countdown?.dispose();
    super.dispose();
  }

  void pauseTimer() => _countdown?.stop();

  void resumeTimer() => _countdown?.reverse(from: _countdown?.value);

  void restartTimer() => _countdown?.reverse(from: 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!initialized) {
      return const SizedBox.shrink();
    }
    return Column(
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
                  width: 32,
                  height: 32,
                ),
              ),
              AppSpacing.elementMarginBox,
              Expanded(
                child: SizedBox(
                  height: 8,
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
                                    // child: Row(
                                    //   mainAxisSize: MainAxisSize.max,
                                    //   mainAxisAlignment: MainAxisAlignment.start,
                                    //   crossAxisAlignment: CrossAxisAlignment.start,
                                    //   children: [
                                    //     Center(
                                    //       child: Text(
                                    //         "$timeLeftInSeconds",
                                    //         style: theme.textTheme.labelSmall?.copyWith(
                                    //           color: AppColors.whiteSwatch,
                                    //           height: 0,
                                    //         ),
                                    //         textAlign: TextAlign.center,
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
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
              AppSpacing.elementMarginBox,
              Container(
                height: 21,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.tinyMargin,
                ),
                child: Center(
                  child: Text(
                    "1",
                    style: theme.textTheme.labelLarge?.copyWith(height: 0),
                  ),
                ),
              ),
              AppSpacing.elementMarginBox,
              SvgPicture.asset(
                AppIcons.diamondIconPath,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryFocus,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.groupMarginBox,
        Expanded(
          child: LayoutBuilder(builder: (context, bigConstraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  "Question ${currentQuestionIndex + 1}/${quizz.questionResponses.length}",
                  style: theme.textTheme.labelMedium,
                ),
                AppSpacing.tinyMarginBox,
                const Spacer(),
                Expanded(
                  flex: 18,
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: bigConstraints.maxWidth,
                      minHeight: bigConstraints.maxWidth / 1.618,
                      maxWidth: bigConstraints.maxWidth,
                      maxHeight: bigConstraints.maxWidth,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDefault,
                      borderRadius: AppRadius.borderRadius20,
                    ),
                  ),
                ),
                AppSpacing.tinyMarginBox,
                const Spacer(),
                AutoSizeText(
                  currentQuestion?.question.text ?? '',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.tinyMarginBox,
                const Spacer(),
                Expanded(
                  flex: 15,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Wrap(
                      spacing: AppSpacing.elementMargin,
                      runSpacing: AppSpacing.elementMargin,
                      children: List.generate(4, (index) {
                        return Container(
                          height: constraints.maxHeight / 2 - AppSpacing.elementMargin / 2,
                          width: constraints.maxWidth / 2 - AppSpacing.elementMargin / 2,
                          color: Colors.accents.getRandomElement(),
                        );
                      }),
                    );
                  }),
                )
              ],
            );
          }),
        ),
        AppSpacing.pageMarginBox,
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  void moveToNextQuestion() {
    currentQuestionIndex++;
    if (currentQuestionIndex >= quizz.questionResponses.length) {
      // Quizz is over
      navigateToPath(context, to: AppRoutes.landing);
      // navigateToPath(context, to: AppRoutes.jobEvaluationResults.replaceFirst(':id', jobId));
      return;
    }
    currentQuestion = quizz.questionResponses[currentQuestionIndex];
    _countdown?.removeStatusListener(_listener);
    // _countdown?.dispose();
    _countdown = AnimationController(vsync: this, duration: currentQuestion?.question.timeLimit ?? _total);
    _countdown?.addStatusListener(_listener);
    restartTimer();
  }

  void _listener(status) {
    if (status == AnimationStatus.dismissed) {
      // time's up — move to next question, show dialog, etc.
      moveToNextQuestion();
    }
  }
}
