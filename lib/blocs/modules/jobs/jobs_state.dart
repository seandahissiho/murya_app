part of 'jobs_bloc.dart';

@immutable
sealed class JobState {
  final List<Job> jobs;

  const JobState({this.jobs = const []});
}

final class JobsInitial extends JobState {}

final class JobsLoading extends JobState {
  const JobsLoading({required super.jobs});
}

final class JobsSearchResults extends JobState {
  final List<Job> searchResults;

  const JobsSearchResults({required this.searchResults}) : super(jobs: searchResults);
}

final class JobDetailsLoaded extends JobState {
  final Job job;

  const JobDetailsLoaded({required this.job});
}

final class CFDetailsLoaded extends JobState {
  final CompetencyFamily cfamily;
  final Job job;

  const CFDetailsLoaded({required this.cfamily, required this.job});
}
