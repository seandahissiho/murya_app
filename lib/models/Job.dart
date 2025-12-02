import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/main.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/job_kiviat.dart';
import 'package:murya/models/quiz.dart';

class Job {
  final String? id;
  final String title;
  final String description;
  final int popularity;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color textColor;
  final Color overlayColor;
  final String imagePath;
  final List<Competency> competencies;
  final List<CompetencyFamily> competenciesFamilies;
  final List<CompetencyFamily> competenciesSubFamilies;
  final List<JobKiviat> kiviats;

  Job({
    required this.id,
    required this.title,
    required this.description,
    this.popularity = 0,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.foregroundColor = const Color(0xFFFFFFFF),
    this.textColor = const Color(0xFFFFFFFF),
    this.overlayColor = const Color(0xFFFFFFFF),
    this.imagePath = '',
    this.competencies = const [],
    this.competenciesFamilies = const [],
    this.competenciesSubFamilies = const [],
    this.kiviats = const [],
  });

  factory Job.fromJson(jobJson) {
    final job = Job(
      id: jobJson['id'],
      title: jobJson['title'],
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

  List<double> kiviatValues(JobProgressionLevel level) {
    log('Getting kiviat values for level: ${level.name}');
    return kiviats.whereOrEmpty((k) => k.level == level.name).map((k) => k.value.toDouble()).toList();
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
        description: FAKER.lorem.sentences(2).join(' '),
        competencies: List.generate(20, (_) => Competency.empty()));
  }

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

// model UserJob {
// id               String        @id @default(dbgenerated("gen_random_uuid()")) @db.Uuid
// userId           String        @db.Uuid
// jobId            String        @db.Uuid
// status           UserJobStatus @default(TARGET)
// // Optional: manual level or seniority (1–5 for example)
// level            Level         @default(EASY)
// note             String?       @db.Text
// // Aggregated ressources for fast dashboards (optional but useful)
// totalScore       Int           @default(0) // sum of all quiz totalScore
// maxScoreSum      Int           @default(0) // sum of all quiz maxScore
// completedQuizzes Int           @default(0)
// lastQuizAt       DateTime?     @db.Timestamp(0)
// createdAt        DateTime      @default(now()) @db.Timestamp(0)
// updatedAt        DateTime      @default(now()) @updatedAt @db.Timestamp(0)
// user             User          @relation(fields: [userId], references: [id], onUpdate: Cascade, onDelete: Cascade)
// job              Job           @relation(fields: [jobId], references: [id], onUpdate: Cascade, onDelete: Cascade)
// quizzes          UserQuiz[]
//
// @@unique([userId, jobId], map: "unique_user_job")
// @@index([userId], map: "idx_user_job_user")
// @@index([jobId], map: "idx_user_job_job")
// }

enum UserJobStatus { target, current, past }

class UserJob {
  final String? id;
  final String? userId;
  final String? jobId;
  final UserJobStatus? status;
  final Level level;
  final String? note;
  final int totalScore;
  final int maxScoreSum;
  final int completedQuizzes;
  final DateTime? lastQuizAt;

  final User? user;
  final Job? job;
  final List<Quiz>? quizzes; // Placeholder for UserQuiz list

  UserJob({
    this.id,
    this.userId,
    this.jobId,
    this.status,
    this.level = Level.beginner,
    this.note,
    this.totalScore = 0,
    this.maxScoreSum = 0,
    this.completedQuizzes = 0,
    this.lastQuizAt,
    this.user,
    this.job,
    this.quizzes,
  });

  factory UserJob.fromJson(userJobJson) {
    return UserJob(
      id: userJobJson['id'],
      userId: userJobJson['userId'],
      jobId: userJobJson['jobId'],
      job: userJobJson['job'] != null ? Job.fromJson(userJobJson['job']) : null,
      status: userJobJson['status'] != null
          ? UserJobStatus.values.firstWhere(
              (e) => e.toString().split('.').last.toLowerCase() == userJobJson['status'].toLowerCase(),
              orElse: () => UserJobStatus.target,
            )
          : null,
      level: userJobJson['level'] != null ? LevelExtension.fromString(userJobJson['level']) : Level.beginner,
      note: userJobJson['note'],
      totalScore: userJobJson['totalScore'] ?? 0,
      maxScoreSum: userJobJson['maxScoreSum'] ?? 0,
      completedQuizzes: userJobJson['completedQuizzes'] ?? 0,
      lastQuizAt: userJobJson['lastQuizAt'] != null ? DateTime.parse(userJobJson['lastQuizAt']) : null,
      // user and job parsing can be added here if needed
    );
  }

  get isNotEmpty => id != null && id!.isNotEmpty;

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

  Competency({
    required this.id,
    required this.name,
    this.families,
    required this.type,
    required this.level,
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

class CompetencyFamily {
  final String? id;
  final String name;
  final String? description;
  final List<Competency> competencies;
  final CompetencyFamily? parent;
  final List<CompetencyFamily> children;

  CompetencyFamily({
    required this.id,
    required this.name,
    this.description,
    this.competencies = const [],
    this.parent,
    this.children = const [],
  });

  factory CompetencyFamily.fromJson(familyJson) {
    return CompetencyFamily(
      id: familyJson['id'],
      name: familyJson['name'],
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

  static CompetencyFamily empty() {
    return CompetencyFamily(
      id: '',
      name: FAKER.lorem.words(1).join(' '),
      description: FAKER.lorem.sentences(50).join(' '),
    );
  }
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
