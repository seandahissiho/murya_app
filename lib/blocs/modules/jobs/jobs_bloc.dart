import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/job_ranking.dart';
import 'package:murya/models/user_job_competency_profile.dart';
import 'package:murya/repositories/jobs.repository.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  UserJob? _userCurrentJob;
  final List<Job> jobs = [];
  late final JobRepository jobRepository;
  late final NotificationBloc notificationBloc;
  late final AuthenticationBloc authenticationBloc;
  late final StreamSubscription<AuthenticationState> _authSubscription;

  JobBloc({required BuildContext context}) : super(const JobsInitial()) {
    on<JobEvent>((event, emit) {
      emit(JobsLoading(jobs: state.jobs, userCurrentJob: state.userCurrentJob));
    });
    // search
    on<SearchJobs>(_onSearchJobs);
    on<LoadUserCurrentJob>(_onLoadUserCurrentJob);
    on<LoadJobDetails>(_onLoadJobDetails);
    on<LoadUserJobDetails>(_onLoadUserJobDetails);
    on<LoadRankingForJob>(_onLoadRankingForJob);
    on<LoadCFDetails>(_onLoadCFDetails);
    on<LoadUserJobCompetencyProfile>(_onLoadUserJobCompetencyProfile);

    jobRepository = RepositoryProvider.of<JobRepository>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    _authSubscription = authenticationBloc.stream.listen((state) {
      if (state is Authenticated && context.mounted) {
        add(LoadUserCurrentJob(context: context));
      }
    });
  }

  Future<void> _onSearchJobs(SearchJobs event, Emitter<JobState> emit) async {
    final local = AppLocalizations.of(event.context);
    final query = event.query.toLowerCase();
    final result = await jobRepository.searchJobs(query: query);

    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.searchNoResults(query)));
      emit(JobsSearchResults(searchResults: [], userCurrentJob: state.userCurrentJob));
      return;
    }

    jobs.clear();
    jobs.addAll(result.data ?? []);
    emit(JobsSearchResults(searchResults: result.data ?? [], userCurrentJob: state.userCurrentJob));
  }

  Future<void> _onLoadUserCurrentJob(LoadUserCurrentJob event, Emitter<JobState> emit) async {
    if (!authenticationBloc.state.isAuthenticated) {
      return;
    }

    final cachedResult = await jobRepository.getUserCurrentJobCached();
    if (cachedResult.data != null) {
      _userCurrentJob = cachedResult.data;
      emit(UserJobDetailsLoaded(userJob: _userCurrentJob!, userCurrentJob: _userCurrentJob));
    }
    if (event.context.mounted == false) return;

    final local = AppLocalizations.of(event.context);

    final result = await jobRepository.getUserCurrentJob();

    if (result.isError || result.data == null) {
      // notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.user_ressources_module_title));
      return;
    }
    _userCurrentJob = result.data;

    emit(UserJobDetailsLoaded(userJob: _userCurrentJob!, userCurrentJob: _userCurrentJob));
  }

  FutureOr<void> _onLoadJobDetails(LoadJobDetails event, Emitter<JobState> emit) async {
    final cachedResult = await jobRepository.getJobDetailsCached(event.jobId);
    if (cachedResult.data != null) {
      emit(JobDetailsLoaded(job: cachedResult.data!, userCurrentJob: state.userCurrentJob));
    }
    if (event.context.mounted == false) return;

    final local = AppLocalizations.of(event.context);
    final result = await jobRepository.getJobDetails(event.jobId);

    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.user_ressources_module_title));
      return;
    }
    final jobDetails = result.data!;

    emit(JobDetailsLoaded(job: jobDetails, userCurrentJob: state.userCurrentJob));
  }

  FutureOr<void> _onLoadUserJobDetails(LoadUserJobDetails event, Emitter<JobState> emit) async {
    if (!authenticationBloc.state.isAuthenticated) {
      return;
    }

    final cachedResult = await jobRepository.getUserJobDetailsCached(event.jobId);
    if (cachedResult.data != null) {
      emit(UserJobDetailsLoaded(userJob: cachedResult.data!, userCurrentJob: state.userCurrentJob));
    }
    if (event.context.mounted == false) return;

    final local = AppLocalizations.of(event.context);
    final result = await jobRepository.getUserJobDetails(event.jobId);

    if (result.isError) {
      // notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.user_ressources_module_title));
      return;
    }
    final userJobDetails = result.data!;

    emit(UserJobDetailsLoaded(userJob: userJobDetails, userCurrentJob: state.userCurrentJob));
  }

  FutureOr<void> _onLoadRankingForJob(LoadRankingForJob event, Emitter<JobState> emit) async {
    if (!authenticationBloc.state.isAuthenticated) {
      return;
    }
    if (event.jobId.isEmptyOrNull) return;

    final cachedResult = await jobRepository.getRankingForJobCached(event.jobId, event.from, event.to);
    if (cachedResult.data != null) {
      emit(JobRankingLoaded(ranking: cachedResult.data!, userCurrentJob: state.userCurrentJob));
    }
    if (event.context.mounted == false) return;

    final local = AppLocalizations.of(event.context);
    final result = await jobRepository.getRankingForJob(event.jobId, event.from, event.to);

    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.user_ressources_module_title));
      return;
    }
    final ranking = result.data!;

    emit(JobRankingLoaded(ranking: ranking, userCurrentJob: state.userCurrentJob));
  }

  FutureOr<void> _onLoadCFDetails(LoadCFDetails event, Emitter<JobState> emit) async {
    final cachedResult = await jobRepository.getCFDetailsCached(event.jobId, event.cfId);
    if (cachedResult.data != null) {
      emit(CFDetailsLoaded(
          cfamily: cachedResult.data!.$1, job: cachedResult.data!.$2, userCurrentJob: state.userCurrentJob));
    }
    if (event.context.mounted == false) return;

    final local = AppLocalizations.of(event.context);
    final result = await jobRepository.getCFDetails(event.jobId, event.cfId);

    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.user_ressources_module_title));
      return;
    }
    final cfDetails = result.data!.$1;
    final jobDetails = result.data!.$2;

    emit(CFDetailsLoaded(cfamily: cfDetails, job: jobDetails, userCurrentJob: state.userCurrentJob));
  }

  FutureOr<void> _onLoadUserJobCompetencyProfile(LoadUserJobCompetencyProfile event, Emitter<JobState> emit) async {
    if (!authenticationBloc.state.isAuthenticated) {
      return;
    }

    final local = AppLocalizations.of(event.context);

    // Try to load from cache first
    final cachedResult = await jobRepository.fetchUserJobCompetencyProfileCached(event.jobId);
    if (cachedResult.data != null && cachedResult.data!.competencyFamilies.isNotEmpty) {
      // Ensure we don't display empty profiles if we can avoid it, or check if empty is valid state
      if (cachedResult.data!.competencyFamilies.isNotEmpty) {
        emit(UserJobCompetencyProfileLoaded(profile: cachedResult.data!, userCurrentJob: state.userCurrentJob));
      }
    }

    final result = await jobRepository.fetchUserJobCompetencyProfile(event.jobId);
    if (result.isError) {
      // notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.user_ressources_module_title));
      return;
    }
    final profile = result.data!;
    emit(UserJobCompetencyProfileLoaded(profile: profile, userCurrentJob: state.userCurrentJob));
  }
}
