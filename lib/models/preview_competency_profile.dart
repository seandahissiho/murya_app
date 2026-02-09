import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/job_kiviat.dart';
import 'package:murya/models/quest.dart';

class PreviewCompetencyProfile {
  final String userJobId;
  final PreviewJob? job;
  final PreviewUser user;
  final PreviewObjective? objective;
  final PreviewKiviats kiviats;
  final PreviewRanking ranking;

  PreviewCompetencyProfile({
    required this.userJobId,
    required this.job,
    required this.user,
    required this.objective,
    required this.kiviats,
    required this.ranking,
  });

  factory PreviewCompetencyProfile.fromJson(Map<String, dynamic> json) {
    return PreviewCompetencyProfile(
      userJobId: json['userJobId']?.toString() ?? '',
      job: _parseNullable(json['job'], (data) => PreviewJob.fromJson(data)),
      user: PreviewUser.fromJson(_parseMap(json['user'])),
      objective: _parseNullable(json['objective'], (data) => PreviewObjective.fromJson(data)),
      kiviats: PreviewKiviats.fromJson(_parseMap(json['kiviats'])),
      ranking: PreviewRanking.fromJson(_parseMap(json['ranking'])),
    );
  }

  static PreviewCompetencyProfile empty() {
    return PreviewCompetencyProfile(
      userJobId: '',
      job: null,
      user: PreviewUser.empty(),
      objective: null,
      kiviats: PreviewKiviats.empty(),
      ranking: PreviewRanking.empty(),
    );
  }

  copyWith({
    String? userJobId,
    String? userId,
    PreviewUser? user,
  }) {
    return PreviewCompetencyProfile(
      userJobId: userJobId ?? this.userJobId,
      job: job,
      user: userId != null ? PreviewUser(id: userId, diamonds: 0) : (user ?? this.user),
      objective: objective,
      kiviats: kiviats,
      ranking: ranking,
    );
  }
}

class PreviewJob {
  final String id;
  final String title;
  final String? slug;
  final String? description;
  final String scope;

  PreviewJob({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    required this.scope,
  });

  factory PreviewJob.fromJson(Map<String, dynamic> json) {
    return PreviewJob(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      scope: json['scope']?.toString() ?? '',
    );
  }
}

class PreviewUser {
  final String id;
  final String? firstname;
  final String? lastname;
  final String? profilePictureUrl;
  final int diamonds;

  PreviewUser({
    required this.id,
    this.firstname,
    this.lastname,
    this.profilePictureUrl,
    required this.diamonds,
  });

  factory PreviewUser.fromJson(Map<String, dynamic> json) {
    return PreviewUser(
      id: json['id']?.toString() ?? '',
      firstname: json['firstname']?.toString(),
      lastname: json['lastname']?.toString(),
      profilePictureUrl: json['profilePictureUrl']?.toString(),
      diamonds: _toInt(json['diamonds']),
    );
  }

  static PreviewUser empty() {
    return PreviewUser(
      id: '',
      diamonds: 0,
    );
  }

  String? get firstName => firstname;

  String? get lastName => lastname;
}

class PreviewObjective {
  final String id;
  final String code;
  final String title;
  final String? description;
  final double completionPercentage;
  final String status;
  final DateTime? periodStartAt;
  final DateTime? periodEndAt;
  final int requiredTotal;
  final int requiredCompleted;
  final int optionalTotal;
  final int optionalCompleted;
  final bool completed;

  PreviewObjective({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.completionPercentage,
    required this.status,
    this.periodStartAt,
    this.periodEndAt,
    required this.requiredTotal,
    required this.requiredCompleted,
    required this.optionalTotal,
    required this.optionalCompleted,
    required this.completed,
  });

  factory PreviewObjective.fromJson(Map<String, dynamic> json) {
    return PreviewObjective(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      completionPercentage: _toDouble(json['completionPercentage']),
      status: json['status']?.toString() ?? '',
      periodStartAt: _parseDate(json['periodStartAt']),
      periodEndAt: _parseDate(json['periodEndAt']),
      requiredTotal: _toInt(json['requiredTotal']),
      requiredCompleted: _toInt(json['requiredCompleted']),
      optionalTotal: _toInt(json['optionalTotal']),
      optionalCompleted: _toInt(json['optionalCompleted']),
      completed: json['completed'] as bool? ?? false,
    );
  }

  QuestGroup toQuestGroup() {
    return QuestGroup(
      group: QuestGroupDefinition(
        id: id,
        code: code,
        title: title,
        description: description,
        scope: 'USER_JOB',
      ),
      instance: QuestGroupInstance(
        status: status,
        periodStartAt: periodStartAt,
        periodEndAt: periodEndAt,
      ),
      requiredTotal: requiredTotal,
      requiredCompleted: requiredCompleted,
      optionalTotal: optionalTotal,
      optionalCompleted: optionalCompleted,
      completed: completed,
    );
  }
}

class PreviewKiviats {
  final List<CompetencyFamily> families;
  final List<JobKiviat> userJob;
  final List<JobKiviat> jobDefaults;

  PreviewKiviats({
    required this.families,
    required this.userJob,
    required this.jobDefaults,
  });

  factory PreviewKiviats.fromJson(Map<String, dynamic> json) {
    return PreviewKiviats(
      families: _parseList(json['families'], (item) => CompetencyFamily.fromJson(item)),
      userJob: _parseList(json['userJob'], (item) => JobKiviat.fromJson(item)),
      jobDefaults: _parseList(json['jobDefaults'], (item) => JobKiviat.fromJson(item)),
    );
  }

  static PreviewKiviats empty() {
    return PreviewKiviats(
      families: const <CompetencyFamily>[],
      userJob: const <JobKiviat>[],
      jobDefaults: const <JobKiviat>[],
    );
  }

  defaultKiviatValues(JobProgressionLevel level) {
    return jobDefaults.whereOrEmpty((k) => k.level == level.name).map((k) => k.radarScore0to5).toList();
  }
}

class PreviewRanking {
  final UserJobRankingRow? me;
  final UserJobRankingRow? top;
  final UserJobRankingRow? betweenTop;
  final UserJobRankingRow? betweenBottom;

  PreviewRanking({
    this.me,
    this.top,
    this.betweenTop,
    this.betweenBottom,
  });

  factory PreviewRanking.fromJson(Map<String, dynamic> json) {
    return PreviewRanking(
      me: _parseNullable(json['me'], (data) => UserJobRankingRow.fromJson(data)),
      top: _parseNullable(json['top'], (data) => UserJobRankingRow.fromJson(data)),
      betweenTop: _parseNullable(json['betweenTop'], (data) => UserJobRankingRow.fromJson(data)),
      betweenBottom: _parseNullable(json['betweenBottom'], (data) => UserJobRankingRow.fromJson(data)),
    );
  }

  static PreviewRanking empty() => PreviewRanking();
}

class UserJobRankingRow {
  final String userJobId;
  final String userId;
  final String? firstname;
  final String? lastname;
  final String? jobId;
  final String? jobTitle;
  final int totalScore;
  final int maxScoreSum;
  final double percentage;
  final int completedQuizzes;
  final String? lastQuizAt;
  final int rank;
  final String? profilePictureUrl;
  final int diamonds;
  final int questionsAnswered;
  final double performance;
  final String? sinceDate;

  UserJobRankingRow({
    required this.userJobId,
    required this.userId,
    this.firstname,
    this.lastname,
    this.jobId,
    this.jobTitle,
    required this.totalScore,
    required this.maxScoreSum,
    required this.percentage,
    required this.completedQuizzes,
    this.lastQuizAt,
    required this.rank,
    this.profilePictureUrl,
    required this.diamonds,
    required this.questionsAnswered,
    required this.performance,
    this.sinceDate,
  });

  factory UserJobRankingRow.fromJson(Map<String, dynamic> json) {
    return UserJobRankingRow(
      userJobId: json['userJobId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      firstname: (json['firstname'] ?? json['firstName'])?.toString(),
      lastname: (json['lastname'] ?? json['lastName'])?.toString(),
      jobId: (json['jobId'] ?? json['jobFamilyId'])?.toString(),
      jobTitle: (json['jobTitle'] ?? json['jobFamilyTitle'])?.toString(),
      totalScore: _toInt(json['totalScore']),
      maxScoreSum: _toInt(json['maxScoreSum']),
      percentage: _toDouble(json['percentage']),
      completedQuizzes: _toInt(json['completedQuizzes']),
      lastQuizAt: json['lastQuizAt']?.toString(),
      rank: _toInt(json['rank']),
      profilePictureUrl: json['profilePictureUrl']?.toString(),
      diamonds: _toInt(json['diamonds']),
      questionsAnswered: _toInt(json['questionsAnswered']),
      performance: _toDouble(json['performance']),
      sinceDate: json['sinceDate']?.toString(),
    );
  }
}

Map<String, dynamic> _parseMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<T> _parseList<T>(dynamic value, T Function(Map<String, dynamic>) mapper) {
  if (value is! List) return <T>[];
  return value.whereType<Map>().map((item) => mapper(Map<String, dynamic>.from(item))).toList();
}

T? _parseNullable<T>(dynamic value, T Function(Map<String, dynamic>) mapper) {
  if (value is Map) {
    return mapper(Map<String, dynamic>.from(value));
  }
  return null;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
