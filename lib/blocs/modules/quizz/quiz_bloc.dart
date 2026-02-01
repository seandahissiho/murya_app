import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/quiz.dart';
import 'package:murya/models/quiz_result.dart';
import 'package:murya/repositories/base.repository.dart';
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
    on<LoadQuizForJob>(_loadQuizForJob);
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
    Result<UserQuizResult?>? result;
    if (authBloc.state.isAuthenticated) {
      // Here you would typically save the quiz results to a repository or database
      // For this example, we'll just simulate a successful save operation
      result = await quizRepository.saveQuizResult(event);
      // notificationBloc.add(SuccessNotificationEvent(
      //   message: "Quiz results saved successfully!",
      // ));
    } else {
      final newEvent = TempRegisterEvent();
      await Future.delayed(const Duration(milliseconds: 100));
      authBloc.add(newEvent);
      while (!authBloc.state.isAuthenticated) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      result = await quizRepository.saveQuizResult(event);
      // notificationBloc.add(SuccessNotificationEvent(
      //   message: "Quiz results saved successfully!",
      // ));
    }
    if (result == null || result.isError) {
      notificationBloc.add(ErrorNotificationEvent(
        message: result?.error,
      ));
      emit(QuizError(message: result?.error ?? "Une erreur est survenue"));
      return;
    }
    await Future.delayed(const Duration(milliseconds: 150));
    if (event.context.mounted) {
      event.context.read<JobBloc>().add(LoadUserCurrentJob(context: event.context));
    }
    emit(QuizSaved(result: result.data));
    profileBloc.add(ProfileLoadEvent());
  }

  FutureOr<void> _loadQuizForJob(LoadQuizForJob event, Emitter<QuizState> emit) async {
    final cachedResult = await quizRepository.getQuizForJobCached(event.jobId);
    if (cachedResult.data != null) {
      emit(QuizLoaded(quiz: cachedResult.data!));
    }
    var result;
    if (authBloc.state.isAuthenticated) {
      result = await quizRepository.getQuizForJob(event.jobId);
    } else {
      final newEvent = TempRegisterEvent();
      await Future.delayed(const Duration(milliseconds: 100));
      authBloc.add(newEvent);
      while (!authBloc.state.isAuthenticated) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      result = await quizRepository.getQuizForJob(event.jobId);
    }
    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(
        message: result.error,
      ));
      emit(QuizError(message: result.error!));
      return;
    }

    emit(QuizLoaded(quiz: result.data!));
  }
}
