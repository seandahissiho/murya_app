part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {
  final User user;
  final QuestList quests;
  final QuestGroupList questGroups;
  final bool questsLoading;
  final bool questGroupsLoading;
  final String? questsError;
  final String? questGroupsError;
  final String? questUserJobId;
  final String? questTimezone;
  final QuestScope? questScope;
  final String? claimingQuestId;
  final List<LeaderBoardUser> leaderboardUsers;
  final bool leaderboardLoading;
  final String? leaderboardError;
  final String? leaderboardJobId;
  final DateTime? leaderboardFrom;
  final DateTime? leaderboardTo;
  final List<RewardItem> rewards;

  const ProfileState({
    this.user = User.zero,
    this.quests = const QuestList(),
    this.questGroups = const QuestGroupList(),
    this.questsLoading = false,
    this.questGroupsLoading = false,
    this.questsError,
    this.questGroupsError,
    this.questUserJobId,
    this.questTimezone,
    this.questScope,
    this.claimingQuestId,
    this.leaderboardUsers = const <LeaderBoardUser>[],
    this.leaderboardLoading = false,
    this.leaderboardError,
    this.leaderboardJobId,
    this.leaderboardFrom,
    this.leaderboardTo,
    this.rewards = const <RewardItem>[],
  });

  @override
  String toString() =>
      'ProfileState(user: $user, questsLoading: $questsLoading, questGroupsLoading: $questGroupsLoading)';
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {
  const ProfileLoading({
    required super.user,
    super.quests,
    super.questGroups,
    super.questsLoading,
    super.questGroupsLoading,
    super.questsError,
    super.questGroupsError,
    super.questUserJobId,
    super.questTimezone,
    super.questScope,
    super.claimingQuestId,
    super.leaderboardUsers,
    super.leaderboardLoading,
    super.leaderboardError,
    super.leaderboardJobId,
    super.leaderboardFrom,
    super.leaderboardTo,
  });

  @override
  String toString() => 'ProfileLoading(user: $user)';
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required super.user,
    super.quests,
    super.questGroups,
    super.questsLoading,
    super.questGroupsLoading,
    super.questsError,
    super.questGroupsError,
    super.questUserJobId,
    super.questTimezone,
    super.questScope,
    super.claimingQuestId,
    super.leaderboardUsers,
    super.leaderboardLoading,
    super.leaderboardError,
    super.leaderboardJobId,
    super.leaderboardFrom,
    super.leaderboardTo,
  });

  @override
  String toString() => 'ProfileLoaded(user: $user)';
}
