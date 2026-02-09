import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/job_ranking.dart';
import 'package:murya/models/preview_competency_profile.dart';
import 'package:murya/models/quest.dart';
import 'package:murya/models/reward.dart';
import 'package:murya/repositories/jobs.repository.dart';
import 'package:murya/repositories/profile.repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final BuildContext context;
  User _userProfile = User.empty();
  late final ProfileRepository profileRepository;
  late final JobRepository jobRepository;
  late final NotificationBloc notificationBloc;
  late final AuthenticationBloc authBloc;
  late final StreamSubscription<AuthenticationState> _authSubscription;

  User get user => _userProfile;

  QuestList? get quests => state.quests;

  QuestGroupList? get questGroups => state.questGroups;

  ProfileBloc({required this.context}) : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) {
      emit(state.copyWith(kind: ProfileStateKind.loading));
    });
    on<ProfileLoadEvent>(_onProfileLoadEvent);
    on<ProfileUpdateEvent>(_onProfileUpdateEvent);
    on<ProfileLoadQuestsEvent>(_onProfileLoadQuestsEvent);
    on<ProfileLoadQuestGroupsEvent>(_onProfileLoadQuestGroupsEvent);
    on<ProfileClaimQuestEvent>(_onProfileClaimQuestEvent);
    on<ProfileLoadLeaderboardEvent>(_onProfileLoadLeaderboardEvent);
    on<OpenProfilPreview>(_onOpenProfilePreview);

    profileRepository = RepositoryProvider.of<ProfileRepository>(context);
    jobRepository = RepositoryProvider.of<JobRepository>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    authBloc = BlocProvider.of<AuthenticationBloc>(context);
    _authSubscription = authBloc.stream.listen((state) {
      if (state is Authenticated) {
        add(ProfileLoadEvent());
      }
    });
  }

  FutureOr<void> _onProfileLoadEvent(ProfileLoadEvent event, Emitter<ProfileState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    // Attempt to load from cache
    final cachedResult = await profileRepository.getMeCached();
    if (cachedResult.data != null && (cachedResult.data!.id?.isNotEmpty ?? false)) {
      _userProfile = cachedResult.data!;
      emit(state.copyWith(kind: ProfileStateKind.loaded, user: _userProfile));
    }

    if (!context.mounted) return;

    final result = await profileRepository.getMe();
    if (result.isError && event.notifyIfNotFound) {
      notificationBloc.add(ErrorNotificationEvent(
        message: result.error,
      ));
      authBloc.add(SignOutEvent());
      return;
    }
    _userProfile = result.data!;
    emit(state.copyWith(kind: ProfileStateKind.loaded, user: _userProfile));
    add(ProfileLoadQuestGroupsEvent(scope: QuestScope.all));
  }

  FutureOr<void> _onProfileLoadQuestsEvent(ProfileLoadQuestsEvent event, Emitter<ProfileState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(state.copyWith(
      kind: ProfileStateKind.loading,
      questsLoading: true,
      questsError: null,
      questUserJobId: event.userJobId,
      questTimezone: event.timezone,
      questScope: event.scope,
    ));

    final cachedResult = await profileRepository.getQuestsCached(
      scope: event.scope,
      timezone: event.timezone,
      userJobId: event.userJobId,
    );
    final cachedQuests = cachedResult.data;
    final hasCachedQuests = cachedQuests != null &&
        (cachedQuests.main != null ||
            cachedQuests.branches.isNotEmpty ||
            cachedQuests.others.isNotEmpty ||
            cachedQuests.groups.isNotEmpty);
    if (hasCachedQuests) {
      emit(state.copyWith(
        kind: ProfileStateKind.loaded,
        quests: cachedQuests,
        questsLoading: false,
        questsError: null,
        questUserJobId: event.userJobId,
        questTimezone: event.timezone,
        questScope: event.scope,
      ));
    }

    final result = await profileRepository.getQuests(
      scope: event.scope,
      timezone: event.timezone,
      userJobId: event.userJobId,
    );

    if (result.isError) {
      if (event.notifyOnError) {
        notificationBloc.add(ErrorNotificationEvent(message: result.error));
      }
      emit(state.copyWith(
        kind: ProfileStateKind.loaded,
        questsLoading: false,
        questsError: result.error,
        questUserJobId: event.userJobId,
        questTimezone: event.timezone,
        questScope: event.scope,
      ));
      return;
    }

    emit(state.copyWith(
      kind: ProfileStateKind.loaded,
      quests: result.data ?? const QuestList(),
      questsLoading: false,
      questsError: null,
      questUserJobId: event.userJobId,
      questTimezone: event.timezone,
      questScope: event.scope,
    ));
  }

  FutureOr<void> _onProfileLoadQuestGroupsEvent(ProfileLoadQuestGroupsEvent event, Emitter<ProfileState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(state.copyWith(
      kind: ProfileStateKind.loading,
      questGroupsLoading: true,
      questGroupsError: null,
      questUserJobId: event.userJobId,
      questTimezone: event.timezone,
      questScope: event.scope,
    ));

    final cachedResult = await profileRepository.getQuestGroupsCached(
      scope: event.scope,
      timezone: event.timezone,
      userJobId: event.userJobId,
    );
    final cachedGroups = cachedResult.data;
    final hasCachedGroups = cachedGroups != null && cachedGroups.groups.isNotEmpty;
    if (hasCachedGroups) {
      emit(state.copyWith(
        kind: ProfileStateKind.loaded,
        questGroups: cachedGroups,
        questGroupsLoading: false,
        questGroupsError: null,
        questUserJobId: event.userJobId,
        questTimezone: event.timezone,
        questScope: event.scope,
      ));
    }

    final result = await profileRepository.getQuestGroups(
      scope: event.scope,
      timezone: event.timezone,
      userJobId: event.userJobId,
    );

    if (result.isError) {
      if (event.notifyOnError) {
        notificationBloc.add(ErrorNotificationEvent(message: result.error));
      }
      emit(state.copyWith(
        kind: ProfileStateKind.loaded,
        questGroupsLoading: false,
        questGroupsError: result.error,
        questUserJobId: event.userJobId,
        questTimezone: event.timezone,
        questScope: event.scope,
      ));
      return;
    }

    emit(state.copyWith(
      kind: ProfileStateKind.loaded,
      questGroups: result.data ?? const QuestGroupList(),
      questGroupsLoading: false,
      questGroupsError: null,
      questUserJobId: event.userJobId,
      questTimezone: event.timezone,
      questScope: event.scope,
    ));
  }

  List<LeaderBoardUser> _mapLeaderboardUsers(JobRankings ranking) {
    final users = ranking.rankings.map((ranking) {
      final String firstName = ranking.firstName ?? ranking.firstname ?? '';
      final String lastName = ranking.lastName ?? ranking.lastname ?? '';
      return LeaderBoardUser(
        id: ranking.userId,
        userJobId: ranking.userJobId,
        firstName: firstName,
        lastName: lastName,
        profilePictureUrl: ranking.profilePictureUrl,
        diamonds: ranking.diamonds,
        questionsAnswered: ranking.questionsAnswered,
        performance: ranking.performance,
        sinceDate: ranking.sinceDate,
        rank: ranking.rank,
        percentage: ranking.percentage,
        completedQuizzes: ranking.completedQuizzes,
        lastQuizAt: ranking.lastQuizAt,
      );
    }).toList();
    users.sort((a, b) => a.rank.compareTo(b.rank));
    // retrieve current user and put them at the top
    final currentUserIndex = users.indexWhere((user) => user.id == _userProfile.id);
    if (currentUserIndex != -1) {
      final currentUser = users.removeAt(currentUserIndex);
      users.insert(0, currentUser);
    }
    return users;
  }

  FutureOr<void> _onProfileLoadLeaderboardEvent(ProfileLoadLeaderboardEvent event, Emitter<ProfileState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    if (event.jobId.isEmpty) return;

    emit(state.copyWith(
      kind: ProfileStateKind.loading,
      leaderboardLoading: true,
      leaderboardError: null,
      leaderboardJobId: event.jobId,
      leaderboardFrom: event.from,
      leaderboardTo: event.to,
    ));

    final cachedResult = await jobRepository.getRankingForJobCached(event.jobId, event.from, event.to);
    if (cachedResult.data != null) {
      emit(state.copyWith(
        kind: ProfileStateKind.loaded,
        leaderboardUsers: _mapLeaderboardUsers(cachedResult.data ?? JobRankings.empty()),
        leaderboardLoading: false,
        leaderboardError: null,
        leaderboardJobId: event.jobId,
        leaderboardFrom: event.from,
        leaderboardTo: event.to,
      ));
    }

    if (!context.mounted) return;

    final result = await jobRepository.getRankingForJob(event.jobId, event.from, event.to);
    if (result.isError) {
      if (event.notifyOnError) {
        notificationBloc.add(ErrorNotificationEvent(message: result.error));
      }
      emit(state.copyWith(
        kind: ProfileStateKind.loaded,
        leaderboardLoading: false,
        leaderboardError: result.error,
        leaderboardJobId: event.jobId,
        leaderboardFrom: event.from,
        leaderboardTo: event.to,
      ));
      return;
    }

    emit(state.copyWith(
      kind: ProfileStateKind.loaded,
      leaderboardUsers: _mapLeaderboardUsers(result.data ?? JobRankings.empty()),
      leaderboardLoading: false,
      leaderboardError: null,
      leaderboardJobId: event.jobId,
      leaderboardFrom: event.from,
      leaderboardTo: event.to,
    ));
  }

  FutureOr<void> _onProfileClaimQuestEvent(ProfileClaimQuestEvent event, Emitter<ProfileState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }

    emit(state.copyWith(
      kind: ProfileStateKind.loading,
      claimingQuestId: event.questId,
    ));

    final result = event.claimType == QuestClaimType.userJob
        ? await profileRepository.claimUserJobQuest(event.questId)
        : await profileRepository.claimUserQuest(event.questId);

    if (result.isError) {
      if (event.notifyOnError) {
        notificationBloc.add(ErrorNotificationEvent(message: result.error));
      }
      emit(state.copyWith(
        kind: ProfileStateKind.loaded,
        claimingQuestId: null,
      ));
      return;
    }

    final QuestInstance updated = result.data ?? QuestInstance.empty();
    final QuestList? updatedQuests = state.quests?.updateInstance(updated);
    final QuestGroupList? updatedGroups = state.questGroups?.updateInstance(updated);

    emit(state.copyWith(
      kind: ProfileStateKind.loaded,
      quests: updatedQuests ?? state.quests,
      questGroups: updatedGroups ?? state.questGroups,
      claimingQuestId: null,
    ));
  }

  FutureOr<void> _onProfileUpdateEvent(ProfileUpdateEvent event, Emitter<ProfileState> emit) async {
    final User previousUser = state.user;
    _userProfile = event.user;
    emit(state.copyWith(kind: ProfileStateKind.loaded, user: _userProfile));

    final result = await profileRepository.updateMe(event.user, baseline: previousUser);
    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(message: result.error));
      return;
    }
    _userProfile = result.data!;
    emit(state.copyWith(kind: ProfileStateKind.loaded, user: _userProfile));
  }

  FutureOr<void> _onOpenProfilePreview(OpenProfilPreview event, Emitter<ProfileState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    if (event.userJobId.isEmpty) return;

    emit(state.copyWith(
      kind: ProfileStateKind.loading,
      previewCompetencyProfileLoading: true,
      previewCompetencyProfileError: null,
      previewCompetencyUserJobId: event.userJobId,
      previewCompetencyFrom: event.from,
      previewCompetencyTo: event.to,
      previewCompetencyTimezone: event.timezone,
      previewCompetencyRequested: true,
    ));

    final cachedResult = await jobRepository.fetchPreviewCompetencyProfileCached(
      event.userJobId,
      from: event.from,
      to: event.to,
      timezone: event.timezone,
    );
    final cachedProfile = cachedResult.data;
    if (cachedProfile != null && cachedProfile.userJobId.isNotEmpty) {
      emit(state.copyWith(
        kind: ProfileStateKind.loaded,
        previewCompetencyProfile: cachedProfile,
        previewCompetencyProfileLoading: false,
        previewCompetencyProfileError: null,
        previewCompetencyUserJobId: event.userJobId,
        previewCompetencyFrom: event.from,
        previewCompetencyTo: event.to,
        previewCompetencyTimezone: event.timezone,
      ));
    }

    if (!context.mounted) return;

    final result = await jobRepository.fetchPreviewCompetencyProfile(
      event.userJobId,
      from: event.from,
      to: event.to,
      timezone: event.timezone,
    );

    if (result.isError) {
      if (event.notifyOnError) {
        notificationBloc.add(ErrorNotificationEvent(message: result.error));
      }
      emit(state.copyWith(
        kind: ProfileStateKind.loaded,
        previewCompetencyProfileLoading: false,
        previewCompetencyProfileError: result.error,
        previewCompetencyUserJobId: event.userJobId,
        previewCompetencyFrom: event.from,
        previewCompetencyTo: event.to,
        previewCompetencyTimezone: event.timezone,
      ));
      return;
    }

    emit(state.copyWith(
      kind: ProfileStateKind.loaded,
      previewCompetencyProfile: result.data,
      previewCompetencyProfileLoading: false,
      previewCompetencyProfileError: null,
      previewCompetencyUserJobId: event.userJobId,
      previewCompetencyFrom: event.from,
      previewCompetencyTo: event.to,
      previewCompetencyTimezone: event.timezone,
    ));
  }
}
