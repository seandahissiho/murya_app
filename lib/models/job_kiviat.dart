import 'package:murya/models/Job.dart';

enum JobProgressionLevel {
  BEGINNER,
  JUNIOR,
  MIDLEVEL,
  SENIOR,
}

class JobKiviat {
  final String id;
  final String? jobId;
  final String? jobFamilyId;
  final String? userJobId;
  final String competenciesFamilyId;
  final String? level;
  final double rawScore0to10;
  final double radarScore0to5;
  final double continuous0to10;
  final double masteryAvg0to1;
  final List<dynamic>? histories;
  final Job? job;
  final JobFamily? jobFamily;
  final UserJob? userJob;
  final CompetencyFamily? competenciesFamily;

  JobKiviat({
    required this.id,
    this.jobId,
    this.userJobId,
    this.jobFamilyId,
    required this.competenciesFamilyId,
    this.level,
    required this.rawScore0to10,
    required this.radarScore0to5,
    required this.continuous0to10,
    required this.masteryAvg0to1,
    this.histories,
    this.job,
    this.userJob,
    this.jobFamily,
    this.competenciesFamily,
  });

  factory JobKiviat.fromJson(Map<String, dynamic> json) {
    return JobKiviat(
      id: json['id'] as String,
      jobId: json['jobId'] as String?,
      userJobId: json['userJobId'] as String?,
      jobFamilyId: json['jobFamilyId'] as String?,
      competenciesFamilyId: (json['competenciesFamilyId'] as String?) ??
          (json['competenciesFamily'] as Map<String, dynamic>?)?['id'] as String? ??
          '',
      level: json['level'] as String?,
      rawScore0to10: _toDouble(json['rawScore0to10']),
      radarScore0to5: _toDouble(json['radarScore0to5']),
      continuous0to10: _toDouble(json['continuous0to10']),
      masteryAvg0to1: _toDouble(json['masteryAvg0to1']),
      histories: json['histories'] as List<dynamic>?,
      job: json['job'] != null ? Job.fromJson(json['job'] as Map<String, dynamic>) : null,
      jobFamily: json['jobFamily'] != null ? JobFamily.fromJson(json['jobFamily'] as Map<String, dynamic>) : null,
      userJob: json['userJob'] != null ? UserJob.fromJson(json['userJob'] as Map<String, dynamic>) : null,
      competenciesFamily: json['competenciesFamily'] != null
          ? CompetencyFamily.fromJson(json['competenciesFamily'] as Map<String, dynamic>)
          : null,
    );
  }
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
