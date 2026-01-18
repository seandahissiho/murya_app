import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/config/app_config.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/device_id_service.dart';
import 'package:murya/repositories/app.repository.dart';
import 'package:murya/repositories/authentication.repository.dart';
import 'package:murya/repositories/jobs.repository.dart';
import 'package:murya/repositories/modules.repository.dart';
import 'package:murya/repositories/notifications.repository.dart';
import 'package:murya/repositories/profile.repository.dart';
import 'package:murya/repositories/quiz.repository.dart';
import 'package:murya/repositories/rewards.repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  late final NotificationBloc notificationBloc;
  late final AuthenticationRepository authenticationRepository;
  late final JobRepository jobRepository;
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
    jobRepository = RepositoryProvider.of<JobRepository>(context);
  }

  Future<bool> _setDefaultCurrentJob() async {
    final jobId = AppConfig.defaultJobId;
    if (jobId.isEmpty) {
      return false;
    }
    const maxAttempts = 2;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      final result = await jobRepository.setUserCurrentJob(jobId);
      if (!result.isError && result.data != null) {
        return true;
      }
      if (attempt < maxAttempts) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    return false;
  }

  FutureOr<void> _onTryAutoLogin(TryAutoLogin event, Emitter<AuthenticationState> emit) async {
    final result = await authenticationRepository.getToken();
    if (result.isError) {
      // try to login with device id
      final service = DeviceIdService();
      final deviceId = await service.getUniqueDeviceId();
      final tempResult = await authenticationRepository.signIn(
        data: {
          "deviceId": deviceId,
        },
      );
      if (tempResult.isError) {
        await _onTempRegisterEvent(TempRegisterEvent(deviceId: deviceId), emit);
        _initialized = true;
        if (_token.isEmpty) {
          await unAuthenticate(emit);
        }
        return;
      }
      _token = tempResult.data!.$1;
      // _user = tempResult.data!.$3;
      updateRepositories(tempResult.data!.$1);
      final jobSet = await _setDefaultCurrentJob();
      if (!jobSet) {
        await unAuthenticate(emit);
        return;
      }
      _initialized = true;
      emit(const Authenticated(
        // user: _user,
        justLoggedIn: true,
      ));
      return;
    }
    if (context.mounted) {
      _token = result.data!.$1;
      // _user = result.data!.$3;
      updateRepositories(result.data!.$1);
      final jobSet = await _setDefaultCurrentJob();
      if (!jobSet) {
        await unAuthenticate(emit);
        return;
      }
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
      await unAuthenticate(emit);
      return;
    }
    _token = result.data!.$1;
    // _user = result.data!.$3;
    updateRepositories(_token);
    final jobSet = await _setDefaultCurrentJob();
    if (!jobSet) {
      await unAuthenticate(emit);
      return;
    }
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
    RepositoryProvider.of<ModulesRepository>(context).updateDio(token, context);
    RepositoryProvider.of<QuizRepository>(context).updateDio(token, context);
    RepositoryProvider.of<RewardsRepository>(context).updateDio(token, context);
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

  Future<void> unAuthenticate(Emitter<AuthenticationState> emit) async {
    await authenticationRepository.deleteToken();
    if (context.mounted) {
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
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
    await unAuthenticate(emit);
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
    final jobSet = await _setDefaultCurrentJob();
    if (!jobSet) {
      await unAuthenticate(emit);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
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
      await unAuthenticate(emit);
      return;
    }
    _token = result.data!.$1;
    // _user = result.data!.$3;
    updateRepositories(_token);
    final jobSet = await _setDefaultCurrentJob();
    if (!jobSet) {
      await unAuthenticate(emit);
      return;
    }
    notificationBloc.add(SuccessNotificationEvent(message: 'Inscription réussie.'));
    emit(const Authenticated(justLoggedIn: true));
  }
}
