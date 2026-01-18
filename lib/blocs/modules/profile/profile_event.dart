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

final class ProfileLoadQuestsEvent extends ProfileEvent {
  final QuestScope scope;
  final String? userJobId;
  final String? timezone;
  final bool notifyOnError;

  ProfileLoadQuestsEvent({
    required this.scope,
    this.userJobId,
    this.timezone,
    this.notifyOnError = true,
  });
}

final class ProfileLoadQuestGroupsEvent extends ProfileEvent {
  final QuestScope scope;
  final String? userJobId;
  final String? timezone;
  final bool notifyOnError;

  ProfileLoadQuestGroupsEvent({
    required this.scope,
    this.userJobId,
    this.timezone,
    this.notifyOnError = true,
  });
}

final class ProfileLoadQuestLineageEvent extends ProfileEvent {
  final QuestScope scope;
  final String? userJobId;
  final String? timezone;
  final bool notifyOnError;

  ProfileLoadQuestLineageEvent({
    required this.scope,
    this.userJobId,
    this.timezone,
    this.notifyOnError = true,
  });
}

enum QuestClaimType { user, userJob }

final class ProfileClaimQuestEvent extends ProfileEvent {
  final String questId;
  final QuestClaimType claimType;
  final bool notifyOnError;

  ProfileClaimQuestEvent({
    required this.questId,
    required this.claimType,
    this.notifyOnError = true,
  });
}

final class ProfileLoadLeaderboardEvent extends ProfileEvent {
  final String jobId;
  final DateTime? from;
  final DateTime? to;
  final bool notifyOnError;

  ProfileLoadLeaderboardEvent({
    required this.jobId,
    this.from,
    this.to,
    this.notifyOnError = true,
  });
}
