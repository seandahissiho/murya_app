part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

final class ProfileLoadEvent extends ProfileEvent {
  final String? userId;
  final bool notifyIfNotFound;

  ProfileLoadEvent({this.userId, this.notifyIfNotFound = true});
}

final class ProfileUpdateEvent extends ProfileEvent {
  final User user;

  ProfileUpdateEvent({required this.user});
}

final class ProfileDeleteEvent extends ProfileEvent {
  final String userId;

  ProfileDeleteEvent({required this.userId});
}
