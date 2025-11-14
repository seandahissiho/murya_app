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
  final List<QuizResponse> responses;

  SaveQuizResults({
    required this.jobId,
    required this.quizId,
    required this.responses,
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
      return {
        'questionId': response.questionId,
        // if (response.freeTextAnswer != null) 'freeTextAnswer': response.freeTextAnswer,
        'responseIds': [response.id],
      };
    }).toList();
  }
}
