import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/analytics/analytics_events.dart';
import 'package:murya/analytics/analytics_service.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/modules/resources/resources_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/localization/locale_controller.dart';
import 'package:murya/models/country.dart';
import 'package:murya/models/quest.dart';
import 'package:murya/repositories/app.repository.dart';
import 'package:murya/repositories/authentication.repository.dart';
import 'package:murya/repositories/jobs.repository.dart';
import 'package:murya/repositories/modules.repository.dart';
import 'package:murya/repositories/notifications.repository.dart';
import 'package:murya/repositories/profile.repository.dart';
import 'package:murya/repositories/quiz.repository.dart';
import 'package:murya/repositories/resources.repository.dart';
import 'package:murya/repositories/rewards.repository.dart';
import 'package:murya/repositories/search.repository.dart';
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
  AppLanguage _appLanguage = AppLanguage.english;

  EdgeInsets get safeAreaPadding => _safeAreaPadding;

  AppLanguage get appLanguage => _appLanguage;

  AppBloc({required BuildContext context})
      : super(const AppRouteChanged(newRoute: AppRoutes.landing)) {
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

  FutureOr<void> _onInitialize(
      AppInitialize event, Emitter<AppState> emit) async {
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

  FutureOr<void> _onChangeNavBarState(
      AppChangeNavBarState event, Emitter<AppState> emit) {
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

  FutureOr<void> _onChangeLanguage(
      AppChangeLanguage event, Emitter<AppState> emit) {
    final previousLanguageCode = state.language.code;
    _appLanguage = event.language;

    _updateRepositoriesLanguage(event.context, _appLanguage.code);
    AnalyticsService.instance.updateLanguage(_appLanguage.code);

    if (previousLanguageCode != _appLanguage.code) {
      unawaited(
        AnalyticsService.instance.captureUi(
          AnalyticsEventNames.languageChanged,
          properties: {
            'lang': _appLanguage.code,
            'previous_lang': previousLanguageCode,
          },
        ),
      );
    }

    if (event.persistPreferredLanguage) {
      unawaited(
        RepositoryProvider.of<ProfileRepository>(event.context)
            .updatePreferredLanguage(_appLanguage.code),
      );
    }

    final context = event.context;

    // UserJob & Search
    context.read<JobBloc>().add(LoadUserCurrentJob(context: context));
    context.read<JobBloc>().add(SearchJobs(query: '', context: context));

    context
        .read<ProfileBloc>()
        .add(ProfileLoadQuestGroupsEvent(scope: QuestScope.all));

    // // Data depending on UserJob
    final userJob = context.read<JobBloc>().state.userCurrentJob;
    final userJobId = userJob?.id;

    if (userJobId != null) {
      context.read<ResourcesBloc>().add(LoadResources(userJobId: userJobId));
      //   context.read<QuestsBloc>().add(
      //       QuestsLoadLineageEvent(scope: QuestScope.all, userJobId: userJobId));
    }

    // Modules
    context.read<ModulesBloc>().add(LoadCatalogModules(force: true));
    context.read<ModulesBloc>().add(LoadLandingModules(force: true));

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
    final savedLocale = localeProvider.locale;
    final resolvedLanguage = savedLocale?.languageCode == 'fr'
        ? AppLanguage.french
        : AppLanguage.english;

    _appLanguage = resolvedLanguage;
    _updateRepositoriesLanguage(context, _appLanguage.code);
    AnalyticsService.instance.updateLanguage(_appLanguage.code);

    if (!context.mounted) return;
    if (state.language.code != resolvedLanguage.code) {
      add(AppChangeLanguage(
        language: resolvedLanguage,
        context: context,
        persistPreferredLanguage: false,
      ));
    }
  }

  void _updateRepositoriesLanguage(BuildContext context, String languageCode) {
    RepositoryProvider.of<AuthenticationRepository>(context)
        .updateLanguage(languageCode);
    RepositoryProvider.of<NotificationRepository>(context)
        .updateLanguage(languageCode);
    RepositoryProvider.of<ProfileRepository>(context)
        .updateLanguage(languageCode);
    RepositoryProvider.of<JobRepository>(context).updateLanguage(languageCode);
    RepositoryProvider.of<ModulesRepository>(context)
        .updateLanguage(languageCode);
    RepositoryProvider.of<RewardsRepository>(context)
        .updateLanguage(languageCode);
    RepositoryProvider.of<AppRepository>(context).updateLanguage(languageCode);
    RepositoryProvider.of<QuizRepository>(context).updateLanguage(languageCode);
    RepositoryProvider.of<ResourcesRepository>(context)
        .updateLanguage(languageCode);
    RepositoryProvider.of<SearchRepository>(context)
        .updateLanguage(languageCode);
  }
}
