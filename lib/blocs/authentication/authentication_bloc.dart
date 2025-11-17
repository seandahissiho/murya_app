import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/device_id_service.dart';
import 'package:murya/repositories/app.repository.dart';
import 'package:murya/repositories/authentication.repository.dart';
import 'package:murya/repositories/jobs.repository.dart';
import 'package:murya/repositories/notifications.repository.dart';
import 'package:murya/repositories/profile.repository.dart';
import 'package:murya/repositories/quiz.repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  late final NotificationBloc notificationBloc;
  late final AuthenticationRepository authenticationRepository;
  Timer? timer;
  BuildContext context;

  String _token = "";

  User _user = User.empty();
  bool _initialized = false;

  User get user => _user;
  bool get initialized => _initialized;

  AuthenticationBloc({required this.context}) : super(AuthenticationInitial()) {
    on<AuthenticationEvent>((event, emit) {
      emit(AuthenticationLoading(
        isAuthenticated: state.isAuthenticated,
        // user: state.user,
      ));
    });
    on<AuthInitialize>((event, emit) async {
      await Future.delayed(const Duration(milliseconds: 1000));
      add(TryAutoLogin(justLoggedIn: true));
      // await Future.delayed(const Duration(seconds: 2));
      // AppUserRole role = AppUserRole.admin; // FAKER.randomGenerator.element(AppUserRole.values);
      // AppUserDepartment department = departmentFromRole(role);
      // _user = AppUser(
      //   id: FAKER.guid.guid(),
      //   email: FAKER.internet.email(),
      //   firstName: FAKER.person.firstName(),
      //   lastName: FAKER.person.lastName(),
      //   phoneNumber: FAKER.phoneNumber.us(),
      //   role: role,
      //   department: department,
      // );
      // if (context.mounted) {
      //   _updateRepositories(context: context);
      // }
      // emit(Authenticated(user: _user, justLoggedIn: true));
      // // Handle initialization logic_onTryAutoLogint(Authenticated(justLoggedIn: true, user: _user));
    });
    on<TryAutoLogin>(_onTryAutoLogin);
    on<RegisterEvent>(_onRegisterEvent);
    on<SignInEvent>(_onSignInEvent);
    on<SignOutEvent>(_onSignOutEvent);
    on<TempRegisterEvent>(_onTempRegisterEvent);

    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    authenticationRepository = RepositoryProvider.of<AuthenticationRepository>(context);
  }

  FutureOr<void> _onTryAutoLogin(TryAutoLogin event, Emitter<AuthenticationState> emit) async {
    final result = await authenticationRepository.getToken();
    if (result.isError) {
      if (result.error?.isNotEmpty ?? false) {
        notificationBloc.add(InfoNotificationEvent(
          message: result.error ?? "Session expirée, veuillez vous reconnecter",
        ));
      }
      _initialized = true;
      unAuthenticate(emit);
      return;
    }
    if (context.mounted) {
      _token = result.data!.$1;
      // _user = result.data!.$3;
      updateRepositories(result.data!.$1);
      _initialized = true;
      emit(Authenticated(
        // user: _user,
        justLoggedIn: event.justLoggedIn,
      ));
    }
  }

  FutureOr<void> _onSignInEvent(SignInEvent event, Emitter<AuthenticationState> emit) async {
    final result = await authenticationRepository.signIn(
      data: event.toJson(),
    );
    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(
        message: result.error,
      ));
      unAuthenticate(emit);
      return;
    }
    _token = result.data!.$1;
    // _user = result.data!.$3;
    updateRepositories(_token);
    notificationBloc.add(SuccessNotificationEvent(message: 'Connexion réussie.'));
    emit(const Authenticated(
      // user: _user,
      justLoggedIn: true,
    ));
  }

  void updateRepositories(String token) {
    _updateRepositories(context: context, token: token);
    if (timer != null) {
      return;
    }
    timer = Timer.periodic(
      const Duration(hours: 1),
      (timer) async {
        final result = await authenticationRepository.getToken();
        if (result.isError) {
          timer.cancel();
          return;
        }
        if (context.mounted) {
          _token = result.data!.$1;
          // _user = result.data!.$3;
          _updateRepositories(context: context, token: result.data!.$1);
        }
      },
    );
  }

  void _updateRepositories({
    required BuildContext context,
    String token = "",
    dontOverride = false,
  }) {
    if (token.isEmpty && !dontOverride) {
      token = _token;
    }

    RepositoryProvider.of<AppRepository>(context).updateDio(token, context);
    RepositoryProvider.of<AuthenticationRepository>(context).updateDio(token, context);
    RepositoryProvider.of<NotificationRepository>(context).updateDio(token, context);
    RepositoryProvider.of<ProfileRepository>(context).updateDio(token, context);
    RepositoryProvider.of<JobRepository>(context).updateDio(token, context);
    RepositoryProvider.of<QuizRepository>(context).updateDio(token, context);
  }

  void updateRepositoriesContext(BuildContext context) {
    this.context = context;
    _updateRepositories(context: context);
  }

  _resetAllBlocs(BuildContext context) {
    _updateRepositories(
      context: context,
      dontOverride: true, // Don't override the token here, as we are resetting
    );

    // Reset all blocs to their initial state
    // App
    BlocProvider.of<AppBloc>(context).reset();
    // Authentication
    BlocProvider.of<AuthenticationBloc>(context).reset();
    // Notifications
    BlocProvider.of<NotificationBloc>(context).reset();
  }

  void reset() {
    _token = "";
    // _user = User.empty();
    _initialized = false;
    timer?.cancel();
    timer = null;
  }

  void unAuthenticate(Emitter<AuthenticationState> emit) {
    authenticationRepository.clearTokens();
    if (context.mounted) {
      // pop until first context
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      // context.read<AppBloc>().add(
      //       AppChangeRoute(
      //         currentRoute: AppRoutes.landing,
      //         nextRoute: AppRoutes.landing,
      //       ),
      //     );
      // Beamer.of(context).beamToNamed(AppRoutes.landing);
    }
    if (context.mounted) {
      _resetAllBlocs(context);
    }
    emit(const Unauthenticated());
  }

  FutureOr<void> _onSignOutEvent(SignOutEvent event, Emitter<AuthenticationState> emit) async {
    final result = await authenticationRepository.signOut();
    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(
        message: result.error,
      ));
      return;
    }
    notificationBloc.add(SuccessNotificationEvent(message: 'Déconnexion réussie.'));
    unAuthenticate(emit);
  }

  FutureOr<void> _onTempRegisterEvent(TempRegisterEvent event, Emitter<AuthenticationState> emit) async {
    final result = await authenticationRepository.registerTemp(
      data: event.toJson(),
    );
    if (result.isError) {
      // notificationBloc.add(ErrorNotificationEvent(
      //   message: result.error,
      // ));
      return;
    }
    _token = result.data!.$1;
    // _user = result.data!.$3;
    updateRepositories(_token);
    // notificationBloc.add(SuccessNotificationEvent(message: 'Connexion réussie.'));
    emit(const Authenticated(justLoggedIn: false));
  }

  FutureOr<void> _onRegisterEvent(RegisterEvent event, Emitter<AuthenticationState> emit) async {
    final result = await authenticationRepository.register(
      data: event.toJson(),
    );
    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(
        message: result.error,
      ));
      unAuthenticate(emit);
      return;
    }
    _token = result.data!.$1;
    // _user = result.data!.$3;
    updateRepositories(_token);
    notificationBloc.add(SuccessNotificationEvent(message: 'Inscription réussie.'));
    emit(const Authenticated(justLoggedIn: true));
  }
}
