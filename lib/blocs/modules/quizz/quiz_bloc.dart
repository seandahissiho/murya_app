import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/models/quiz.dart';
import 'package:murya/repositories/quiz.repository.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  late final NotificationBloc notificationBloc;
  late final AuthenticationBloc authBloc;
  late final ProfileBloc profileBloc;
  late final StreamSubscription<ProfileState> _profileSubscription;
  late final QuizRepository quizRepository;

  QuizBloc({required BuildContext context}) : super(QuizInitial()) {
    on<QuizEvent>((event, emit) {
      emit(QuizLoading());
    });
    on<SaveQuizResults>(_onSaveQuizResults);

    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    authBloc = BlocProvider.of<AuthenticationBloc>(context);
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    quizRepository = RepositoryProvider.of<QuizRepository>(context);

    _profileSubscription = profileBloc.stream.listen((state) {
      if (state is ProfileLoaded) {}
    });
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    return super.close();
  }

  Future<void> _onSaveQuizResults(SaveQuizResults event, Emitter<QuizState> emit) async {
    if (authBloc.state.isAuthenticated) {
      // Here you would typically save the quiz results to a repository or database
      // For this example, we'll just simulate a successful save operation
      final result = await quizRepository.saveQuizResult(event);
      notificationBloc.add(SuccessNotificationEvent(
        message: "Quiz results saved successfully!",
      ));
    } else {
      final newEvent = TempRegisterEvent();
      await Future.delayed(const Duration(milliseconds: 100));
      authBloc.add(newEvent);
      while (!authBloc.state.isAuthenticated) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      final result = await quizRepository.saveQuizResult(event);
      notificationBloc.add(ErrorNotificationEvent(
        message: "You were not logged in. A temporary account was created to save your quiz results.",
      ));
    }
    emit(QuizSaved());
  }
}
