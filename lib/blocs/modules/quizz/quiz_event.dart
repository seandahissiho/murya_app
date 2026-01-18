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
    final Map<String, QuizResponse> responseByQuestionId = {
      for (final response in responses.whereOrEmpty((response) => response.questionId.isNotEmptyOrNull))
        response.questionId: response,
    };

    return questions.whereOrEmpty((question) => question.id.isNotEmptyOrNull).map((question) {
      final QuizResponse? response = responseByQuestionId[question.id];
      final int availableTime = question.timeLimitInSeconds;
      final int timeLeft = response?.timeLeftAfterAnswer ?? 0;
      final int timeToAnswer = (availableTime - timeLeft).clamp(0, availableTime).toInt();

      final Map<String, dynamic> payload = {
        'questionId': question.id,
        'timeToAnswer': timeToAnswer,
      };

      if (question.type == QuizQuestionType.short_answer || question.type == QuizQuestionType.fill_in_the_blank) {
        payload['freeTextAnswer'] = response?.freeTextAnswer ?? '';
      } else {
        payload['responseIds'] = response?.id.isNotEmptyOrNull == true ? [response!.id] : <String>[];
      }

      return payload;
    }).toList();
  }
}
