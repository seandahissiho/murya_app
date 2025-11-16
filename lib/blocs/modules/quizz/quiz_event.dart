part of 'quiz_bloc.dart';

@immutable
sealed class QuizEvent {}

final class LoadQuizForJob extends QuizEvent {
  final String jobId;

  LoadQuizForJob({required this.jobId});
}

final class StartQuiz extends QuizEvent {
  final String quizId;

  StartQuiz({required this.quizId});
}

final class SubmitAnswer extends QuizEvent {
  final String questionId;
  final String answer;

  SubmitAnswer({required this.questionId, required this.answer});
}

final class SaveQuizResults extends QuizEvent {
  final String jobId;
  final String quizId;
  final List<QuizQuestion> questions;
  final List<QuizResponse> responses;
  final BuildContext context;

  SaveQuizResults({
    required this.jobId,
    required this.quizId,
    required this.questions,
    required this.responses,
    required this.context,
  });

  //type AnswerInput = {
  //     questionId: string;
  //     freeTextAnswer?: string;
  //     responseIds?: string[]; // ids de QuizResponse sélectionnées
  // };
  List<Map<String, dynamic>> get dbResponses {
    return responses
        .whereOrEmpty((response) => response.id.isNotEmptyOrNull && response.questionId.isNotEmptyOrNull)
        .map((response) {
      final int availableTime = questions
              .whereOrEmpty((question) => question.id.isNotEmptyOrNull)
              .firstWhereOrNull((question) => question.id == response.questionId)
              ?.timeLimitInSeconds ??
          0;
      final int timeToAnswer = availableTime - response.timeLeftAfterAnswer;
      return {
        'questionId': response.questionId,
        // if (response.freeTextAnswer != null) 'freeTextAnswer': response.freeTextAnswer,
        'responseIds': response.id.isNotEmptyOrNull ? [response.id] : [],
        'timeToAnswer': timeToAnswer,
      };
    }).toList();
  }
}
