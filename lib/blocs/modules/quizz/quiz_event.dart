part of 'quiz_bloc.dart';

@immutable
sealed class QuizEvent {}

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
  final String quizId;
  final List<QuizResponse> responses;

  SaveQuizResults({required this.quizId, required this.responses});
}
