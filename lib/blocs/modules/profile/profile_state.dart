part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {
  final User user;

  const ProfileState({this.user = User.zero});

  @override
  String toString() => 'ProfileState(user: $user)';
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {
  const ProfileLoading({required super.user});

  @override
  String toString() => 'ProfileLoading(user: $user)';
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required super.user});

  @override
  String toString() => 'ProfileLoaded(user: $user)';
}
