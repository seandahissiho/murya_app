part of 'quiz_bloc.dart';

@immutable
sealed class QuizState {}

final class QuizInitial extends QuizState {}

final class QuizLoading extends QuizState {}

final class QuizLoaded extends QuizState {
  final Quiz quiz;

  QuizLoaded({required this.quiz});
}

final class QuizError extends QuizState {
  final String message;

  QuizError({required this.message});
}

final class QuizCompleted extends QuizState {
  final int score;
  final int totalQuestions;

  QuizCompleted({required this.score, required this.totalQuestions});
}

final class QuizSaving extends QuizState {}

final class QuizSaved extends QuizState {}
