import 'package:murya/models/Job.dart';

enum JobProgressionLevel {
  JUNIOR,
  MIDLEVEL,
  SENIOR,
  EXPERT,
}

class JobKiviat {
  final String id;
  final String? jobId;
  final String? userJobId;
  final String competenciesFamilyId;
  final String level;
  final double value;

  final Job? job;
  final UserJob? userJob;
  final CompetencyFamily? competenciesFamily;

  JobKiviat({
    required this.id,
    this.jobId,
    this.userJobId,
    required this.competenciesFamilyId,
    required this.level,
    required this.value,
    this.job,
    this.userJob,
    this.competenciesFamily,
  });

  factory JobKiviat.fromJson(Map<String, dynamic> json) {
    return JobKiviat(
      id: json['id'] as String,
      jobId: json['jobId'] as String?,
      userJobId: json['userJobId'] as String?,
      competenciesFamilyId: json['competenciesFamilyId'] as String,
      level: json['level'] as String,
      value: double.tryParse(json['value'].toString()) ?? 0.0,
      job: json['job'] != null ? Job.fromJson(json['job'] as Map<String, dynamic>) : null,
      userJob: json['userJob'] != null ? UserJob.fromJson(json['userJob'] as Map<String, dynamic>) : null,
      competenciesFamily: json['competenciesFamily'] != null
          ? CompetencyFamily.fromJson(json['competenciesFamily'] as Map<String, dynamic>)
          : null,
    );
  }
}
