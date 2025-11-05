import 'package:flutter/foundation.dart' show listEquals, mapEquals;

enum QuizzQuestionType {
  single_choice,
  multiple_choice,
  true_false,
  short_answer,
  fill_in_the_blank,
}

extension QuizzQuestionTypeJson on QuizzQuestionType {
  String toJsonValue() => name; // "single_choice", etc.

  static QuizzQuestionType fromJsonValue(String? value) {
    if (value == null) return QuizzQuestionType.single_choice;
    for (final v in QuizzQuestionType.values) {
      if (v.name == value) return v;
    }
    // Par défaut (tu ne supportes que single_choice pour l’instant)
    return QuizzQuestionType.single_choice;
  }
}

/// -------------------- Quizz --------------------
class Quizz {
  final List<QuestionResponses> questionResponses;

  Quizz({required this.questionResponses});

  factory Quizz.fromJson(Map<String, dynamic> json) {
    final list = (json['questionResponses'] as List?) ?? const [];
    return Quizz(
      questionResponses: list
          .map((e) => QuestionResponses.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'questionResponses': questionResponses.map((e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quizz && listEquals(other.questionResponses, questionResponses);
  }

  @override
  int get hashCode => Object.hashAll(questionResponses);
}

/// -------------------- QuestionResponses --------------------
class QuestionResponses {
  final QuizzQuestion question;
  final List<QuizzResponse> responses;
  final int index;

  QuestionResponses({
    required this.question,
    required this.responses,
    required this.index,
  });

  factory QuestionResponses.fromJson(Map<String, dynamic> json) {
    final resp = (json['responses'] as List?) ?? const [];
    return QuestionResponses(
      question: QuizzQuestion.fromJson(Map<String, dynamic>.from(json['question'])),
      responses: resp.map((e) => QuizzResponse.fromJson(Map<String, dynamic>.from(e))).toList(),
      index: json['index'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'question': question.toJson(),
        'responses': responses.map((e) => e.toJson()).toList(),
        'index': index,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionResponses &&
        other.question == question &&
        listEquals(other.responses, responses) &&
        other.index == index;
  }

  @override
  int get hashCode => Object.hash(question, Object.hashAll(responses), index);
}

/// -------------------- QuizzQuestion --------------------
class QuizzQuestion {
  final String id;
  final String text;
  final int timeLimitInSeconds;
  final int points;
  final QuizzQuestionType type;
  final String mediaUrl;
  final Map<String, dynamic>? metadata;

  QuizzQuestion({
    required this.id,
    required this.text,
    this.timeLimitInSeconds = 30,
    this.points = 1,
    this.type = QuizzQuestionType.single_choice,
    this.mediaUrl = '',
    this.metadata,
  });

  factory QuizzQuestion.fromJson(Map<String, dynamic> json) {
    return QuizzQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      timeLimitInSeconds: (json['timeLimitInSeconds'] as num?)?.toInt() ?? 30,
      points: (json['points'] as num?)?.toInt() ?? 1,
      type: QuizzQuestionTypeJson.fromJsonValue(json['type'] as String?),
      mediaUrl: (json['mediaUrl'] as String?) ?? '',
      metadata: (json['metadata'] as Map?) == null ? null : Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'timeLimitInSeconds': timeLimitInSeconds,
        'points': points,
        'type': type.toJsonValue(),
        'mediaUrl': mediaUrl,
        'metadata': metadata,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizzQuestion &&
        other.id == id &&
        other.text == text &&
        other.timeLimitInSeconds == timeLimitInSeconds &&
        other.points == points &&
        other.type == type &&
        other.mediaUrl == mediaUrl &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(id, text, timeLimitInSeconds, points, type, mediaUrl, _mapHash(metadata));

  Duration get timeLimit => Duration(seconds: timeLimitInSeconds);
}

/// -------------------- QuizzResponse --------------------
class QuizzResponse {
  final String id;
  final String text;
  final Map<String, dynamic>? metadata;
  final bool isCorrect;
  final int points;
  final int index;

  QuizzResponse({
    required this.id,
    required this.text,
    this.metadata,
    this.isCorrect = false,
    this.points = 0,
    required this.index,
  });

  factory QuizzResponse.fromJson(Map<String, dynamic> json) {
    return QuizzResponse(
      id: json['id'] as String,
      text: json['text'] as String,
      metadata: (json['metadata'] as Map?) == null ? null : Map<String, dynamic>.from(json['metadata'] as Map),
      isCorrect: (json['isCorrect'] as bool?) ?? false,
      points: (json['points'] as num?)?.toInt() ?? 0,
      index: (json['index'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'metadata': metadata,
        'isCorrect': isCorrect,
        'points': points,
        'index': index,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizzResponse &&
        other.id == id &&
        other.text == text &&
        mapEquals(other.metadata, metadata) &&
        other.isCorrect == isCorrect &&
        other.points == points &&
        other.index == index;
  }

  @override
  int get hashCode => Object.hash(id, text, _mapHash(metadata), isCorrect, points, index);
}

/// -------- Helpers for stable hashing of nullable maps --------
int _mapHash(Map<String, dynamic>? m) {
  if (m == null || m.isEmpty) return 0;
  // Hash non-ordonné: clé+valeur, pour éviter une dépendance à l’ordre d’itération.
  return Object.hashAllUnordered(
    m.entries.map((e) => Object.hash(e.key, e.value)),
  );
}

final Map<String, dynamic> TEST_QUIZZ = {
  "questionResponses": [
    {
      "index": 1,
      "question": {
        "id": "MURYA_PM_Q1",
        "text": "Pour Murya (marketplace B2B agroalimentaire), quelle North Star Metric est la plus pertinente ?",
        "timeLimitInSeconds": 5,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "metrics", "difficulty": "medium"}
      },
      "responses": [
        {
          "id": "MURYA_PM_Q1_A",
          "text": "Nombre total de téléchargements de l'app",
          "isCorrect": false,
          "points": 0,
          "index": 0
        },
        {
          "id": "MURYA_PM_Q1_B",
          "text": "Commandes livrées par utilisateur actif par semaine",
          "isCorrect": true,
          "points": 2,
          "index": 1
        },
        {"id": "MURYA_PM_Q1_C", "text": "Budget marketing mensuel", "isCorrect": false, "points": -1, "index": 2},
        {"id": "MURYA_PM_Q1_D", "text": "Taille de l'équipe produit", "isCorrect": false, "points": 0, "index": 3}
      ]
    },
    {
      "index": 2,
      "question": {
        "id": "MURYA_PM_Q2",
        "text": "Dans le funnel AARRR, laquelle relève de l’Activation pour Murya ?",
        "timeLimitInSeconds": 4,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "growth", "difficulty": "easy"}
      },
      "responses": [
        {
          "id": "MURYA_PM_Q2_A",
          "text": "Trafic organique sur la page d'inscription",
          "isCorrect": false,
          "points": 0,
          "index": 0
        },
        {
          "id": "MURYA_PM_Q2_B",
          "text": "% d’entreprises qui complètent l’onboarding",
          "isCorrect": true,
          "points": 2,
          "index": 1
        },
        {
          "id": "MURYA_PM_Q2_C",
          "text": "Valeur moyenne de commande (AOV)",
          "isCorrect": false,
          "points": -1,
          "index": 2
        },
        {"id": "MURYA_PM_Q2_D", "text": "Taux de parrainage client→client", "isCorrect": false, "points": 0, "index": 3}
      ]
    },
    {
      "index": 3,
      "question": {
        "id": "MURYA_PM_Q3",
        "text": "Tu suspectes des ruptures de stock fournisseurs. Quelle action de discovery initiale en 48h ?",
        "timeLimitInSeconds": 4,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "discovery", "difficulty": "medium"}
      },
      "responses": [
        {
          "id": "MURYA_PM_Q3_A",
          "text": "Déployer un correctif à tous les utilisateurs",
          "isCorrect": false,
          "points": 0,
          "index": 0
        },
        {
          "id": "MURYA_PM_Q3_B",
          "text": "5–7 entretiens fournisseurs ciblés + analyse des logs de stock",
          "isCorrect": true,
          "points": 2,
          "index": 1
        },
        {"id": "MURYA_PM_Q3_C", "text": "Écrire un PRD complet d’emblée", "isCorrect": false, "points": 0, "index": 2},
        {
          "id": "MURYA_PM_Q3_D",
          "text": "Augmenter le budget publicitaire",
          "isCorrect": false,
          "points": -1,
          "index": 3
        }
      ]
    },
    {
      "index": 4,
      "question": {
        "id": "MURYA_PM_Q4",
        "text": "Dans RICE, quel paramètre fait BAISSER le score quand il AUGMENTE ?",
        "timeLimitInSeconds": 3,
        "points": 1,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "prioritization", "difficulty": "easy"}
      },
      "responses": [
        {"id": "MURYA_PM_Q4_A", "text": "Reach", "isCorrect": false, "points": -1, "index": 0},
        {"id": "MURYA_PM_Q4_B", "text": "Impact", "isCorrect": false, "points": 0, "index": 1},
        {"id": "MURYA_PM_Q4_C", "text": "Confidence", "isCorrect": false, "points": 0, "index": 2},
        {"id": "MURYA_PM_Q4_D", "text": "Effort", "isCorrect": true, "points": 1, "index": 3}
      ]
    },
    {
      "index": 5,
      "question": {
        "id": "MURYA_PM_Q5",
        "text": "Lequel est un bon KPI Ops pour Murya ?",
        "timeLimitInSeconds": 5,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "ops", "difficulty": "easy"}
      },
      "responses": [
        {
          "id": "MURYA_PM_Q5_A",
          "text": "Taux de commandes livrées à l'heure (OTD)",
          "isCorrect": true,
          "points": 2,
          "index": 0
        },
        {"id": "MURYA_PM_Q5_B", "text": "Nombre d'abonnés Instagram", "isCorrect": false, "points": -1, "index": 1},
        {"id": "MURYA_PM_Q5_C", "text": "Nombre total de SKUs listés", "isCorrect": false, "points": 0, "index": 2},
        {"id": "MURYA_PM_Q5_D", "text": "Budget promotionnel mensuel", "isCorrect": false, "points": 0, "index": 3}
      ]
    },
    {
      "index": 6,
      "question": {
        "id": "MURYA_PM_Q6",
        "text": "Quel élément doit absolument figurer dans un PRD ?",
        "timeLimitInSeconds": 3,
        "points": 1,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "delivery", "difficulty": "easy"}
      },
      "responses": [
        {"id": "MURYA_PM_Q6_A", "text": "Critères d’acceptation testables", "isCorrect": true, "points": 1, "index": 0},
        {"id": "MURYA_PM_Q6_B", "text": "Roadmap annuelle complète", "isCorrect": false, "points": 0, "index": 1},
        {
          "id": "MURYA_PM_Q6_C",
          "text": "Liste exhaustive des bugs historiques",
          "isCorrect": false,
          "points": 0,
          "index": 2
        },
        {"id": "MURYA_PM_Q6_D", "text": "Captures d’écran marketing", "isCorrect": false, "points": -1, "index": 3}
      ]
    },
    {
      "index": 7,
      "question": {
        "id": "MURYA_PM_Q7",
        "text": "Tu imposes un minimum de commande pour réduire l’anti-marge. Quel KPI primaire choisir ?",
        "timeLimitInSeconds": 4,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "experimentation", "difficulty": "medium"}
      },
      "responses": [
        {"id": "MURYA_PM_Q7_A", "text": "Nombre de pages vues", "isCorrect": false, "points": -1, "index": 0},
        {"id": "MURYA_PM_Q7_B", "text": "Taux de conversion global", "isCorrect": false, "points": 0, "index": 1},
        {
          "id": "MURYA_PM_Q7_C",
          "text": "Marge de contribution moyenne par commande",
          "isCorrect": true,
          "points": 2,
          "index": 2
        },
        {"id": "MURYA_PM_Q7_D", "text": "Nombre de tickets support", "isCorrect": false, "points": 0, "index": 3}
      ]
    },
    {
      "index": 8,
      "question": {
        "id": "MURYA_PM_Q8",
        "text": "Quel énoncé est CORRECT ?",
        "timeLimitInSeconds": 3,
        "points": 1,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "planning", "difficulty": "easy"}
      },
      "responses": [
        {
          "id": "MURYA_PM_Q8_A",
          "text": "Le backlog = la roadmap avec des dates engagées",
          "isCorrect": false,
          "points": 0,
          "index": 0
        },
        {
          "id": "MURYA_PM_Q8_B",
          "text": "Le backlog est un réservoir d’options priorisées sans dates fermes",
          "isCorrect": true,
          "points": 1,
          "index": 1
        },
        {
          "id": "MURYA_PM_Q8_C",
          "text": "La roadmap est une liste de tâches sans objectifs",
          "isCorrect": false,
          "points": 0,
          "index": 2
        },
        {"id": "MURYA_PM_Q8_D", "text": "Le backlog ne change jamais", "isCorrect": false, "points": -1, "index": 3}
      ]
    },
    {
      "index": 9,
      "question": {
        "id": "MURYA_PM_Q9",
        "text": "Tu veux tester un nouveau flux de commande en 72h. Quel livrable privilégier ?",
        "timeLimitInSeconds": 5,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "ux", "difficulty": "easy"}
      },
      "responses": [
        {
          "id": "MURYA_PM_Q9_A",
          "text": "Prototype cliquable basse fidélité (ex. Figma)",
          "isCorrect": true,
          "points": 2,
          "index": 0
        },
        {
          "id": "MURYA_PM_Q9_B",
          "text": "Spécifications techniques complètes",
          "isCorrect": false,
          "points": 0,
          "index": 1
        },
        {"id": "MURYA_PM_Q9_C", "text": "Roadmap trimestrielle", "isCorrect": false, "points": 0, "index": 2},
        {"id": "MURYA_PM_Q9_D", "text": "Business plan sur 5 ans", "isCorrect": false, "points": -1, "index": 3}
      ]
    },
    {
      "index": 10,
      "question": {
        "id": "MURYA_PM_Q10",
        "text": "Quel risque un PM doit-il adresser en PRIORITÉ pendant la discovery ?",
        "timeLimitInSeconds": 4,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "discovery_risks", "difficulty": "medium"}
      },
      "responses": [
        {
          "id": "MURYA_PM_Q10_A",
          "text": "Valeur : les clients veulent-ils vraiment ça ?",
          "isCorrect": true,
          "points": 2,
          "index": 0
        },
        {
          "id": "MURYA_PM_Q10_B",
          "text": "Utilisabilité : peuvent-ils l'utiliser ?",
          "isCorrect": false,
          "points": 0,
          "index": 1
        },
        {
          "id": "MURYA_PM_Q10_C",
          "text": "Faisabilité : l'équipe peut-elle le construire ?",
          "isCorrect": false,
          "points": 0,
          "index": 2
        },
        {
          "id": "MURYA_PM_Q10_D",
          "text": "Viabilité : est-ce rentable/légal/supportable ?",
          "isCorrect": false,
          "points": 0,
          "index": 3
        }
      ]
    }
  ]
};
