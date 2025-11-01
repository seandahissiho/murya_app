part of 'jobs_bloc.dart';

@immutable
sealed class JobEvent {}

final class SearchJobs extends JobEvent {
  final String query;
  final BuildContext context;

  SearchJobs({required this.query, required this.context});
}

final class LoadJobDetails extends JobEvent {
  final String jobId;
  final BuildContext context;

  LoadJobDetails({required this.jobId, required this.context});
}

final class LoadCFDetails extends JobEvent {
  final String jobId;
  final String cfId;
  final BuildContext context;

  LoadCFDetails({required this.jobId, required this.cfId, required this.context});
}
