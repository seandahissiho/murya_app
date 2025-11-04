import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/localization/locale_controller.dart';
import 'package:murya/models/country.dart';
import 'package:murya/repositories/app.repository.dart';
import 'package:murya/repositories/authentication.repository.dart';
import 'package:murya/repositories/jobs.repository.dart';
import 'package:murya/repositories/notifications.repository.dart';
import 'package:murya/repositories/profile.repository.dart';
import 'package:provider/provider.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppForex {
  final String? result;
  final String? documentation;
  final String? termsOfUse;
  final int? timeLastUpdateUnix;
  final String? timeLastUpdateUtc;
  final int? timeNextUpdateUnix;
  final String? timeNextUpdateUtc;
  final String? baseCode;
  final Map<String, double>? conversionRates;

  AppForex({
    this.result,
    this.documentation,
    this.termsOfUse,
    this.timeLastUpdateUnix,
    this.timeLastUpdateUtc,
    this.timeNextUpdateUnix,
    this.timeNextUpdateUtc,
    this.baseCode,
    this.conversionRates,
  });

  double toUSD(double amount) {
    return 0;
  }

  double toEUR(double amount) {
    return 0;
  }

  double eurToxof(double eurPrice) {
    if (baseCode != 'XOF') {
      return 0.0;
    }
    if (conversionRates == null || !conversionRates!.containsKey('EUR')) {
      return 0.0;
    }
    final rate = conversionRates!['EUR']!;
    return eurPrice / rate;
  }
}

class AppBloc extends Bloc<AppEvent, AppState> {
  String? oldRoute;
  String? newRoute;
  late final AppRepository appRepository;
  EdgeInsets _safeAreaPadding = EdgeInsets.zero;
  AppLanguage _appLanguage = AppLanguage.french;

  EdgeInsets get safeAreaPadding => _safeAreaPadding;

  AppLanguage get appLanguage => _appLanguage;

  AppBloc({required BuildContext context}) : super(const AppRouteChanged(newRoute: AppRoutes.home)) {
    on<AppEvent>((event, emit) {
      emit(AppLoading(
        isLoading: true,
        showNavBar: state.showNavBar,
        oldRoute: state.oldRoute,
        newRoute: state.newRoute,
        language: state.language,
      ));
    });
    on<AppInitialize>(_onInitialize);
    on<AppChangeNavBarState>(_onChangeNavBarState);
    on<AppChangeRoute>(_onChangeRoute);
    on<AppChangeLanguage>(_onChangeLanguage);

    appRepository = RepositoryProvider.of<AppRepository>(context);
  }

  FutureOr<void> _onInitialize(AppInitialize event, Emitter<AppState> emit) async {
    emit(AppInitial(
      showNavBar: true,
      oldRoute: state.oldRoute,
      newRoute: state.newRoute,
      language: state.language,
    ));

    emit(AppLoaded(
      isLoading: false,
      showNavBar: state.showNavBar,
      oldRoute: state.oldRoute,
      newRoute: state.newRoute,
      language: state.language,
    ));
  }

  FutureOr<void> _onChangeNavBarState(AppChangeNavBarState event, Emitter<AppState> emit) {
    emit(AppInitial(
      showNavBar: !state.showNavBar,
      oldRoute: state.oldRoute,
      newRoute: state.newRoute,
      language: state.language,
    ));
    print('AppBloc: NavBar state changed to ${!state.showNavBar}');
    emit(AppLoaded(
      isLoading: false,
      showNavBar: state.showNavBar,
      oldRoute: state.oldRoute,
      newRoute: state.newRoute,
      language: state.language,
    ));
  }

  FutureOr<void> _onChangeRoute(AppChangeRoute event, Emitter<AppState> emit) {
    oldRoute = event.currentRoute;
    newRoute = event.nextRoute;
    emit(AppRouteChanged(
      oldRoute: event.currentRoute,
      newRoute: event.nextRoute,
      language: state.language,
    ));
  }

  FutureOr<void> _onChangeLanguage(AppChangeLanguage event, Emitter<AppState> emit) {
    _appLanguage = event.language;

    RepositoryProvider.of<AuthenticationRepository>(event.context).updateLanguage(_appLanguage.code);
    RepositoryProvider.of<NotificationRepository>(event.context).updateLanguage(_appLanguage.code);
    RepositoryProvider.of<ProfileRepository>(event.context).updateLanguage(_appLanguage.code);
    // jobs repository
    RepositoryProvider.of<JobRepository>(event.context).updateLanguage(_appLanguage.code);

    emit(AppRouteChanged(
      oldRoute: state.oldRoute,
      newRoute: state.newRoute,
      language: event.language,
    ));
  }

  void reset() {
    oldRoute = null;
    newRoute = null;
    add(AppInitialize());
  }

  void updateScreenSafeAreaPadding(BuildContext context) {
    _safeAreaPadding = MediaQuery.of(context).padding;
  }

  Future<void> smt(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.load();
    _appLanguage = AppLanguage(
      code: localeProvider.locale?.languageCode == 'fr' ? 'fr' : 'en',
      name: localeProvider.locale?.languageCode == 'fr' ? 'Français' : 'English',
    );
    add(AppChangeLanguage(
      language: _appLanguage,
      context: context,
    ));
  }
}
