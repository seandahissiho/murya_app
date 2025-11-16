class JobRanking {
  final String userJobId;
  final String userId;
  final String? firstname;
  final String? lastname;
  final String jobId;
  final String jobTitle;
  final int totalScore;
  final int maxScoreSum;
  final double percentage;
  final int completedQuizzes;
  final DateTime? lastQuizAt;
  final int rank;

  JobRanking({
    required this.userJobId,
    required this.userId,
    this.firstname,
    this.lastname,
    required this.jobId,
    required this.jobTitle,
    required this.totalScore,
    required this.maxScoreSum,
    required this.percentage,
    required this.completedQuizzes,
    this.lastQuizAt,
    required this.rank,
  });

  factory JobRanking.fromJson(Map<String, dynamic> json) {
    return JobRanking(
      userJobId: json['userJobId'],
      userId: json['userId'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      jobId: json['jobId'],
      jobTitle: json['jobTitle'],
      totalScore: json['totalScore'] is String ? int.parse(json['totalScore']) : json['totalScore'],
      maxScoreSum: json['maxScoreSum'] is String ? int.parse(json['maxScoreSum']) : json['maxScoreSum'],
      percentage: json['percentage'] is String ? double.parse(json['percentage']) : json['percentage'].toDouble(),
      completedQuizzes:
          json['completedQuizzes'] is String ? int.parse(json['completedQuizzes']) : json['completedQuizzes'],
      lastQuizAt: json['lastQuizAt'] != null ? DateTime.parse(json['lastQuizAt']) : null,
      rank: json['rank'] is String ? int.parse(json['rank']) : json['rank'],
    );
  }

  String get fullName {
    if (firstname == null && lastname == null) return "Utilisateur inconnu";
    return "${firstname ?? ''} ${lastname ?? ''}".trim();
  }
}

class JobRankings {
  final List<JobRanking> rankings;

  JobRankings({required this.rankings});

  factory JobRankings.fromJson(Map<String, dynamic> json) {
    final rankingsJson = json['results'] as List<dynamic>? ?? [];
    final rankings = rankingsJson.map((rankingJson) => JobRanking.fromJson(rankingJson)).toList();
    return JobRankings(rankings: rankings);
  }

  static JobRankings empty() {
    return JobRankings(rankings: []);
  }
}
