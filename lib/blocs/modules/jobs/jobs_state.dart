part of 'jobs_bloc.dart';

@immutable
sealed class JobState {
  final UserJob? userCurrentJob;
  final List<Job> jobs;

  const JobState({this.jobs = const [], required this.userCurrentJob});
}

final class JobsInitial extends JobState {
  const JobsInitial({super.userCurrentJob});
}

final class JobsLoading extends JobState {
  const JobsLoading({required super.jobs, required super.userCurrentJob});
}

final class JobsSearchResults extends JobState {
  final List<Job> searchResults;

  const JobsSearchResults({required this.searchResults, required super.userCurrentJob}) : super(jobs: searchResults);
}

final class JobDetailsLoaded extends JobState {
  final AppJob job;

  const JobDetailsLoaded({required this.job, required super.userCurrentJob});
}

final class UserJobDetailsLoaded extends JobState {
  final UserJob userJob;

  const UserJobDetailsLoaded({required this.userJob, required super.userCurrentJob});
}

final class JobRankingLoaded extends JobState {
  final JobRankings ranking;

  const JobRankingLoaded({required this.ranking, required super.userCurrentJob});
}

final class UserJobCompetencyProfileLoaded extends JobState {
  final UserJobCompetencyProfile profile;

  const UserJobCompetencyProfileLoaded({required this.profile, required super.userCurrentJob});
}

final class CFDetailsLoaded extends JobState {
  final CompetencyFamily cfamily;
  final AppJob job;

  const CFDetailsLoaded({required this.cfamily, required this.job, required super.userCurrentJob});
}
