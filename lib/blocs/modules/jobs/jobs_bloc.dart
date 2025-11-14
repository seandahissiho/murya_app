import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/repositories/jobs.repository.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final List<Job> _myJobs = [];
  late final JobRepository jobRepository;
  late final NotificationBloc notificationBloc;

  JobBloc({required BuildContext context}) : super(JobsInitial()) {
    on<JobEvent>((event, emit) {
      emit(JobsLoading(jobs: state.jobs));
    });
    // search
    on<SearchJobs>(_onSearchJobs);
    on<LoadJobDetails>(_onLoadJobDetails);
    on<LoadUserJobDetails>(_onLoadUserJobDetails);
    on<LoadCFDetails>(_onLoadCFDetails);

    jobRepository = RepositoryProvider.of<JobRepository>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
  }

  Future<void> _onSearchJobs(SearchJobs event, Emitter<JobState> emit) async {
    final local = AppLocalizations.of(event.context);
    final query = event.query.toLowerCase();
    final result = await jobRepository.searchJobs(query: query);

    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.searchNoResults(query)));
      emit(const JobsSearchResults(searchResults: []));
      return;
    }

    emit(JobsSearchResults(searchResults: result.data ?? []));
  }

  FutureOr<void> _onLoadJobDetails(LoadJobDetails event, Emitter<JobState> emit) async {
    final local = AppLocalizations.of(event.context);
    final result = await jobRepository.getJobDetails(event.jobId);

    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.user_stats_module_title));
      return;
    }
    final jobDetails = result.data!;

    emit(JobDetailsLoaded(job: jobDetails));
  }

  FutureOr<void> _onLoadUserJobDetails(LoadUserJobDetails event, Emitter<JobState> emit) async {
    final local = AppLocalizations.of(event.context);
    final result = await jobRepository.getUserJobDetails(event.jobId);

    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.user_stats_module_title));
      return;
    }
    final userJobDetails = result.data!;

    emit(UserJobDetailsLoaded(userJob: userJobDetails));
  }

  FutureOr<void> _onLoadCFDetails(LoadCFDetails event, Emitter<JobState> emit) async {
    final local = AppLocalizations.of(event.context);
    final result = await jobRepository.getCFDetails(event.jobId, event.cfId);

    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(message: result.error ?? local.user_stats_module_title));
      return;
    }
    final cfDetails = result.data!.$1;
    final jobDetails = result.data!.$2;

    emit(CFDetailsLoaded(cfamily: cfDetails, job: jobDetails));
  }
}
