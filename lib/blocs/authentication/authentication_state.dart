part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState {
  final bool isAuthenticated;

  // final User user;

  const AuthenticationState({
    this.isAuthenticated = false,
    // this.user = User.zero,
  });

  @override
  String toString() => 'AuthenticationState(isAuthenticated: $isAuthenticated)';
}

final class AuthenticationInitial extends AuthenticationState {}

final class Authenticated extends AuthenticationState {
  final bool justLoggedIn;

  const Authenticated({
    this.justLoggedIn = false,
    // required super.user,
  }) : super(isAuthenticated: true);

  @override
  String toString() => 'AuthenticatedState(isAuthenticated: $isAuthenticated)';
}

final class Unauthenticated extends AuthenticationState {
  final bool goToLandingPage;

  const Unauthenticated({this.goToLandingPage = false}) : super(isAuthenticated: false);

  @override
  String toString() => 'UnauthenticatedState(isAuthenticated: $isAuthenticated, goToLandingPage: $goToLandingPage)';
}

final class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading({
    required super.isAuthenticated,
    // required super.user,
  });

  @override
  String toString() => 'AuthenticationLoading(isAuthenticated: $isAuthenticated)';
}
