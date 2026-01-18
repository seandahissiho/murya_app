import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/job_ranking.dart';
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
      emit(ProfileLoading(
        user: state.user,
        quests: state.quests,
        questGroups: state.questGroups,
        questsLoading: state.questsLoading,
        questGroupsLoading: state.questGroupsLoading,
        questsError: state.questsError,
        questGroupsError: state.questGroupsError,
        questUserJobId: state.questUserJobId,
        questTimezone: state.questTimezone,
        questScope: state.questScope,
        claimingQuestId: state.claimingQuestId,
        leaderboardUsers: state.leaderboardUsers,
        leaderboardLoading: state.leaderboardLoading,
        leaderboardError: state.leaderboardError,
        leaderboardJobId: state.leaderboardJobId,
        leaderboardFrom: state.leaderboardFrom,
        leaderboardTo: state.leaderboardTo,
      ));
    });
    on<ProfileLoadEvent>(_onProfileLoadEvent);
    on<ProfileLoadQuestsEvent>(_onProfileLoadQuestsEvent);
    on<ProfileLoadQuestGroupsEvent>(_onProfileLoadQuestGroupsEvent);
    on<ProfileClaimQuestEvent>(_onProfileClaimQuestEvent);
    on<ProfileLoadLeaderboardEvent>(_onProfileLoadLeaderboardEvent);

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
      emit(ProfileLoaded(
        user: _userProfile,
        quests: state.quests,
        questGroups: state.questGroups,
        questsLoading: state.questsLoading,
        questGroupsLoading: state.questGroupsLoading,
        questsError: state.questsError,
        questGroupsError: state.questGroupsError,
        questUserJobId: state.questUserJobId,
        questTimezone: state.questTimezone,
        questScope: state.questScope,
        claimingQuestId: state.claimingQuestId,
        leaderboardUsers: state.leaderboardUsers,
        leaderboardLoading: state.leaderboardLoading,
        leaderboardError: state.leaderboardError,
        leaderboardJobId: state.leaderboardJobId,
        leaderboardFrom: state.leaderboardFrom,
        leaderboardTo: state.leaderboardTo,
      ));
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
    emit(ProfileLoaded(
      user: _userProfile,
      quests: state.quests,
      questGroups: state.questGroups,
      questsLoading: state.questsLoading,
      questGroupsLoading: state.questGroupsLoading,
      questsError: state.questsError,
      questGroupsError: state.questGroupsError,
      questUserJobId: state.questUserJobId,
      questTimezone: state.questTimezone,
      questScope: state.questScope,
      claimingQuestId: state.claimingQuestId,
      leaderboardUsers: state.leaderboardUsers,
      leaderboardLoading: state.leaderboardLoading,
      leaderboardError: state.leaderboardError,
      leaderboardJobId: state.leaderboardJobId,
      leaderboardFrom: state.leaderboardFrom,
      leaderboardTo: state.leaderboardTo,
    ));
    add(ProfileLoadQuestGroupsEvent(scope: QuestScope.all));
  }

  FutureOr<void> _onProfileLoadQuestsEvent(ProfileLoadQuestsEvent event, Emitter<ProfileState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(ProfileLoading(
      user: state.user,
      quests: state.quests,
      questGroups: state.questGroups,
      questsLoading: true,
      questGroupsLoading: state.questGroupsLoading,
      questsError: null,
      questGroupsError: state.questGroupsError,
      questUserJobId: event.userJobId,
      questTimezone: event.timezone,
      questScope: event.scope,
      claimingQuestId: state.claimingQuestId,
      leaderboardUsers: state.leaderboardUsers,
      leaderboardLoading: state.leaderboardLoading,
      leaderboardError: state.leaderboardError,
      leaderboardJobId: state.leaderboardJobId,
      leaderboardFrom: state.leaderboardFrom,
      leaderboardTo: state.leaderboardTo,
    ));

    final result = await profileRepository.getQuests(
      scope: event.scope,
      timezone: event.timezone,
      userJobId: event.userJobId,
    );

    if (result.isError) {
      if (event.notifyOnError) {
        notificationBloc.add(ErrorNotificationEvent(message: result.error));
      }
      emit(ProfileLoaded(
        user: state.user,
        quests: state.quests,
        questGroups: state.questGroups,
        questsLoading: false,
        questGroupsLoading: state.questGroupsLoading,
        questsError: result.error,
        questGroupsError: state.questGroupsError,
        questUserJobId: event.userJobId,
        questTimezone: event.timezone,
        questScope: event.scope,
        claimingQuestId: state.claimingQuestId,
        leaderboardUsers: state.leaderboardUsers,
        leaderboardLoading: state.leaderboardLoading,
        leaderboardError: state.leaderboardError,
        leaderboardJobId: state.leaderboardJobId,
        leaderboardFrom: state.leaderboardFrom,
        leaderboardTo: state.leaderboardTo,
      ));
      return;
    }

    emit(ProfileLoaded(
      user: state.user,
      quests: result.data ?? const QuestList(),
      questGroups: state.questGroups,
      questsLoading: false,
      questGroupsLoading: state.questGroupsLoading,
      questsError: null,
      questGroupsError: state.questGroupsError,
      questUserJobId: event.userJobId,
      questTimezone: event.timezone,
      questScope: event.scope,
      claimingQuestId: state.claimingQuestId,
      leaderboardUsers: state.leaderboardUsers,
      leaderboardLoading: state.leaderboardLoading,
      leaderboardError: state.leaderboardError,
      leaderboardJobId: state.leaderboardJobId,
      leaderboardFrom: state.leaderboardFrom,
      leaderboardTo: state.leaderboardTo,
    ));
  }

  FutureOr<void> _onProfileLoadQuestGroupsEvent(ProfileLoadQuestGroupsEvent event, Emitter<ProfileState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(ProfileLoading(
      user: state.user,
      quests: state.quests,
      questGroups: state.questGroups,
      questsLoading: state.questsLoading,
      questGroupsLoading: true,
      questsError: state.questsError,
      questGroupsError: null,
      questUserJobId: event.userJobId,
      questTimezone: event.timezone,
      questScope: event.scope,
      claimingQuestId: state.claimingQuestId,
      leaderboardUsers: state.leaderboardUsers,
      leaderboardLoading: state.leaderboardLoading,
      leaderboardError: state.leaderboardError,
      leaderboardJobId: state.leaderboardJobId,
      leaderboardFrom: state.leaderboardFrom,
      leaderboardTo: state.leaderboardTo,
    ));

    final result = await profileRepository.getQuestGroups(
      scope: event.scope,
      timezone: event.timezone,
      userJobId: event.userJobId,
    );

    if (result.isError) {
      if (event.notifyOnError) {
        notificationBloc.add(ErrorNotificationEvent(message: result.error));
      }
      emit(ProfileLoaded(
        user: state.user,
        quests: state.quests,
        questGroups: state.questGroups,
        questsLoading: state.questsLoading,
        questGroupsLoading: false,
        questsError: state.questsError,
        questGroupsError: result.error,
        questUserJobId: event.userJobId,
        questTimezone: event.timezone,
        questScope: event.scope,
        claimingQuestId: state.claimingQuestId,
        leaderboardUsers: state.leaderboardUsers,
        leaderboardLoading: state.leaderboardLoading,
        leaderboardError: state.leaderboardError,
        leaderboardJobId: state.leaderboardJobId,
        leaderboardFrom: state.leaderboardFrom,
        leaderboardTo: state.leaderboardTo,
      ));
      return;
    }

    emit(ProfileLoaded(
      user: state.user,
      quests: state.quests,
      questGroups: result.data ?? const QuestGroupList(),
      questsLoading: state.questsLoading,
      questGroupsLoading: false,
      questsError: state.questsError,
      questGroupsError: null,
      questUserJobId: event.userJobId,
      questTimezone: event.timezone,
      questScope: event.scope,
      claimingQuestId: state.claimingQuestId,
      leaderboardUsers: state.leaderboardUsers,
      leaderboardLoading: state.leaderboardLoading,
      leaderboardError: state.leaderboardError,
      leaderboardJobId: state.leaderboardJobId,
      leaderboardFrom: state.leaderboardFrom,
      leaderboardTo: state.leaderboardTo,
    ));
  }

  List<LeaderBoardUser> _mapLeaderboardUsers(JobRankings ranking) {
    final users = ranking.rankings.map((ranking) {
      final String firstName = ranking.firstName ?? ranking.firstname ?? '';
      final String lastName = ranking.lastName ?? ranking.lastname ?? '';
      return LeaderBoardUser(
        id: ranking.userId,
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
    return users;
  }

  FutureOr<void> _onProfileLoadLeaderboardEvent(ProfileLoadLeaderboardEvent event, Emitter<ProfileState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    if (event.jobId.isEmpty) return;

    emit(ProfileLoading(
      user: state.user,
      quests: state.quests,
      questGroups: state.questGroups,
      questsLoading: state.questsLoading,
      questGroupsLoading: state.questGroupsLoading,
      questsError: state.questsError,
      questGroupsError: state.questGroupsError,
      questUserJobId: state.questUserJobId,
      questTimezone: state.questTimezone,
      questScope: state.questScope,
      claimingQuestId: state.claimingQuestId,
      leaderboardUsers: state.leaderboardUsers,
      leaderboardLoading: true,
      leaderboardError: null,
      leaderboardJobId: event.jobId,
      leaderboardFrom: event.from,
      leaderboardTo: event.to,
    ));

    final cachedResult = await jobRepository.getRankingForJobCached(event.jobId, event.from, event.to);
    if (cachedResult.data != null) {
      emit(ProfileLoaded(
        user: state.user,
        quests: state.quests,
        questGroups: state.questGroups,
        questsLoading: state.questsLoading,
        questGroupsLoading: state.questGroupsLoading,
        questsError: state.questsError,
        questGroupsError: state.questGroupsError,
        questUserJobId: state.questUserJobId,
        questTimezone: state.questTimezone,
        questScope: state.questScope,
        claimingQuestId: state.claimingQuestId,
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
      emit(ProfileLoaded(
        user: state.user,
        quests: state.quests,
        questGroups: state.questGroups,
        questsLoading: state.questsLoading,
        questGroupsLoading: state.questGroupsLoading,
        questsError: state.questsError,
        questGroupsError: state.questGroupsError,
        questUserJobId: state.questUserJobId,
        questTimezone: state.questTimezone,
        questScope: state.questScope,
        claimingQuestId: state.claimingQuestId,
        leaderboardUsers: state.leaderboardUsers,
        leaderboardLoading: false,
        leaderboardError: result.error,
        leaderboardJobId: event.jobId,
        leaderboardFrom: event.from,
        leaderboardTo: event.to,
      ));
      return;
    }

    emit(ProfileLoaded(
      user: state.user,
      quests: state.quests,
      questGroups: state.questGroups,
      questsLoading: state.questsLoading,
      questGroupsLoading: state.questGroupsLoading,
      questsError: state.questsError,
      questGroupsError: state.questGroupsError,
      questUserJobId: state.questUserJobId,
      questTimezone: state.questTimezone,
      questScope: state.questScope,
      claimingQuestId: state.claimingQuestId,
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

    emit(ProfileLoading(
      user: state.user,
      quests: state.quests,
      questGroups: state.questGroups,
      questsLoading: state.questsLoading,
      questGroupsLoading: state.questGroupsLoading,
      questsError: state.questsError,
      questGroupsError: state.questGroupsError,
      questUserJobId: state.questUserJobId,
      questTimezone: state.questTimezone,
      questScope: state.questScope,
      claimingQuestId: event.questId,
      leaderboardUsers: state.leaderboardUsers,
      leaderboardLoading: state.leaderboardLoading,
      leaderboardError: state.leaderboardError,
      leaderboardJobId: state.leaderboardJobId,
      leaderboardFrom: state.leaderboardFrom,
      leaderboardTo: state.leaderboardTo,
    ));

    final result = event.claimType == QuestClaimType.userJob
        ? await profileRepository.claimUserJobQuest(event.questId)
        : await profileRepository.claimUserQuest(event.questId);

    if (result.isError) {
      if (event.notifyOnError) {
        notificationBloc.add(ErrorNotificationEvent(message: result.error));
      }
      emit(ProfileLoaded(
        user: state.user,
        quests: state.quests,
        questGroups: state.questGroups,
        questsLoading: state.questsLoading,
        questGroupsLoading: state.questGroupsLoading,
        questsError: state.questsError,
        questGroupsError: state.questGroupsError,
        questUserJobId: state.questUserJobId,
        questTimezone: state.questTimezone,
        questScope: state.questScope,
        claimingQuestId: null,
        leaderboardUsers: state.leaderboardUsers,
        leaderboardLoading: state.leaderboardLoading,
        leaderboardError: state.leaderboardError,
        leaderboardJobId: state.leaderboardJobId,
        leaderboardFrom: state.leaderboardFrom,
        leaderboardTo: state.leaderboardTo,
      ));
      return;
    }

    final QuestInstance updated = result.data ?? QuestInstance.empty();
    final QuestList? updatedQuests = state.quests?.updateInstance(updated);
    final QuestGroupList? updatedGroups = state.questGroups?.updateInstance(updated);

    emit(ProfileLoaded(
      user: state.user,
      quests: updatedQuests ?? state.quests,
      questGroups: updatedGroups ?? state.questGroups,
      questsLoading: state.questsLoading,
      questGroupsLoading: state.questGroupsLoading,
      questsError: state.questsError,
      questGroupsError: state.questGroupsError,
      questUserJobId: state.questUserJobId,
      questTimezone: state.questTimezone,
      questScope: state.questScope,
      claimingQuestId: null,
      leaderboardUsers: state.leaderboardUsers,
      leaderboardLoading: state.leaderboardLoading,
      leaderboardError: state.leaderboardError,
      leaderboardJobId: state.leaderboardJobId,
      leaderboardFrom: state.leaderboardFrom,
      leaderboardTo: state.leaderboardTo,
    ));
  }
}
