part of 'app_bloc.dart';

@immutable
sealed class AppState {
  final bool isLoading;
  final bool showNavBar;
  final String? oldRoute;
  final String newRoute;
  final AppLanguage language;

  const AppState({
    this.isLoading = false,
    this.showNavBar = true,
    this.oldRoute,
    this.newRoute = AppRoutes.landing,
    this.language = AppLanguage.english,
  });
}

final class AppInitial extends AppState {
  const AppInitial({
    super.isLoading,
    super.showNavBar,
    super.oldRoute,
    super.newRoute = AppRoutes.landing,
    super.language,
  });

  @override
  String toString() =>
      'AppInitial(isLoading: $isLoading, showNavBar: $showNavBar, oldRoute: $oldRoute, newRoute: $newRoute, language: ${language.code})';
}

final class AppLoading extends AppState {
  const AppLoading({
    super.isLoading = true,
    super.showNavBar = true,
    required super.oldRoute,
    required super.newRoute,
    required super.language,
  });

  @override
  String toString() =>
      'AppLoading(isLoading: $isLoading, showNavBar: $showNavBar, oldRoute: $oldRoute, newRoute: $newRoute)';
}

final class AppLoaded extends AppState {
  const AppLoaded({
    super.isLoading = false,
    super.showNavBar = true,
    required super.oldRoute,
    required super.newRoute,
    required super.language,
  });

  @override
  String toString() =>
      'AppLoaded(isLoading: $isLoading, showNavBar: $showNavBar, oldRoute: $oldRoute, newRoute: $newRoute)';
}

final class AppError extends AppState {
  final String message;

  const AppError({
    this.message = 'An error occurred',
    super.isLoading = false,
    super.showNavBar = true,
    required super.oldRoute,
    required super.newRoute,
    required super.language,
  });

  @override
  String toString() =>
      'AppError(message: $message, isLoading: $isLoading, showNavBar: $showNavBar, oldRoute: $oldRoute, newRoute: $newRoute)';
}

final class AppNoInternet extends AppState {
  const AppNoInternet({
    super.isLoading = false,
    super.showNavBar = true,
    required super.oldRoute,
    required super.newRoute,
    required super.language,
  });

  @override
  String toString() =>
      'AppNoInternet(isLoading: $isLoading, showNavBar: $showNavBar, oldRoute: $oldRoute, newRoute: $newRoute)';
}

final class AppUnauthorized extends AppState {
  const AppUnauthorized({
    super.isLoading = false,
    super.showNavBar = true,
    required super.oldRoute,
    required super.newRoute,
    required super.language,
  });

  @override
  String toString() =>
      'AppUnauthorized(isLoading: $isLoading, showNavBar: $showNavBar, oldRoute: $oldRoute, newRoute: $newRoute)';
}

final class AppRouteChanged extends AppState {
  const AppRouteChanged({
    super.oldRoute,
    required super.newRoute,
    super.isLoading = false,
    super.showNavBar = true,
    super.language,
  });

  @override
  String toString() =>
      'AppRouteChanged(currentRoute: $oldRoute, nextRoute: $newRoute, isLoading: $isLoading, showNavBar: $showNavBar)';
}
