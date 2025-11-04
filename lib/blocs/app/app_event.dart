part of 'app_bloc.dart';

@immutable
sealed class AppEvent {}

class AppInitialize extends AppEvent {}

class AppChangeNavBarState extends AppEvent {}

class AppChangeRoute extends AppEvent {
  final String nextRoute;
  final String currentRoute;

  AppChangeRoute({
    required this.nextRoute,
    required this.currentRoute,
  });
}

class AppChangeLanguage extends AppEvent {
  final AppLanguage language;
  final BuildContext context;

  AppChangeLanguage({
    required this.language,
    required this.context,
  });
}
