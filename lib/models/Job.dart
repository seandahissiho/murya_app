import 'package:flutter/material.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/main.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/job_kiviat.dart';
import 'package:murya/models/quiz.dart';
import 'package:murya/models/resource.dart';

sealed class AppJob {
  final String? id;
  final String title;
  final String slug;
  final String description;
  final List<Competency> competencies;
  final List<CompetencyFamily> competenciesFamilies;
  final List<CompetencyFamily> competenciesSubFamilies;
  final List<JobKiviat> kiviats;

  AppJob({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.competencies,
    required this.competenciesFamilies,
    required this.competenciesSubFamilies,
    required this.kiviats,
  });

  kiviatValues(JobProgressionLevel level) {}

  competenciesPerFamily(CompetencyFamily family) {}

  static AppJob empty() {
    return Job.empty();
  }
}

class Job extends AppJob {
  final int popularity;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color textColor;
  final Color overlayColor;
  final String imagePath;

  Job({
    required super.id,
    required super.title,
    required super.slug,
    required super.description,
    this.popularity = 0,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.foregroundColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFFFFFFFF),
    this.overlayColor = const Color(0xFFFFFFFF),
    this.imagePath = '',
    super.competencies = const [],
    super.competenciesFamilies = const [],
    super.competenciesSubFamilies = const [],
    super.kiviats = const [],
  });

  factory Job.fromJson(jobJson) {
    final job = Job(
      id: jobJson['id'],
      title: jobJson['title'],
      slug: jobJson['slug'] ?? '',
      description: jobJson['description'] ?? '',
      popularity: jobJson['popularity'] ?? 0,
      backgroundColor:
          jobJson['background_color'] != null ? parseColor(jobJson['background_color']) : const Color(0xFFFFFFFF),
      foregroundColor:
          jobJson['foreground_color'] != null ? parseColor(jobJson['foreground_color']) : const Color(0xFFFFFFFF),
      textColor: jobJson['text_color'] != null ? parseColor(jobJson['text_color']) : const Color(0xFFFFFFFF),
      overlayColor: jobJson['overlay_color'] != null ? parseColor(jobJson['overlay_color']) : const Color(0xFFFFFFFF),
      imagePath: jobJson['image_path'] ?? '',
      competencies: jobJson['competencies'] != null
          ? (jobJson['competencies'] as List).map((compJson) => Competency.fromJson(compJson)).toList()
          : [],
      competenciesFamilies: jobJson['competenciesFamilies'] != null
          ? (jobJson['competenciesFamilies'] as List)
              .map((familyJson) => CompetencyFamily.fromJson(familyJson))
              .toList()
          : [],
      competenciesSubFamilies: jobJson['competenciesSubfamilies'] != null
          ? (jobJson['competenciesSubfamilies'] as List)
              .map((familyJson) => CompetencyFamily.fromJson(familyJson))
              .toList()
          : [],
      kiviats: jobJson['kiviats'] != null
          ? (jobJson['kiviats'] as List).map((kiviatJson) => JobKiviat.fromJson(kiviatJson)).toList()
          : [],
    );

    return job;
  }

  @override
  List<double> kiviatValues(JobProgressionLevel level) {
    return kiviats.whereOrEmpty((k) => k.level == level.name).map((k) => k.radarScore0to5).toList();
  }

  // List<CompetencyFamily> get competenciesFamilies {
  //   final Set<CompetencyFamily?> familiesSet = {};
  //   for (final competency in competencies) {
  //     if (competency.families != null) {
  //       familiesSet.addAll(competency.families!.whereOrEmpty((family) => family.parent != null));
  //     }
  //   }
  //   return familiesSet.whereOrEmpty((family) => family != null).cast<CompetencyFamily>();
  // }

  static Color parseColor(String hex) {
    String hexCode = hex.replaceAll('#', '');
    if (hexCode.length == 6) {
      hexCode = 'FF$hexCode';
    }
    return Color(int.parse(hexCode, radix: 16));
  }

  static Job empty() {
    return Job(
      id: '',
      title: FAKER.lorem.word(),
      slug: '',
      description: FAKER.lorem.sentence() * 5,
      competencies: List.generate(20, (_) => Competency.empty()),
      competenciesFamilies: List.generate(5, (_) => CompetencyFamily.empty()),
      competenciesSubFamilies: List.generate(5, (_) => CompetencyFamily.empty()),
    );
  }

  @override
  competenciesPerFamily(CompetencyFamily family) {
    return competencies.where((comp) => comp.families != null && comp.families!.contains(family)).toList();
  }

  getProficiencyLevel(comp, int level) {
    // Placeholder logic for proficiency level calculation
    // In a real scenario, this would be based on actual data
    switch (level) {
      case 0:
        return 1.0;
      case 1:
        return 2.0;
      case 2:
        return 3.0;
      case 3:
        return 4.0;
      default:
        return 0.0;
    }
  }
}

class JobFamily extends AppJob {
  // final String? id;
  // final String title;
  // final String? description;
  final List<Job> jobs;
  final List<Resource> resources;

  // final List<JobKiviat> kiviats;

  JobFamily({
    required super.id,
    required super.title,
    required super.slug,
    required super.description,
    this.jobs = const [],
    this.resources = const [],
    super.kiviats = const [],
    required super.competencies,
    required super.competenciesFamilies,
    required super.competenciesSubFamilies,
  });

  factory JobFamily.fromJson(familyJson) {
    final id = familyJson['id'];
    final title = familyJson['name'] ?? familyJson['title'];
    final slug = familyJson['slug'] ?? '';
    final description = familyJson['description'] ?? '';

    final jobs = familyJson['jobs'] != null
        ? (familyJson['jobs'] as List).map((jobJson) => Job.fromJson(jobJson)).toList()
        : <Job>[];

    final resources = familyJson['learningResources'] != null
        ? (familyJson['learningResources'] as List).map((resJson) => Resource.fromJson(resJson)).toList()
        : <Resource>[];

    final kiviats = familyJson['kiviats'] != null
        ? (familyJson['kiviats'] as List).map((kiviatJson) => JobKiviat.fromJson(kiviatJson)).toList()
        : <JobKiviat>[];

    final competencies = familyJson['competencies'] != null
        ? (familyJson['competencies'] as List).map((compJson) => Competency.fromJson(compJson)).toList()
        : <Competency>[];

    final competenciesFamilies = familyJson['competenciesFamilies'] != null
        ? (familyJson['competenciesFamilies'] as List)
            .map((familyJson) => CompetencyFamily.fromJson(familyJson))
            .toList()
        : <CompetencyFamily>[];

    final competenciesSubFamilies = familyJson['competenciesSubfamilies'] != null
        ? (familyJson['competenciesSubfamilies'] as List)
            .map((familyJson) => CompetencyFamily.fromJson(familyJson))
            .toList()
        : <CompetencyFamily>[];

    return JobFamily(
      id: id,
      title: title,
      slug: slug,
      description: description,
      jobs: jobs,
      resources: resources,
      kiviats: kiviats,
      competencies: competencies,
      competenciesFamilies: competenciesFamilies,
      competenciesSubFamilies: competenciesSubFamilies,
    );
  }

  static JobFamily empty() {
    return JobFamily(
      id: '',
      title: FAKER.lorem.words(1).join(' '),
      slug: '',
      description: '',
      jobs: [],
      resources: [],
      competencies: [],
      competenciesFamilies: [],
      competenciesSubFamilies: [],
    );
  }

  @override
  List<double> kiviatValues(JobProgressionLevel level) {
    return kiviats.whereOrEmpty((k) => k.level == level.name).map((k) => k.radarScore0to5).toList();
  }

  @override
  competenciesPerFamily(CompetencyFamily family) {
    return competencies.where((comp) => comp.families != null && comp.families!.contains(family)).toList();
  }
}

enum UserJobStatus { target, current, past }

class UserJob {
  final String? id;
  final String? userId;
  final String? jobId;
  final String? jobFamilyId;
  final UserJobStatus? status;
  final Level level;
  final String? note;
  final int totalScore;
  final int maxScoreSum;
  final int completedQuizzes;
  final DateTime? lastQuizAt;
  final List<JobKiviat> kiviats;

  final User? user;
  final Job? job;
  final JobFamily? jobFamily;
  final List<Quiz>? quizzes; // Placeholder for UserQuiz list

  UserJob({
    this.id,
    this.userId,
    this.jobId,
    this.jobFamilyId,
    this.status,
    this.level = Level.beginner,
    this.note,
    this.totalScore = 0,
    this.maxScoreSum = 0,
    this.completedQuizzes = 0,
    this.lastQuizAt,
    this.kiviats = const [],
    this.user,
    this.job,
    this.jobFamily,
    this.quizzes,
  });

  factory UserJob.fromJson(userJobJson) {
    final id = userJobJson['id'];
    final userId = userJobJson['userId'];
    final jobId = userJobJson['jobId'];
    final job = userJobJson['job'] != null ? Job.fromJson(userJobJson['job']) : null;
    final jobFamilyId = userJobJson['jobFamilyId'];
    final jobFamily = userJobJson['jobFamily'] != null ? JobFamily.fromJson(userJobJson['jobFamily']) : null;

    final statusString = userJobJson['status'];
    final status = statusString != null
        ? UserJobStatus.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == statusString.toLowerCase(),
            orElse: () => UserJobStatus.target,
          )
        : null;

    final levelString = userJobJson['level'];
    final level = levelString != null ? LevelExtension.fromString(levelString) : Level.beginner;

    final note = userJobJson['note'];
    final totalScore = userJobJson['totalScore'] ?? 0;
    final maxScoreSum = userJobJson['maxScoreSum'] ?? 0;
    final completedQuizzes = userJobJson['completedQuizzes'] ?? 0;

    final lastQuizAtString = userJobJson['lastQuizAt'];
    final lastQuizAt = lastQuizAtString != null ? DateTime.parse(lastQuizAtString) : null;
    final kiviats = userJobJson['kiviats'] != null
        ? (userJobJson['kiviats'] as List).map((kiviatJson) => JobKiviat.fromJson(kiviatJson)).toList()
        : <JobKiviat>[];

    return UserJob(
      id: id,
      userId: userId,
      jobId: jobId,
      job: job,
      jobFamilyId: jobFamilyId,
      jobFamily: jobFamily,
      status: status,
      level: level,
      note: note,
      totalScore: totalScore,
      maxScoreSum: maxScoreSum,
      completedQuizzes: completedQuizzes,
      lastQuizAt: lastQuizAt,
      kiviats: kiviats,
    );
  }

  List<double> kiviatValues(List<CompetencyFamily> families, {String? level}) {
    if (kiviats.isEmpty || families.isEmpty) return [];
    final Map<String, List<double>> valuesPerFamily = {};
    for (final kiviat in kiviats) {
      if (level != null && kiviat.level != level) continue;
      valuesPerFamily.putIfAbsent(kiviat.competenciesFamilyId, () => <double>[]).add(kiviat.radarScore0to5);
    }
    return families.map((family) {
      final values = valuesPerFamily[family.id] ?? const <double>[];
      if (values.isEmpty) return 0.0;
      final avg = values.reduce((a, b) => a + b) / values.length;
      return avg > 5.0 ? 5.0 : avg;
    }).toList();
  }

  get isNotEmpty => id != null && id!.isNotEmpty;

  List<double> get kiviatsValues {
    return kiviats.map((k) => k.radarScore0to5).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'jobId': jobId,
      'note': note,
    };
  }

  static UserJob empty() {
    return UserJob(
      id: '',
      userId: '',
      jobId: '',
      level: Level.beginner,
    );
  }
}

class Competency {
  final String? id;
  final String name;
  final List<CompetencyFamily>? families;
  final CompetencyType type;
  final Level level;
  final CompetencyRating? rating;
  final double? percentage;
  final double? masteryNow;
  final double? mastery30d;
  final int? attemptsCount;
  final double? bestScore;
  final DateTime? lastQuizAt;

  Competency({
    required this.id,
    required this.name,
    this.families,
    required this.type,
    required this.level,
    this.rating,
    this.percentage,
    this.masteryNow,
    this.mastery30d,
    this.attemptsCount,
    this.bestScore,
    this.lastQuizAt,
  });

  factory Competency.fromJson(compJson) {
    return Competency(
      id: compJson['id'],
      name: compJson['name'],
      families: compJson['families'] != null
          ? (compJson['families'] as List).map((familyJson) => CompetencyFamily.fromJson(familyJson)).toList()
          : null,
      type: CompetencyTypeExtension.fromString(compJson['type']),
      level: LevelExtension.fromString(compJson['level']),
      rating: CompetencyRatingExtension.fromString(compJson['rating'] as String?),
      percentage: _toDoubleNullable(compJson['percentage']),
      masteryNow: _toDoubleNullable(compJson['masteryNow']),
      mastery30d: _toDoubleNullable(compJson['mastery30d']),
      attemptsCount: (compJson['attemptsCount'] as num?)?.toInt(),
      bestScore: _toDoubleNullable(compJson['bestScore']),
      lastQuizAt: compJson['lastQuizAt'] != null ? DateTime.parse(compJson['lastQuizAt'] as String) : null,
    );
  }

  static Competency empty() {
    return Competency(
      id: '',
      name: FAKER.job.title(),
      type: CompetencyType.hardSkill,
      level: Level.beginner,
    );
  }
}

enum CompetencyRating { tresBon, bon, moyen, mauvais, tresMauvais }

extension CompetencyRatingExtension on CompetencyRating {
  static CompetencyRating? fromString(String? rating) {
    if (rating == null) return null;
    switch (rating.toUpperCase()) {
      case 'TRES_BON':
        return CompetencyRating.tresBon;
      case 'BON':
        return CompetencyRating.bon;
      case 'MOYEN':
        return CompetencyRating.moyen;
      case 'MAUVAIS':
        return CompetencyRating.mauvais;
      case 'TRES_MAUVAIS':
        return CompetencyRating.tresMauvais;
      default:
        return null;
    }
  }

  String get iconAssetPath {
    switch (this) {
      case CompetencyRating.tresBon:
      case CompetencyRating.bon:
        return AppIcons.grinningFacePath;
      case CompetencyRating.moyen:
        return AppIcons.expressionlessFacePath;
      case CompetencyRating.mauvais:
      case CompetencyRating.tresMauvais:
        return AppIcons.wearyFacePath;
    }
  }

  String get tooltipText {
    switch (this) {
      case CompetencyRating.tresBon:
        return 'Vous êtes en progression !';
      case CompetencyRating.bon:
        return 'Vous êtes en progression !';
      case CompetencyRating.moyen:
        return 'Vous avez besoin de pratiquer davantage.';
      case CompetencyRating.mauvais:
        return 'Vous avez besoin de pratiquer davantage.';
      case CompetencyRating.tresMauvais:
        return 'Vous avez besoin de pratiquer davantage.';
    }
  }

  String localizedTooltipText(BuildContext context) {
    final locale = AppLocalizations.of(context);
    switch (this) {
      case CompetencyRating.tresBon:
        return locale.competencyRatingVeryGoodTooltip;
      case CompetencyRating.bon:
        return locale.competencyRatingGoodTooltip;
      case CompetencyRating.moyen:
        return locale.competencyRatingAverageTooltip;
      case CompetencyRating.mauvais:
        return locale.competencyRatingBadTooltip;
      case CompetencyRating.tresMauvais:
        return locale.competencyRatingVeryBadTooltip;
    }
  }
}

class CompetencyFamily {
  final String? id;
  final String name;
  final String slug;
  final String? description;
  final List<Competency> competencies;
  final CompetencyFamily? parent;
  final List<CompetencyFamily> children;

  CompetencyFamily({
    required this.id,
    required this.name,
    this.slug = '',
    this.description,
    this.competencies = const [],
    this.parent,
    this.children = const [],
  });

  factory CompetencyFamily.fromJson(familyJson) {
    return CompetencyFamily(
      id: familyJson['id'],
      name: familyJson['name'],
      slug: familyJson['slug'] ?? '',
      description: familyJson['description'],
      competencies: familyJson['competencies'] != null
          ? (familyJson['competencies'] as List).map((compJson) => Competency.fromJson(compJson)).toList()
          : [],
      parent: familyJson['parent'] != null ? CompetencyFamily.fromJson(familyJson['parent']) : null,
      children: familyJson['children'] != null
          ? (familyJson['children'] as List).map((childJson) => CompetencyFamily.fromJson(childJson)).toList()
          : [],
    );
  }

  // Override equality operator and hashCode to ensure uniqueness in a Set
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CompetencyFamily && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  // tous les scores doivent etre converti sur une echelle de 5

  static CompetencyFamily empty({int depth = 0, int maxDepth = 1}) {
    final canNest = depth < maxDepth;
    return CompetencyFamily(
      id: '',
      name: FAKER.lorem.word(),
      description: FAKER.lorem.sentence() * 5,
      competencies: List.generate(20, (_) => Competency.empty()),
      parent: null,
      children:
          canNest ? List.generate(3, (_) => CompetencyFamily.empty(depth: depth + 1, maxDepth: maxDepth)) : const [],
    );
  }
}

double? _toDoubleNullable(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

enum CompetencyType { hardSkill, softSkill }

extension CompetencyTypeExtension on CompetencyType {
  static CompetencyType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'hard_skill':
        return CompetencyType.hardSkill;
      case 'soft_skill':
        return CompetencyType.softSkill;
      default:
        throw Exception('Unknown CompetencyType: $type');
    }
  }

  String localisedName(BuildContext context) {
    final locale = AppLocalizations.of(context);
    switch (this) {
      case CompetencyType.hardSkill:
        return locale.hard_skill;
      case CompetencyType.softSkill:
        return locale.soft_skill;
    }
  }
}

enum Level { beginner, intermediate, advanced, expert }

extension LevelExtension on Level {
  static Level fromString(String level) {
    switch (level.toLowerCase()) {
      case 'easy':
        return Level.beginner;
      case 'medium':
        return Level.intermediate;
      case 'hard':
        return Level.advanced;
      case 'expert':
        return Level.expert;
      default:
        throw Exception('Unknown Level: $level');
    }
  }

  String localisedName(BuildContext context) {
    final locale = AppLocalizations.of(context);
    switch (this) {
      case Level.beginner:
        return locale.easy;
      case Level.intermediate:
        return locale.medium;
      case Level.advanced:
        return locale.hard;
      case Level.expert:
        return locale.expert;
    }
  }

  static fromJsonValue(String? json) {
    switch (json) {
      case 'EASY':
        return Level.beginner;
      case 'MEDIUM':
        return Level.intermediate;
      case 'HARD':
        return Level.advanced;
      case 'EXPERT':
        return Level.expert;
      default:
        return Level.beginner;
    }
  }
}
