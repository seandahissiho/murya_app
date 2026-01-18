import 'package:murya/models/Job.dart';

enum LeagueTier { iron, bronze, silver, gold, platinum }

extension LeagueTierExtension on LeagueTier {
  static LeagueTier? fromJsonValue(String? value) {
    switch (value) {
      case 'IRON':
        return LeagueTier.iron;
      case 'BRONZE':
        return LeagueTier.bronze;
      case 'SILVER':
        return LeagueTier.silver;
      case 'GOLD':
        return LeagueTier.gold;
      case 'PLATINUM':
        return LeagueTier.platinum;
      default:
        return null;
    }
  }
}

class QuizRadarItem {
  final String competenciesFamilyId;
  final double rawScore0to10;
  final double radarScore0to5;
  final double continuous0to10;
  final double masteryAvg0to1;
  final Level? level;

  QuizRadarItem({
    required this.competenciesFamilyId,
    required this.rawScore0to10,
    required this.radarScore0to5,
    required this.continuous0to10,
    required this.masteryAvg0to1,
    required this.level,
  });

  factory QuizRadarItem.fromJson(Map<String, dynamic> json) {
    return QuizRadarItem(
      competenciesFamilyId: json['competenciesFamilyId'] as String? ?? '',
      rawScore0to10: _toDouble(json['rawScore0to10']),
      radarScore0to5: _toDouble(json['radarScore0to5']),
      continuous0to10: _toDouble(json['continuous0to10']),
      masteryAvg0to1: _toDouble(json['masteryAvg0to1']),
      level: json['level'] == null ? null : LevelExtension.fromJsonValue(json['level'] as String?),
    );
  }
}

class UserQuiz {
  final String id;
  final String quizId;
  final String? type;
  final String? status;
  final DateTime? completedAt;
  final int totalScore;
  final int maxScore;
  final double percentage;

  UserQuiz({
    required this.id,
    required this.quizId,
    this.type,
    this.status,
    this.completedAt,
    required this.totalScore,
    required this.maxScore,
    required this.percentage,
  });

  factory UserQuiz.fromJson(Map<String, dynamic> json) {
    return UserQuiz(
      id: json['id'] as String? ?? '',
      quizId: json['quizId'] as String? ?? '',
      type: json['type'] as String?,
      status: json['status'] as String?,
      completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
      totalScore: _toInt(json['totalScore']),
      maxScore: _toInt(json['maxScore']),
      percentage: _toDouble(json['percentage']),
    );
  }
}

class UserQuizResult {
  final UserQuiz data;
  final List<QuizRadarItem> radar;
  final LeagueTier? leagueTier;
  final int? leaguePoints;
  final String? generatedArticle;

  UserQuizResult({
    required this.data,
    required this.radar,
    required this.leagueTier,
    required this.leaguePoints,
    required this.generatedArticle,
  });

  factory UserQuizResult.fromJson(Map<String, dynamic> json) {
    final radarJson = json['radar'] as List<dynamic>? ?? [];
    return UserQuizResult(
      data: UserQuiz.fromJson(json),
      radar: radarJson.map((item) => QuizRadarItem.fromJson(Map<String, dynamic>.from(item))).toList(),
      leagueTier: LeagueTierExtension.fromJsonValue(json['leagueTier'] as String?),
      leaguePoints: json['leaguePoints'] == null ? null : _toInt(json['leaguePoints']),
      generatedArticle: json['generatedArticle'] as String?,
    );
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
