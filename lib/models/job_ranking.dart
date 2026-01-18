class JobRanking {
  final String userJobId;
  final String userId;
  final String? firstname;
  final String? lastname;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final String jobId;
  final String jobTitle;
  final int totalScore;
  final int maxScoreSum;
  final double percentage;
  final int completedQuizzes;
  final DateTime? lastQuizAt;
  final int diamonds;
  final int questionsAnswered;
  final double performance;
  final DateTime? sinceDate;
  final int rank;

  JobRanking({
    required this.userJobId,
    required this.userId,
    this.firstname,
    this.lastname,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    required this.jobId,
    required this.jobTitle,
    required this.totalScore,
    required this.maxScoreSum,
    required this.percentage,
    required this.completedQuizzes,
    this.lastQuizAt,
    required this.diamonds,
    required this.questionsAnswered,
    required this.performance,
    this.sinceDate,
    required this.rank,
  });

  factory JobRanking.fromJson(Map<String, dynamic> json) {
    final String? firstName = json['firstName'] ?? json['firstname'];
    final String? lastName = json['lastName'] ?? json['lastname'];
    return JobRanking(
      userJobId: json['userJobId'],
      userId: json['userId'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      firstName: firstName,
      lastName: lastName,
      profilePictureUrl: json['profilePictureUrl']?.toString(),
      jobId: json['jobId'] ?? json['jobFamilyId'],
      jobTitle: json['jobTitle'] ?? json['jobFamilyTitle'],
      totalScore: json['totalScore'] is String ? int.parse(json['totalScore']) : json['totalScore'],
      maxScoreSum: json['maxScoreSum'] is String ? int.parse(json['maxScoreSum']) : json['maxScoreSum'],
      percentage: json['percentage'] is String ? double.parse(json['percentage']) : json['percentage'].toDouble(),
      completedQuizzes:
          json['completedQuizzes'] is String ? int.parse(json['completedQuizzes']) : json['completedQuizzes'],
      lastQuizAt: json['lastQuizAt'] != null ? DateTime.parse(json['lastQuizAt']) : null,
      diamonds: json['diamonds'] is String ? int.parse(json['diamonds']) : (json['diamonds'] ?? 0),
      questionsAnswered:
          json['questionsAnswered'] is String ? int.parse(json['questionsAnswered']) : (json['questionsAnswered'] ?? 0),
      performance: json['performance'] is String ? double.parse(json['performance']) : (json['performance'] ?? 0).toDouble(),
      sinceDate: json['sinceDate'] != null ? DateTime.parse(json['sinceDate']) : null,
      rank: json['rank'] is String ? int.parse(json['rank']) : json['rank'],
    );
  }

  String get fullName {
    final String? first = firstName ?? firstname;
    final String? last = lastName ?? lastname;
    if (first == null && last == null) return "Utilisateur inconnu";
    return "${first ?? ''} ${last ?? ''}".trim();
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
