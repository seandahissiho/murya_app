part of 'jobs_bloc.dart';

@immutable
sealed class JobEvent {}

final class SearchJobs extends JobEvent {
  final String query;
  final BuildContext context;

  SearchJobs({required this.query, required this.context});
}

final class LoadUserCurrentJob extends JobEvent {
  final BuildContext context;

  LoadUserCurrentJob({required this.context});
}

final class LoadJobDetails extends JobEvent {
  final String jobId;
  final BuildContext context;

  LoadJobDetails({required this.jobId, required this.context});
}

final class LoadUserJobDetails extends JobEvent {
  final String jobId;
  final BuildContext context;

  LoadUserJobDetails({required this.jobId, required this.context});
}

final class LoadRankingForJob extends JobEvent {
  final String jobId;
  final DateTime? from;
  final DateTime? to;
  final BuildContext context;

  LoadRankingForJob({
    required this.jobId,
    required this.context,
    this.from,
    this.to,
  });
}

final class LoadUserJobCompetencyProfile extends JobEvent {
  final String jobId;
  final BuildContext context;

  LoadUserJobCompetencyProfile({required this.jobId, required this.context});
}

final class LoadCFDetails extends JobEvent {
  final String jobId;
  final String cfId;
  final BuildContext context;
  final String? userJobId;

  LoadCFDetails({required this.jobId, required this.cfId, required this.context, this.userJobId});
}
