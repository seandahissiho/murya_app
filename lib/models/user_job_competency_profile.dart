import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/repositories/base.repository.dart';

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

  List<double> get competencyFamiliesValues {
    if (WE_ARE_BEFORE_QUIZZ) return [];
    return [1, 2, 2, 1, 2];

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

    // calculate average percentage for each family
    List<double> familyAverages = [];
    familyMap.forEach((familyId, competenciesSet) {
      if (competenciesSet != null && competenciesSet.isNotEmpty) {
        // aggregate nb of competencies validated per family
        final nbCompetenciesValidated = competenciesSet.where((c) => c.percentage >= 100).length;
        final nbCompetencies = competenciesSet.length;
        final int base10Result = ((nbCompetenciesValidated / nbCompetencies) * 10).round();
        // Nombre de réussite par famille	0	1	2 à 5	6 ou 7	8 ou 9	10
        // Diagramme du positionnement	0	1	2	3	4	5
        if (base10Result == 0) {
          familyAverages.add(0.0);
        } else if (base10Result == 1) {
          familyAverages.add(1.0);
        } else if (base10Result >= 2 && base10Result <= 5) {
          familyAverages.add(2.0);
        } else if (base10Result == 6 || base10Result == 7) {
          familyAverages.add(3.0);
        } else if (base10Result == 8 || base10Result == 9) {
          familyAverages.add(4.0);
        } else if (base10Result == 10) {
          familyAverages.add(5.0);
        }

        // double total = 0.0;
        // for (var competency in competenciesSet) {
        //   total += competency.percentage;
        // }
        // double average = (total / competenciesSet.length) / 20;
        // average = average <= 0.5 ? 0.5 : average;
        // familyAverages.add(average); // convert to base 5
      } else {
        familyAverages.add(0);
      }
    });
    return familyAverages;
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

  JobInfo({
    required this.id,
    required this.title,
    required this.normalizedName,
    this.description,
    this.competencyFamilies = const [],
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
    );
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
