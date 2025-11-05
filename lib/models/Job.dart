import 'package:flutter/material.dart';
import 'package:murya/l10n/l10n.dart';

class Job {
  final String id;
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
    );

    return job;
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
      title: '',
      description: '',
    );
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

class Competency {
  final String id;
  final String name;
  final List<CompetencyFamily>? families;
  final int? beginnerScore;
  final int? intermediateScore;
  final int? advancedScore;
  final int? expertScore;
  final int? maxScore;
  final CompetencyType type;
  final Level level;

  Competency({
    required this.id,
    required this.name,
    this.families,
    this.beginnerScore,
    this.intermediateScore,
    this.advancedScore,
    this.expertScore,
    this.maxScore,
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
      beginnerScore: compJson['beginnerScore'],
      intermediateScore: compJson['intermediateScore'],
      advancedScore: compJson['advancedScore'],
      expertScore: compJson['expertScore'],
      maxScore: compJson['maxScore'],
      type: CompetencyTypeExtension.fromString(compJson['type']),
      level: LevelExtension.fromString(compJson['level']),
    );
  }
}

class CompetencyFamily {
  final String id;
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
  double beginnerAverageScore() {
    if (competencies.isEmpty) return 0.0;
    double total = 0.0;
    for (final comp in competencies) {
      if (comp.beginnerScore != null && comp.maxScore != null && comp.maxScore! > 0) {
        total += (comp.beginnerScore! / comp.maxScore!) * 5.0;
      }
    }
    return total / competencies.length;
  }

  double intermediateAverageScore() {
    if (competencies.isEmpty) return 0.0;
    double total = 0.0;
    for (final comp in competencies) {
      if (comp.intermediateScore != null && comp.maxScore != null && comp.maxScore! > 0) {
        total += (comp.intermediateScore! / comp.maxScore!) * 5.0;
      }
    }
    return total / competencies.length;
  }

  double advancedAverageScore() {
    if (competencies.isEmpty) return 0.0;
    double total = 0.0;
    for (final comp in competencies) {
      if (comp.advancedScore != null && comp.maxScore != null && comp.maxScore! > 0) {
        total += (comp.advancedScore! / comp.maxScore!) * 5.0;
      }
    }
    return total / competencies.length;
  }

  double expertAverageScore() {
    if (competencies.isEmpty) return 0.0;
    double total = 0.0;
    for (final comp in competencies) {
      if (comp.expertScore != null && comp.maxScore != null && comp.maxScore! > 0) {
        total += (comp.expertScore! / comp.maxScore!) * 5.0;
      }
    }
    return total / competencies.length;
  }

  double averageScoreByLevel({required int level}) {
    switch (level) {
      case 0:
        return beginnerAverageScore();
      case 1:
        return intermediateAverageScore();
      case 2:
        return advancedAverageScore();
      case 3:
        return expertAverageScore();
      default:
        return 0.0;
    }
  }

  static CompetencyFamily empty() {
    return CompetencyFamily(
      id: '',
      name: '',
    );
  }
}

enum CompetencyType { hardSkill, softSkill }

extension CompetencyTypeExtension on CompetencyType {
  static CompetencyType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'hardskill':
        return CompetencyType.hardSkill;
      case 'softskill':
        return CompetencyType.softSkill;
      default:
        return CompetencyType.hardSkill;
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
      case 'beginner':
        return Level.beginner;
      case 'intermediate':
        return Level.intermediate;
      case 'advanced':
        return Level.advanced;
      case 'expert':
        return Level.expert;
      default:
        return Level.beginner;
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
}
