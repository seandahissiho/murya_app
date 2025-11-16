part of 'job_evaluation.dart';

class MobileJobEvaluationScreen extends StatefulWidget {
  const MobileJobEvaluationScreen({super.key});

  @override
  State<MobileJobEvaluationScreen> createState() => _MobileJobEvaluationScreenState();
}

class _MobileJobEvaluationScreenState extends State<MobileJobEvaluationScreen> with TickerProviderStateMixin {
  late final String jobId;
  late final Quiz quiz;
  QuestionResponses? currentQuestion;
  int currentQuestionIndex = -1;
  bool initialized = false;
  final List<QuizResponse> answers = [];

  // Adjust to whatever per-question time you need.
  static const _total = Duration(seconds: 30);

  AnimationController? _countdown;

  int showVerificationState = -1;

  int displayCorrectIndex = -1;

  bool locked = true;

  int get timeLeftInSeconds {
    return ((_countdown?.duration!.inSeconds ?? 0) * (_countdown?.value ?? 0)).ceil();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dynamic beamState = Beamer.of(context).currentBeamLocation.state;
      jobId = beamState.pathParameters['id'];
      context.read<QuizBloc>().add(LoadQuizForJob(jobId: jobId));
      // quiz = Quiz.fromJson(TEST_QUIZ);
      // initialized = true;
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
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizLoaded) {
          quiz = state.quiz;
          initialized = true;
          currentQuestionIndex = -1;
          Future.delayed(const Duration(seconds: 1), () {
            moveToNextQuestion();
          });
        }
        if (state is QuizSaved) {
          navigateToPath(context, to: AppRoutes.landing);
        }
        setState(() {});
      },
      builder: (context, state) {
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
                  ScoreWidget(
                    value: answers.fold(
                        0,
                        (int previousValue, element) =>
                            previousValue + element.points < 0 ? 0 : previousValue + element.points),
                  ),
                ],
              ),
            ),
            AppSpacing.groupMarginBox,
            Expanded(
              child: Stack(
                children: [
                  LayoutBuilder(builder: (context, bigConstraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          "Question ${currentQuestionIndex + 1 > quiz.questionResponses.length ? quiz.questionResponses.length : currentQuestionIndex + 1}/${quiz.questionResponses.length}",
                          style: theme.textTheme.labelMedium,
                        ),
                        AppSpacing.tinyMarginBox,
                        const Spacer(),
                        Expanded(
                          flex: 15,
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
                          style: theme.textTheme.labelLarge,
                          maxLines: 3,
                          textAlign: TextAlign.center,
                        ),
                        AppSpacing.tinyMarginBox,
                        const Spacer(),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: bigConstraints.maxWidth,
                            maxHeight: bigConstraints.maxWidth / 1.325,
                          ),
                          child: LayoutBuilder(builder: (context, constraints) {
                            return Wrap(
                              spacing: AppSpacing.elementMargin,
                              runSpacing: AppSpacing.elementMargin,
                              children: List.generate(4, (index) {
                                return answerCard(index, constraints, theme);
                              }),
                            );
                          }),
                        )
                      ],
                    );
                  }),
                  if (currentQuestion == null)
                    Positioned.fill(
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                ],
              ),
            ),
            AppSpacing.pageMarginBox,
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        );
      },
    );
  }

  void moveToNextQuestion() {
    currentQuestionIndex++;
    if (currentQuestionIndex >= quiz.questionResponses.length) {
      currentQuestionIndex;
      // Quiz is over
      context.read<QuizBloc>().add(SaveQuizResults(
            jobId: jobId,
            quizId: quiz.id!,
            questions: quiz.questionResponses.map((e) => e.question).toList(),
            responses: answers,
            context: context,
          ));
      // navigateToPath(context, to: AppRoutes.landing);
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
    locked = false;
    setState(() {});
    restartTimer();
  }

  void _listener(status) {
    if (status == AnimationStatus.dismissed) {
      // time's up — move to next question, show dialog, etc.
      showCorrectAnswer();
    }
  }

  void showCorrectAnswer() {
    displayCorrectIndex = currentQuestion?.correctResponseIndex ?? -1;
    pauseTimer();
    locked = true;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 25), () {
      if (!mounted) return;
      answers.add(currentQuestion!.toQuizResponse(
            selectedResponseIndex: 0, // showVerificationState,
            timeLeftInSeconds: 30, // timeLeftInSeconds,
          ) ??
          QuizResponse.empty());
      moveToNextQuestion();
    });
  }

  _card(dynamic constraints, int index, dynamic theme, {required String type}) {
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
          AppSpacing.tinyTinyMarginBox,
          Expanded(
            child: Center(
              child: AutoSizeText(
                (currentQuestion?.responses.elementAtOrNull(index)?.text ?? '\n\n\n'),
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 4,
                minFontSize: theme.textTheme.bodySmall!.fontSize! - 2,
                maxFontSize: theme.textTheme.bodyMedium!.fontSize!,
              ),
            ),
          ),
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
    );
  }
}
