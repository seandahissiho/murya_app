part of 'profile_bloc.dart';

enum ProfileStateKind { initial, loading, loaded }

@immutable
sealed class ProfileState {
  static const Object _noValue = Object();

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
  final PreviewCompetencyProfile? previewCompetencyProfile;
  final bool previewCompetencyProfileLoading;
  final String? previewCompetencyProfileError;
  final String? previewCompetencyUserJobId;
  final DateTime? previewCompetencyFrom;
  final DateTime? previewCompetencyTo;
  final String? previewCompetencyTimezone;
  final bool previewCompetencyRequested;

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
    this.previewCompetencyProfile,
    this.previewCompetencyProfileLoading = false,
    this.previewCompetencyProfileError,
    this.previewCompetencyUserJobId,
    this.previewCompetencyFrom,
    this.previewCompetencyTo,
    this.previewCompetencyTimezone,
    this.previewCompetencyRequested = false,
  });

  @override
  String toString() =>
      'ProfileState(user: $user, questsLoading: $questsLoading, questGroupsLoading: $questGroupsLoading)';

  ProfileStateKind get _kind {
    if (this is ProfileLoading) return ProfileStateKind.loading;
    if (this is ProfileLoaded) return ProfileStateKind.loaded;
    return ProfileStateKind.initial;
  }

  ProfileState copyWith({
    ProfileStateKind? kind,
    User? user,
    QuestList? quests,
    QuestGroupList? questGroups,
    bool? questsLoading,
    bool? questGroupsLoading,
    Object? questsError = _noValue,
    Object? questGroupsError = _noValue,
    Object? questUserJobId = _noValue,
    Object? questTimezone = _noValue,
    Object? questScope = _noValue,
    Object? claimingQuestId = _noValue,
    List<LeaderBoardUser>? leaderboardUsers,
    bool? leaderboardLoading,
    Object? leaderboardError = _noValue,
    Object? leaderboardJobId = _noValue,
    Object? leaderboardFrom = _noValue,
    Object? leaderboardTo = _noValue,
    List<RewardItem>? rewards,
    PreviewCompetencyProfile? previewCompetencyProfile,
    bool? previewCompetencyProfileLoading,
    Object? previewCompetencyProfileError = _noValue,
    Object? previewCompetencyUserJobId = _noValue,
    Object? previewCompetencyFrom = _noValue,
    Object? previewCompetencyTo = _noValue,
    Object? previewCompetencyTimezone = _noValue,
    bool? previewCompetencyRequested,
  }) {
    final resolvedKind = kind ?? _kind;
    final resolvedUser = user ?? this.user;
    final resolvedQuests = quests ?? this.quests;
    final resolvedQuestGroups = questGroups ?? this.questGroups;
    final resolvedQuestsLoading = questsLoading ?? this.questsLoading;
    final resolvedQuestGroupsLoading = questGroupsLoading ?? this.questGroupsLoading;
    final resolvedQuestsError =
        identical(questsError, _noValue) ? this.questsError : questsError as String?;
    final resolvedQuestGroupsError =
        identical(questGroupsError, _noValue) ? this.questGroupsError : questGroupsError as String?;
    final resolvedQuestUserJobId =
        identical(questUserJobId, _noValue) ? this.questUserJobId : questUserJobId as String?;
    final resolvedQuestTimezone =
        identical(questTimezone, _noValue) ? this.questTimezone : questTimezone as String?;
    final resolvedQuestScope =
        identical(questScope, _noValue) ? this.questScope : questScope as QuestScope?;
    final resolvedClaimingQuestId =
        identical(claimingQuestId, _noValue) ? this.claimingQuestId : claimingQuestId as String?;
    final resolvedLeaderboardUsers = leaderboardUsers ?? this.leaderboardUsers;
    final resolvedLeaderboardLoading = leaderboardLoading ?? this.leaderboardLoading;
    final resolvedLeaderboardError =
        identical(leaderboardError, _noValue) ? this.leaderboardError : leaderboardError as String?;
    final resolvedLeaderboardJobId =
        identical(leaderboardJobId, _noValue) ? this.leaderboardJobId : leaderboardJobId as String?;
    final resolvedLeaderboardFrom =
        identical(leaderboardFrom, _noValue) ? this.leaderboardFrom : leaderboardFrom as DateTime?;
    final resolvedLeaderboardTo =
        identical(leaderboardTo, _noValue) ? this.leaderboardTo : leaderboardTo as DateTime?;
    final resolvedRewards = rewards ?? this.rewards;
    final resolvedPreviewCompetencyProfile =
        previewCompetencyProfile ?? this.previewCompetencyProfile;
    final resolvedPreviewCompetencyProfileLoading =
        previewCompetencyProfileLoading ?? this.previewCompetencyProfileLoading;
    final resolvedPreviewCompetencyProfileError = identical(
            previewCompetencyProfileError, _noValue)
        ? this.previewCompetencyProfileError
        : previewCompetencyProfileError as String?;
    final resolvedPreviewCompetencyUserJobId = identical(
            previewCompetencyUserJobId, _noValue)
        ? this.previewCompetencyUserJobId
        : previewCompetencyUserJobId as String?;
    final resolvedPreviewCompetencyFrom =
        identical(previewCompetencyFrom, _noValue)
            ? this.previewCompetencyFrom
            : previewCompetencyFrom as DateTime?;
    final resolvedPreviewCompetencyTo =
        identical(previewCompetencyTo, _noValue)
            ? this.previewCompetencyTo
            : previewCompetencyTo as DateTime?;
    final resolvedPreviewCompetencyTimezone = identical(
            previewCompetencyTimezone, _noValue)
        ? this.previewCompetencyTimezone
        : previewCompetencyTimezone as String?;
    final resolvedPreviewCompetencyRequested =
        previewCompetencyRequested ?? this.previewCompetencyRequested;

    switch (resolvedKind) {
      case ProfileStateKind.initial:
        return ProfileInitial(
          user: resolvedUser,
          quests: resolvedQuests,
          questGroups: resolvedQuestGroups,
          questsLoading: resolvedQuestsLoading,
          questGroupsLoading: resolvedQuestGroupsLoading,
          questsError: resolvedQuestsError,
          questGroupsError: resolvedQuestGroupsError,
          questUserJobId: resolvedQuestUserJobId,
          questTimezone: resolvedQuestTimezone,
          questScope: resolvedQuestScope,
          claimingQuestId: resolvedClaimingQuestId,
          leaderboardUsers: resolvedLeaderboardUsers,
          leaderboardLoading: resolvedLeaderboardLoading,
          leaderboardError: resolvedLeaderboardError,
          leaderboardJobId: resolvedLeaderboardJobId,
          leaderboardFrom: resolvedLeaderboardFrom,
          leaderboardTo: resolvedLeaderboardTo,
          rewards: resolvedRewards,
          previewCompetencyProfile: resolvedPreviewCompetencyProfile,
          previewCompetencyProfileLoading: resolvedPreviewCompetencyProfileLoading,
          previewCompetencyProfileError: resolvedPreviewCompetencyProfileError,
          previewCompetencyUserJobId: resolvedPreviewCompetencyUserJobId,
          previewCompetencyFrom: resolvedPreviewCompetencyFrom,
          previewCompetencyTo: resolvedPreviewCompetencyTo,
          previewCompetencyTimezone: resolvedPreviewCompetencyTimezone,
          previewCompetencyRequested: resolvedPreviewCompetencyRequested,
        );
      case ProfileStateKind.loading:
        return ProfileLoading(
          user: resolvedUser,
          quests: resolvedQuests,
          questGroups: resolvedQuestGroups,
          questsLoading: resolvedQuestsLoading,
          questGroupsLoading: resolvedQuestGroupsLoading,
          questsError: resolvedQuestsError,
          questGroupsError: resolvedQuestGroupsError,
          questUserJobId: resolvedQuestUserJobId,
          questTimezone: resolvedQuestTimezone,
          questScope: resolvedQuestScope,
          claimingQuestId: resolvedClaimingQuestId,
          leaderboardUsers: resolvedLeaderboardUsers,
          leaderboardLoading: resolvedLeaderboardLoading,
          leaderboardError: resolvedLeaderboardError,
          leaderboardJobId: resolvedLeaderboardJobId,
          leaderboardFrom: resolvedLeaderboardFrom,
          leaderboardTo: resolvedLeaderboardTo,
          rewards: resolvedRewards,
          previewCompetencyProfile: resolvedPreviewCompetencyProfile,
          previewCompetencyProfileLoading: resolvedPreviewCompetencyProfileLoading,
          previewCompetencyProfileError: resolvedPreviewCompetencyProfileError,
          previewCompetencyUserJobId: resolvedPreviewCompetencyUserJobId,
          previewCompetencyFrom: resolvedPreviewCompetencyFrom,
          previewCompetencyTo: resolvedPreviewCompetencyTo,
          previewCompetencyTimezone: resolvedPreviewCompetencyTimezone,
          previewCompetencyRequested: resolvedPreviewCompetencyRequested,
        );
      case ProfileStateKind.loaded:
        return ProfileLoaded(
          user: resolvedUser,
          quests: resolvedQuests,
          questGroups: resolvedQuestGroups,
          questsLoading: resolvedQuestsLoading,
          questGroupsLoading: resolvedQuestGroupsLoading,
          questsError: resolvedQuestsError,
          questGroupsError: resolvedQuestGroupsError,
          questUserJobId: resolvedQuestUserJobId,
          questTimezone: resolvedQuestTimezone,
          questScope: resolvedQuestScope,
          claimingQuestId: resolvedClaimingQuestId,
          leaderboardUsers: resolvedLeaderboardUsers,
          leaderboardLoading: resolvedLeaderboardLoading,
          leaderboardError: resolvedLeaderboardError,
          leaderboardJobId: resolvedLeaderboardJobId,
          leaderboardFrom: resolvedLeaderboardFrom,
          leaderboardTo: resolvedLeaderboardTo,
          rewards: resolvedRewards,
          previewCompetencyProfile: resolvedPreviewCompetencyProfile,
          previewCompetencyProfileLoading: resolvedPreviewCompetencyProfileLoading,
          previewCompetencyProfileError: resolvedPreviewCompetencyProfileError,
          previewCompetencyUserJobId: resolvedPreviewCompetencyUserJobId,
          previewCompetencyFrom: resolvedPreviewCompetencyFrom,
          previewCompetencyTo: resolvedPreviewCompetencyTo,
          previewCompetencyTimezone: resolvedPreviewCompetencyTimezone,
          previewCompetencyRequested: resolvedPreviewCompetencyRequested,
        );
    }
  }
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial({
    super.user,
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
    super.rewards,
    super.previewCompetencyProfile,
    super.previewCompetencyProfileLoading,
    super.previewCompetencyProfileError,
    super.previewCompetencyUserJobId,
    super.previewCompetencyFrom,
    super.previewCompetencyTo,
    super.previewCompetencyTimezone,
    super.previewCompetencyRequested,
  });
}

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
    super.rewards,
    super.previewCompetencyProfile,
    super.previewCompetencyProfileLoading,
    super.previewCompetencyProfileError,
    super.previewCompetencyUserJobId,
    super.previewCompetencyFrom,
    super.previewCompetencyTo,
    super.previewCompetencyTimezone,
    super.previewCompetencyRequested,
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
    super.rewards,
    super.previewCompetencyProfile,
    super.previewCompetencyProfileLoading,
    super.previewCompetencyProfileError,
    super.previewCompetencyUserJobId,
    super.previewCompetencyFrom,
    super.previewCompetencyTo,
    super.previewCompetencyTimezone,
    super.previewCompetencyRequested,
  });

  @override
  String toString() => 'ProfileLoaded(user: $user)';
}
