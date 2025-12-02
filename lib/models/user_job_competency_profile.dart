import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/job_kiviat.dart';

class UserJobCompetencyProfile {
  final String userJobId;
  final JobInfo job;
  final UserInfo user;
  final ProfileSummary summary;
  final List<CompetencyProfile> competencies;

  UserJobCompetencyProfile({
    required this.userJobId,
    required this.job,
    required this.user,
    required this.summary,
    required this.competencies,
  });

  factory UserJobCompetencyProfile.fromJson(Map<String, dynamic> json) {
    return UserJobCompetencyProfile(
      userJobId: json['userJobId'] as String,
      job: JobInfo.fromJson(json['job'] as Map<String, dynamic>),
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      summary: ProfileSummary.fromJson(json['summary'] as Map<String, dynamic>),
      competencies: (json['competencies'] as List<dynamic>)
          .map((c) => CompetencyProfile.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  List<CompetencyFamily> get competencyFamilies {
    return job.competencyFamilies;
    // group competencies by family
    Map<String, Set<CompetencyProfile>?> familyMap = {};
    for (var competenciesFamily in job.competencyFamilies) {
      familyMap[competenciesFamily.id!] = {};
    }
    for (var competency in competencies) {
      for (var familyId in competency.competencyFamiliesIds) {
        if (familyMap.containsKey(familyId)) {
          familyMap[familyId]!.add(competency);
        }
      }
    }

    // create CompetencyFamily objects
    List<CompetencyFamily> families = [];
    familyMap.forEach((familyId, competenciesSet) {
      families.add(CompetencyFamily(
        id: familyId,
        name: job.competencyFamilies.firstWhereOrNull((cf) => cf.id == familyId)?.name ?? 'Unknown',
      ));
    });
    return families;
  }

  List<double> get kiviatValues {
    return job.kiviatValues;
  }

  static UserJobCompetencyProfile empty() {
    return UserJobCompetencyProfile(
      userJobId: '',
      job: JobInfo(id: '', title: '', normalizedName: ''),
      user: UserInfo(id: ''),
      summary: ProfileSummary(
        totalCompetencies: 0,
        avgPercentage: 0.0,
        strongCount: 0,
        weakCount: 0,
      ),
      competencies: [],
    );
  }
}

class JobInfo {
  final String id;
  final String title;
  final String normalizedName;
  final String? description;
  final List<CompetencyFamily> competencyFamilies;
  final List<JobKiviat>? kiviat;

  JobInfo({
    required this.id,
    required this.title,
    required this.normalizedName,
    this.description,
    this.competencyFamilies = const [],
    this.kiviat,
  });

  factory JobInfo.fromJson(Map<String, dynamic> json) {
    return JobInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      normalizedName: json['normalizedName'] as String,
      description: json['description'] as String?,
      competencyFamilies: (json['competencyFamilies'] as List<dynamic>?)
              ?.map((cf) => CompetencyFamily.fromJson(cf as Map<String, dynamic>))
              .toList() ??
          [],
      kiviat: (json['kiviat'] as List<dynamic>?)?.map((k) => JobKiviat.fromJson(k as Map<String, dynamic>)).toList(),
    );
  }

  List<double> get kiviatValues {
    if (kiviat == null) return [];
    return kiviat!.map((k) => k.value.toDouble()).toList();
  }
}

class UserInfo {
  final String id;
  final String? firstname;
  final String? lastname;
  final String? email;

  UserInfo({
    required this.id,
    this.firstname,
    this.lastname,
    this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
    };
  }
}

class ProfileSummary {
  final int totalCompetencies;
  final double avgPercentage;
  final int strongCount;
  final int weakCount;
  final DateTime? lastQuizAt;

  ProfileSummary({
    required this.totalCompetencies,
    required this.avgPercentage,
    required this.strongCount,
    required this.weakCount,
    this.lastQuizAt,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      totalCompetencies: (json['totalCompetencies'] as num).toInt(),
      avgPercentage: (json['avgPercentage'] as num).toDouble(),
      strongCount: (json['strongCount'] as num).toInt(),
      weakCount: (json['weakCount'] as num).toInt(),
      lastQuizAt: json['lastQuizAt'] != null ? DateTime.parse(json['lastQuizAt'] as String) : null,
    );
  }
}

class CompetencyProfile {
  final String competencyId;
  final List<String> competencyFamiliesIds;
  final String name;
  final String normalizedName;
  final String type; // "HARD_SKILL" | "SOFT_SKILL"
  final String? level; // enum Level, nullable
  final double percentage;
  final double currentScore;
  final double maxScore;
  final int attemptsCount;
  final double bestScore;
  final DateTime? lastQuizAt;
  final List<CompetencyHistoryPoint> history;

  CompetencyProfile({
    required this.competencyId,
    this.competencyFamiliesIds = const [],
    required this.name,
    required this.normalizedName,
    required this.type,
    this.level,
    required this.percentage,
    required this.currentScore,
    required this.maxScore,
    required this.attemptsCount,
    required this.bestScore,
    this.lastQuizAt,
    required this.history,
  });

  factory CompetencyProfile.fromJson(Map<String, dynamic> json) {
    return CompetencyProfile(
      competencyId: json['competencyId'] as String,
      competencyFamiliesIds:
          (json['competencyFamiliesIds'] as List<dynamic>?)?.map((id) => id as String).toList() ?? [],
      name: json['name'] as String,
      normalizedName: json['normalizedName'] as String,
      type: json['type'] as String,
      level: json['level'] as String?,
      percentage: (json['percentage'] as num).toDouble(),
      currentScore: (json['currentScore'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      attemptsCount: (json['attemptsCount'] as num).toInt(),
      bestScore: (json['bestScore'] as num).toDouble(),
      lastQuizAt: json['lastQuizAt'] != null ? DateTime.parse(json['lastQuizAt'] as String) : null,
      history: (json['history'] as List<dynamic>)
          .map((h) => CompetencyHistoryPoint.fromJson(h as Map<String, dynamic>))
          .toList(),
    );
  }

  double get percentageBase5 {
    return (percentage / 100) * 5;
  }
}

class CompetencyHistoryPoint {
  final DateTime date;
  final double score;
  final double maxScore;
  final double percentage;

  CompetencyHistoryPoint({
    required this.date,
    required this.score,
    required this.maxScore,
    required this.percentage,
  });

  factory CompetencyHistoryPoint.fromJson(Map<String, dynamic> json) {
    return CompetencyHistoryPoint(
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
