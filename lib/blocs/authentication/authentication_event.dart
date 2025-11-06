part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}

final class AuthInitialize extends AuthenticationEvent {
  AuthInitialize();
}

final class AuthenticatedEvent extends AuthenticationEvent {
  final User user;
  final bool justLoggedIn;

  AuthenticatedEvent({required this.user, this.justLoggedIn = false});
}

final class TryAutoLogin extends AuthenticationEvent {
  final bool justLoggedIn;

  TryAutoLogin({this.justLoggedIn = false});
}

final class SignInEvent extends AuthenticationEvent {
  final String email;
  final String password;

  SignInEvent({required this.email, required this.password});

  toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

final class SignOutEvent extends AuthenticationEvent {
  SignOutEvent();
}
