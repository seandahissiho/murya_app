import 'dart:developer';

import 'package:flutter/foundation.dart' show listEquals, mapEquals;
import 'package:murya/config/custom_classes.dart';

enum QuizQuestionType {
  single_choice,
  multiple_choice,
  true_false,
  short_answer,
  fill_in_the_blank,
}

extension QuizQuestionTypeJson on QuizQuestionType {
  String toJsonValue() => name; // "single_choice", etc.

  static QuizQuestionType fromJsonValue(String? value) {
    if (value == null) return QuizQuestionType.single_choice;
    for (final v in QuizQuestionType.values) {
      if (v.name == value) return v;
    }
    // Par défaut (tu ne supportes que single_choice pour l’instant)
    return QuizQuestionType.single_choice;
  }
}

/// -------------------- Quiz --------------------
class Quiz {
  final String? id;
  final List<QuestionResponses> questionResponses;

  Quiz({
    this.id,
    required this.questionResponses,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final list = (json['questionResponses'] as List?) ?? const [];
    return Quiz(
      id: id,
      questionResponses: list
          .map((e) => QuestionResponses.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionResponses': questionResponses.map((e) => e.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quiz && other.id == id && listEquals(other.questionResponses, questionResponses);
  }

  @override
  int get hashCode => Object.hashAll([id, Object.hashAll(questionResponses)]);
}

/// -------------------- QuestionResponses --------------------
class QuestionResponses {
  final QuizQuestion question;
  final List<QuizResponse> responses;
  final int index;

  QuestionResponses({
    required this.question,
    required this.responses,
    required this.index,
  });

  factory QuestionResponses.fromJson(Map<String, dynamic> json) {
    final resp = (json['responses'] as List?) ?? const [];
    return QuestionResponses(
      question: QuizQuestion.fromJson(Map<String, dynamic>.from(json['question'])),
      responses: resp.map((e) => QuizResponse.fromJson(Map<String, dynamic>.from(e))).toList(),
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

  int get correctResponseIndex => responses.indexWhere((r) => r.isCorrect);

  QuizResponse? toQuizResponse({required int selectedResponseIndex}) {
    log('Finding response for selectedResponseIndex: $selectedResponseIndex');
    final result = responses.firstWhereOrNull((r) => r.index == selectedResponseIndex);

    return result;
  }
}

/// -------------------- QuizQuestion --------------------
class QuizQuestion {
  final String? id;
  final String text;
  final int timeLimitInSeconds;
  final int points;
  final QuizQuestionType type;
  final String mediaUrl;
  final Map<String, dynamic>? metadata;

  QuizQuestion({
    required this.id,
    required this.text,
    this.timeLimitInSeconds = 30,
    this.points = 1,
    this.type = QuizQuestionType.single_choice,
    this.mediaUrl = '',
    this.metadata,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      timeLimitInSeconds: (json['timeLimitInSeconds'] as num?)?.toInt() ?? 30,
      points: (json['points'] as num?)?.toInt() ?? 1,
      type: QuizQuestionTypeJson.fromJsonValue(json['type'] as String?),
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
    return other is QuizQuestion &&
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

  Duration get timeLimit => Duration(seconds: timeLimitInSeconds ~/ 20);
}

/// -------------------- QuizResponse --------------------
class QuizResponse {
  final String? id;
  final String questionId;
  final String text;
  final Map<String, dynamic>? metadata;
  final bool isCorrect;
  final int points;
  final int index;

  QuizResponse({
    required this.id,
    required this.questionId,
    required this.text,
    this.metadata,
    this.isCorrect = false,
    this.points = 0,
    required this.index,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      text: json['text'] as String,
      metadata: (json['metadata'] as Map?) == null ? null : Map<String, dynamic>.from(json['metadata'] as Map),
      isCorrect: (json['isCorrect'] as bool?) ?? false,
      points: (json['points'] as num?)?.toInt() ?? 0,
      index: (json['index'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionId': questionId,
        'text': text,
        'metadata': metadata,
        'isCorrect': isCorrect,
        'points': points,
        'index': index,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizResponse &&
        other.id == id &&
        other.questionId == questionId &&
        other.text == text &&
        mapEquals(other.metadata, metadata) &&
        other.isCorrect == isCorrect &&
        other.points == points &&
        other.index == index;
  }

  @override
  int get hashCode => Object.hash(id, questionId, text, _mapHash(metadata), isCorrect, points, index);

  static empty() {
    return QuizResponse(id: '', questionId: '', text: '', index: -1);
  }
}

/// -------- Helpers for stable hashing of nullable maps --------
int _mapHash(Map<String, dynamic>? m) {
  if (m == null || m.isEmpty) return 0;
  // Hash non-ordonné: clé+valeur, pour éviter une dépendance à l’ordre d’itération.
  return Object.hashAllUnordered(
    m.entries.map((e) => Object.hash(e.key, e.value)),
  );
}

final Map<String, dynamic> TEST_QUIZ = {
  "id": "MURYA_PM_QUIZ_01",
  "questionResponses": [
    {
      "index": 1,
      "question": {
        "id": "MURYA_PM_Q1",
        "text": "Pour Murya (marketplace B2B agroalimentaire), quelle North Star Metric est la plus pertinente ?",
        "timeLimitInSeconds": 45,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "metrics", "difficulty": "medium"}
      },
      "responses": [
        {
          "id": "MURYA_PM_Q1_A",
          "questionId": "MURYA_PM_Q1",
          "text": "Nombre total de téléchargements de l'app",
          "isCorrect": false,
          "points": -1,
          "index": 0,
          "metadata": {"severity": "minor", "reason": "vanity metric"}
        },
        {
          "id": "MURYA_PM_Q1_B",
          "questionId": "MURYA_PM_Q1",
          "text": "Commandes livrées par utilisateur actif par semaine",
          "isCorrect": true,
          "points": 2,
          "index": 1
        },
        {
          "id": "MURYA_PM_Q1_C",
          "questionId": "MURYA_PM_Q1",
          "text": "Budget marketing mensuel",
          "isCorrect": false,
          "points": -3,
          "index": 2,
          "metadata": {"severity": "critical", "reason": "aucun lien direct avec la valeur client"}
        },
        {
          "id": "MURYA_PM_Q1_D",
          "questionId": "MURYA_PM_Q1",
          "text": "Taille de l'équipe produit",
          "isCorrect": false,
          "points": -2,
          "index": 3,
          "metadata": {"severity": "major", "reason": "input interne, pas un outcome"}
        }
      ]
    },
    // {
    //   "index": 2,
    //   "question": {
    //     "id": "MURYA_PM_Q2",
    //     "text": "Dans le funnel AARRR, laquelle relève de l’Activation pour Murya ?",
    //     "timeLimitInSeconds": 40,
    //     "points": 2,
    //     "type": "single_choice",
    //     "mediaUrl": "",
    //     "metadata": {"topic": "growth", "difficulty": "easy"}
    //   },
    //   "responses": [
    //     {
    //       "id": "MURYA_PM_Q2_A",
    //       "questionId": "MURYA_PM_Q2",
    //       "text": "Trafic organique sur la page d'inscription",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 0,
    //       "metadata": {"severity": "minor", "reason": "Acquisition, pas Activation"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q2_B",
    //       "questionId": "MURYA_PM_Q2",
    //       "text": "% d’entreprises qui complètent l’onboarding",
    //       "isCorrect": true,
    //       "points": 2,
    //       "index": 1
    //     },
    //     {
    //       "id": "MURYA_PM_Q2_C",
    //       "questionId": "MURYA_PM_Q2",
    //       "text": "Valeur moyenne de commande (AOV)",
    //       "isCorrect": false,
    //       "points": -2,
    //       "index": 2,
    //       "metadata": {"severity": "major", "reason": "Revenue, pas Activation"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q2_D",
    //       "questionId": "MURYA_PM_Q2",
    //       "text": "Taux de parrainage client→client",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 3,
    //       "metadata": {"severity": "minor", "reason": "Referral, pas Activation"}
    //     }
    //   ]
    // },
    // {
    //   "index": 3,
    //   "question": {
    //     "id": "MURYA_PM_Q3",
    //     "text": "Tu suspectes des ruptures de stock fournisseurs. Quelle action de discovery initiale en 48h ?",
    //     "timeLimitInSeconds": 40,
    //     "points": 2,
    //     "type": "single_choice",
    //     "mediaUrl": "",
    //     "metadata": {"topic": "discovery", "difficulty": "medium"}
    //   },
    //   "responses": [
    //     {
    //       "id": "MURYA_PM_Q3_A",
    //       "questionId": "MURYA_PM_Q3",
    //       "text": "Déployer un correctif à tous les utilisateurs",
    //       "isCorrect": false,
    //       "points": -2,
    //       "index": 0,
    //       "metadata": {"severity": "major", "reason": "solutionnisme sans compréhension du problème"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q3_B",
    //       "questionId": "MURYA_PM_Q3",
    //       "text": "5–7 entretiens fournisseurs ciblés + analyse des logs de stock",
    //       "isCorrect": true,
    //       "points": 2,
    //       "index": 1
    //     },
    //     {
    //       "id": "MURYA_PM_Q3_C",
    //       "questionId": "MURYA_PM_Q3",
    //       "text": "Écrire un PRD complet d’emblée",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 2,
    //       "metadata": {"severity": "minor", "reason": "documentation prématurée"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q3_D",
    //       "questionId": "MURYA_PM_Q3",
    //       "text": "Augmenter le budget publicitaire",
    //       "isCorrect": false,
    //       "points": -3,
    //       "index": 3,
    //       "metadata": {"severity": "critical", "reason": "aucun lien avec le stock"}
    //     }
    //   ]
    // },
    // {
    //   "index": 4,
    //   "question": {
    //     "id": "MURYA_PM_Q4",
    //     "text": "Dans RICE, quel paramètre fait BAISSER le score quand il AUGMENTE ?",
    //     "timeLimitInSeconds": 35,
    //     "points": 1,
    //     "type": "single_choice",
    //     "mediaUrl": "",
    //     "metadata": {"topic": "prioritization", "difficulty": "easy"}
    //   },
    //   "responses": [
    //     {
    //       "id": "MURYA_PM_Q4_A",
    //       "questionId": "MURYA_PM_Q4",
    //       "text": "Reach",
    //       "isCorrect": false,
    //       "points": -2,
    //       "index": 0,
    //       "metadata": {"severity": "major", "reason": "effet inverse de la réalité"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q4_B",
    //       "questionId": "MURYA_PM_Q4",
    //       "text": "Impact",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 1,
    //       "metadata": {"severity": "minor", "reason": "impact ↑ -> score ↑"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q4_C",
    //       "questionId": "MURYA_PM_Q4",
    //       "text": "Confidence",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 2,
    //       "metadata": {"severity": "minor", "reason": "confidence ↑ -> score ↑"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q4_D",
    //       "questionId": "MURYA_PM_Q4",
    //       "text": "Effort",
    //       "isCorrect": true,
    //       "points": 1,
    //       "index": 3
    //     }
    //   ]
    // },
    // {
    //   "index": 5,
    //   "question": {
    //     "id": "MURYA_PM_Q5",
    //     "text": "Lequel est un bon KPI Ops pour Murya ?",
    //     "timeLimitInSeconds": 45,
    //     "points": 2,
    //     "type": "single_choice",
    //     "mediaUrl": "",
    //     "metadata": {"topic": "ops", "difficulty": "easy"}
    //   },
    //   "responses": [
    //     {
    //       "id": "MURYA_PM_Q5_A",
    //       "questionId": "MURYA_PM_Q5",
    //       "text": "Taux de commandes livrées à l'heure (OTD)",
    //       "isCorrect": true,
    //       "points": 2,
    //       "index": 0
    //     },
    //     {
    //       "id": "MURYA_PM_Q5_B",
    //       "questionId": "MURYA_PM_Q5",
    //       "text": "Nombre d'abonnés Instagram",
    //       "isCorrect": false,
    //       "points": -3,
    //       "index": 1,
    //       "metadata": {"severity": "critical", "reason": "vanity metric, hors Ops"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q5_C",
    //       "questionId": "MURYA_PM_Q5",
    //       "text": "Nombre total de SKUs listés",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 2,
    //       "metadata": {"severity": "minor", "reason": "volume catalogue ≠ qualité opérationnelle"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q5_D",
    //       "questionId": "MURYA_PM_Q5",
    //       "text": "Budget promotionnel mensuel",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 3,
    //       "metadata": {"severity": "minor", "reason": "dépenses marketing ≠ performance Ops"}
    //     }
    //   ]
    // },
    // {
    //   "index": 6,
    //   "question": {
    //     "id": "MURYA_PM_Q6",
    //     "text": "Quel élément doit absolument figurer dans un PRD ?",
    //     "timeLimitInSeconds": 30,
    //     "points": 1,
    //     "type": "single_choice",
    //     "mediaUrl": "",
    //     "metadata": {"topic": "delivery", "difficulty": "easy"}
    //   },
    //   "responses": [
    //     {
    //       "id": "MURYA_PM_Q6_A",
    //       "questionId": "MURYA_PM_Q6",
    //       "text": "Critères d’acceptation testables",
    //       "isCorrect": true,
    //       "points": 1,
    //       "index": 0
    //     },
    //     {
    //       "id": "MURYA_PM_Q6_B",
    //       "questionId": "MURYA_PM_Q6",
    //       "text": "Roadmap annuelle complète",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 1,
    //       "metadata": {"severity": "minor", "reason": "hors périmètre PRD"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q6_C",
    //       "questionId": "MURYA_PM_Q6",
    //       "text": "Liste exhaustive des bugs historiques",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 2,
    //       "metadata": {"severity": "minor", "reason": "non essentiel au PRD"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q6_D",
    //       "questionId": "MURYA_PM_Q6",
    //       "text": "Captures d’écran marketing",
    //       "isCorrect": false,
    //       "points": -2,
    //       "index": 3,
    //       "metadata": {"severity": "major", "reason": "marketing ≠ exigences produit"}
    //     }
    //   ]
    // },
    // {
    //   "index": 7,
    //   "question": {
    //     "id": "MURYA_PM_Q7",
    //     "text": "Tu imposes un minimum de commande pour réduire l’anti-marge. Quel KPI primaire choisir ?",
    //     "timeLimitInSeconds": 40,
    //     "points": 2,
    //     "type": "single_choice",
    //     "mediaUrl": "",
    //     "metadata": {"topic": "experimentation", "difficulty": "medium"}
    //   },
    //   "responses": [
    //     {
    //       "id": "MURYA_PM_Q7_A",
    //       "questionId": "MURYA_PM_Q7",
    //       "text": "Nombre de pages vues",
    //       "isCorrect": false,
    //       "points": -2,
    //       "index": 0,
    //       "metadata": {"severity": "major", "reason": "ne mesure pas l’objectif financier"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q7_B",
    //       "questionId": "MURYA_PM_Q7",
    //       "text": "Taux de conversion global",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 1,
    //       "metadata": {"severity": "minor", "reason": "indirect, peut baisser alors que la marge ↑"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q7_C",
    //       "questionId": "MURYA_PM_Q7",
    //       "text": "Marge de contribution moyenne par commande",
    //       "isCorrect": true,
    //       "points": 2,
    //       "index": 2
    //     },
    //     {
    //       "id": "MURYA_PM_Q7_D",
    //       "questionId": "MURYA_PM_Q7",
    //       "text": "Nombre de tickets support",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 3,
    //       "metadata": {"severity": "minor", "reason": "signal secondaire"}
    //     }
    //   ]
    // },
    // {
    //   "index": 8,
    //   "question": {
    //     "id": "MURYA_PM_Q8",
    //     "text": "Quel énoncé est CORRECT ?",
    //     "timeLimitInSeconds": 30,
    //     "points": 1,
    //     "type": "single_choice",
    //     "mediaUrl": "",
    //     "metadata": {"topic": "planning", "difficulty": "easy"}
    //   },
    //   "responses": [
    //     {
    //       "id": "MURYA_PM_Q8_A",
    //       "questionId": "MURYA_PM_Q8",
    //       "text": "Le backlog = la roadmap avec des dates engagées",
    //       "isCorrect": false,
    //       "points": -2,
    //       "index": 0,
    //       "metadata": {"severity": "major", "reason": "confusion backlog/roadmap"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q8_B",
    //       "questionId": "MURYA_PM_Q8",
    //       "text": "Le backlog est un réservoir d’options priorisées sans dates fermes",
    //       "isCorrect": true,
    //       "points": 1,
    //       "index": 1
    //     },
    //     {
    //       "id": "MURYA_PM_Q8_C",
    //       "questionId": "MURYA_PM_Q8",
    //       "text": "La roadmap est une liste de tâches sans objectifs",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 2,
    //       "metadata": {"severity": "minor", "reason": "la roadmap est orientée outcomes"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q8_D",
    //       "questionId": "MURYA_PM_Q8",
    //       "text": "Le backlog ne change jamais",
    //       "isCorrect": false,
    //       "points": -3,
    //       "index": 3,
    //       "metadata": {"severity": "critical", "reason": "contradit l’agilité"}
    //     }
    //   ]
    // },
    // {
    //   "index": 9,
    //   "question": {
    //     "id": "MURYA_PM_Q9",
    //     "text": "Tu veux tester un nouveau flux de commande en 72h. Quel livrable privilégier ?",
    //     "timeLimitInSeconds": 35,
    //     "points": 2,
    //     "type": "single_choice",
    //     "mediaUrl": "",
    //     "metadata": {"topic": "ux", "difficulty": "easy"}
    //   },
    //   "responses": [
    //     {
    //       "id": "MURYA_PM_Q9_A",
    //       "questionId": "MURYA_PM_Q9",
    //       "text": "Prototype cliquable basse fidélité (ex. Figma)",
    //       "isCorrect": true,
    //       "points": 2,
    //       "index": 0
    //     },
    //     {
    //       "id": "MURYA_PM_Q9_B",
    //       "questionId": "MURYA_PM_Q9",
    //       "text": "Spécifications techniques complètes",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 1,
    //       "metadata": {"severity": "minor", "reason": "trop lent pour un test en 72h"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q9_C",
    //       "questionId": "MURYA_PM_Q9",
    //       "text": "Roadmap trimestrielle",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 2,
    //       "metadata": {"severity": "minor", "reason": "hors objectif de test utilisateur"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q9_D",
    //       "questionId": "MURYA_PM_Q9",
    //       "text": "Business plan sur 5 ans",
    //       "isCorrect": false,
    //       "points": -2,
    //       "index": 3,
    //       "metadata": {"severity": "major", "reason": "hors sujet, horizon trop long"}
    //     }
    //   ]
    // },
    // {
    //   "index": 10,
    //   "question": {
    //     "id": "MURYA_PM_Q10",
    //     "text": "Quel risque un PM doit-il adresser en PRIORITÉ pendant la discovery ?",
    //     "timeLimitInSeconds": 45,
    //     "points": 2,
    //     "type": "single_choice",
    //     "mediaUrl": "",
    //     "metadata": {"topic": "discovery_risks", "difficulty": "medium"}
    //   },
    //   "responses": [
    //     {
    //       "id": "MURYA_PM_Q10_A",
    //       "questionId": "MURYA_PM_Q10",
    //       "text": "Valeur : les clients veulent-ils vraiment ça ?",
    //       "isCorrect": true,
    //       "points": 2,
    //       "index": 0
    //     },
    //     {
    //       "id": "MURYA_PM_Q10_B",
    //       "questionId": "MURYA_PM_Q10",
    //       "text": "Utilisabilité : peuvent-ils l'utiliser ?",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 1,
    //       "metadata": {"severity": "minor", "reason": "important mais après la valeur"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q10_C",
    //       "questionId": "MURYA_PM_Q10",
    //       "text": "Faisabilité : l'équipe peut-elle le construire ?",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 2,
    //       "metadata": {"severity": "minor", "reason": "à traiter après la valeur"}
    //     },
    //     {
    //       "id": "MURYA_PM_Q10_D",
    //       "questionId": "MURYA_PM_Q10",
    //       "text": "Viabilité : est-ce rentable/légal/supportable ?",
    //       "isCorrect": false,
    //       "points": -1,
    //       "index": 3,
    //       "metadata": {"severity": "minor", "reason": "priorité secondaire en discovery initiale"}
    //     }
    //   ]
    // }
  ]
};

final Map<String, dynamic> TEST_QUIZ_2 = {
  "id": "MURYA_UI_QUIZ_01",
  "questionResponses": [
    {
      "index": 1,
      "question": {
        "id": "MURYA_UI_Q1",
        "text": "Quel est le minimum de contraste requis (WCAG 2.2 AA) pour du texte normal ?",
        "timeLimitInSeconds": 40,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "accessibility", "difficulty": "medium"}
      },
      "responses": [
        {
          "id": "MURYA_UI_Q1_A",
          "questionId": "MURYA_UI_Q1",
          "text": "3:1",
          "isCorrect": false,
          "points": -2,
          "index": 0,
          "metadata": {"severity": "major", "reason": "seulement AA pour grand texte"}
        },
        {
          "id": "MURYA_UI_Q1_B",
          "questionId": "MURYA_UI_Q1",
          "text": "4.5:1",
          "isCorrect": true,
          "points": 2,
          "index": 1
        },
        {
          "id": "MURYA_UI_Q1_C",
          "questionId": "MURYA_UI_Q1",
          "text": "2:1",
          "isCorrect": false,
          "points": -3,
          "index": 2,
          "metadata": {"severity": "critical", "reason": "beaucoup trop faible"}
        },
        {
          "id": "MURYA_UI_Q1_D",
          "questionId": "MURYA_UI_Q1",
          "text": "7:1",
          "isCorrect": false,
          "points": -1,
          "index": 3,
          "metadata": {"severity": "minor", "reason": "AAA, pas le minimum AA"}
        }
      ]
    },
    {
      "index": 2,
      "question": {
        "id": "MURYA_UI_Q2",
        "text": "Taille minimale recommandée d’une cible tactile en Android (Material) ?",
        "timeLimitInSeconds": 35,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "touch", "difficulty": "easy"}
      },
      "responses": [
        {
          "id": "MURYA_UI_Q2_A",
          "questionId": "MURYA_UI_Q2",
          "text": "24 × 24 dp",
          "isCorrect": false,
          "points": -3,
          "index": 0,
          "metadata": {"severity": "critical", "reason": "cible trop petite"}
        },
        {
          "id": "MURYA_UI_Q2_B",
          "questionId": "MURYA_UI_Q2",
          "text": "36 × 36 dp",
          "isCorrect": false,
          "points": -2,
          "index": 1,
          "metadata": {"severity": "major", "reason": "en dessous du guidage"}
        },
        {
          "id": "MURYA_UI_Q2_C",
          "questionId": "MURYA_UI_Q2",
          "text": "48 × 48 dp",
          "isCorrect": true,
          "points": 2,
          "index": 2
        },
        {
          "id": "MURYA_UI_Q2_D",
          "questionId": "MURYA_UI_Q2",
          "text": "56 × 56 dp",
          "isCorrect": false,
          "points": -1,
          "index": 3,
          "metadata": {"severity": "minor", "reason": "pas le minimum recommandé"}
        }
      ]
    },
    {
      "index": 3,
      "question": {
        "id": "MURYA_UI_Q3",
        "text": "Pour la navigation clavier, quel état doit être VISIBLE sur chaque élément focalisable ?",
        "timeLimitInSeconds": 30,
        "points": 1,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "accessibility", "difficulty": "easy"}
      },
      "responses": [
        {
          "id": "MURYA_UI_Q3_A",
          "questionId": "MURYA_UI_Q3",
          "text": "Focus",
          "isCorrect": true,
          "points": 1,
          "index": 0
        },
        {
          "id": "MURYA_UI_Q3_B",
          "questionId": "MURYA_UI_Q3",
          "text": "Hover uniquement",
          "isCorrect": false,
          "points": -2,
          "index": 1,
          "metadata": {"severity": "major", "reason": "souris seulement"}
        },
        {
          "id": "MURYA_UI_Q3_C",
          "questionId": "MURYA_UI_Q3",
          "text": "Active uniquement",
          "isCorrect": false,
          "points": -1,
          "index": 2,
          "metadata": {"severity": "minor", "reason": "momentané"}
        },
        {
          "id": "MURYA_UI_Q3_D",
          "questionId": "MURYA_UI_Q3",
          "text": "Aucun indicateur visible",
          "isCorrect": false,
          "points": -3,
          "index": 3,
          "metadata": {"severity": "critical", "reason": "bloquant pour l’accessibilité"}
        }
      ]
    },
    {
      "index": 4,
      "question": {
        "id": "MURYA_UI_Q4",
        "text": "Quelle longueur de ligne améliore le plus la lisibilité des paragraphes ?",
        "timeLimitInSeconds": 40,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "typography", "difficulty": "medium"}
      },
      "responses": [
        {
          "id": "MURYA_UI_Q4_A",
          "questionId": "MURYA_UI_Q4",
          "text": "10–20 caractères par ligne",
          "isCorrect": false,
          "points": -3,
          "index": 0,
          "metadata": {"severity": "critical", "reason": "trop court"}
        },
        {
          "id": "MURYA_UI_Q4_B",
          "questionId": "MURYA_UI_Q4",
          "text": "50–75 caractères par ligne",
          "isCorrect": true,
          "points": 2,
          "index": 1
        },
        {
          "id": "MURYA_UI_Q4_C",
          "questionId": "MURYA_UI_Q4",
          "text": "80–120 caractères par ligne",
          "isCorrect": false,
          "points": -1,
          "index": 2,
          "metadata": {"severity": "minor", "reason": "trop long"}
        },
        {
          "id": "MURYA_UI_Q4_D",
          "questionId": "MURYA_UI_Q4",
          "text": "100–140 caractères par ligne",
          "isCorrect": false,
          "points": -2,
          "index": 3,
          "metadata": {"severity": "major", "reason": "très long"}
        }
      ]
    },
    {
      "index": 5,
      "question": {
        "id": "MURYA_UI_Q5",
        "text": "Quel incrément de grille de base est le plus courant pour l’espacement (Material) ?",
        "timeLimitInSeconds": 30,
        "points": 1,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "layout", "difficulty": "easy"}
      },
      "responses": [
        {
          "id": "MURYA_UI_Q5_A",
          "questionId": "MURYA_UI_Q5",
          "text": "8 px/dp",
          "isCorrect": true,
          "points": 1,
          "index": 0
        },
        {
          "id": "MURYA_UI_Q5_B",
          "questionId": "MURYA_UI_Q5",
          "text": "6 px",
          "isCorrect": false,
          "points": -1,
          "index": 1,
          "metadata": {"severity": "minor", "reason": "non standard"}
        },
        {
          "id": "MURYA_UI_Q5_C",
          "questionId": "MURYA_UI_Q5",
          "text": "12 px",
          "isCorrect": false,
          "points": -1,
          "index": 2,
          "metadata": {"severity": "minor", "reason": "peu courant"}
        },
        {
          "id": "MURYA_UI_Q5_D",
          "questionId": "MURYA_UI_Q5",
          "text": "5 px",
          "isCorrect": false,
          "points": -2,
          "index": 3,
          "metadata": {"severity": "major", "reason": "irrégulier pour la grille"}
        }
      ]
    },
    {
      "index": 6,
      "question": {
        "id": "MURYA_UI_Q6",
        "text": "Combien de boutons primaires faut-il afficher sur un écran ?",
        "timeLimitInSeconds": 25,
        "points": 1,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "buttons", "difficulty": "easy"}
      },
      "responses": [
        {
          "id": "MURYA_UI_Q6_A",
          "questionId": "MURYA_UI_Q6",
          "text": "Un seul",
          "isCorrect": true,
          "points": 1,
          "index": 0
        },
        {
          "id": "MURYA_UI_Q6_B",
          "questionId": "MURYA_UI_Q6",
          "text": "Un par section",
          "isCorrect": false,
          "points": -1,
          "index": 1,
          "metadata": {"severity": "minor", "reason": "hiérarchie confuse"}
        },
        {
          "id": "MURYA_UI_Q6_C",
          "questionId": "MURYA_UI_Q6",
          "text": "Autant que nécessaire",
          "isCorrect": false,
          "points": -3,
          "index": 2,
          "metadata": {"severity": "critical", "reason": "dilution de l’action"}
        },
        {
          "id": "MURYA_UI_Q6_D",
          "questionId": "MURYA_UI_Q6",
          "text": "Un par action possible",
          "isCorrect": false,
          "points": -2,
          "index": 3,
          "metadata": {"severity": "major", "reason": "trop de primaires"}
        }
      ]
    },
    {
      "index": 7,
      "question": {
        "id": "MURYA_UI_Q7",
        "text": "Quand préférer un skeleton à un spinner ?",
        "timeLimitInSeconds": 35,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "feedback", "difficulty": "medium"}
      },
      "responses": [
        {
          "id": "MURYA_UI_Q7_A",
          "questionId": "MURYA_UI_Q7",
          "text": "Quand la structure du contenu est connue et se remplit progressivement",
          "isCorrect": true,
          "points": 2,
          "index": 0
        },
        {
          "id": "MURYA_UI_Q7_B",
          "questionId": "MURYA_UI_Q7",
          "text": "Quand la durée est très longue et inconnue (mieux vaut une barre de progression)",
          "isCorrect": false,
          "points": -1,
          "index": 1,
          "metadata": {"severity": "minor", "reason": "préférer une barre %"}
        },
        {
          "id": "MURYA_UI_Q7_C",
          "questionId": "MURYA_UI_Q7",
          "text": "Toujours utiliser un spinner, jamais de skeleton",
          "isCorrect": false,
          "points": -3,
          "index": 2,
          "metadata": {"severity": "critical", "reason": "mauvaise UX perçue"}
        },
        {
          "id": "MURYA_UI_Q7_D",
          "questionId": "MURYA_UI_Q7",
          "text": "Uniquement pour masquer des erreurs serveur",
          "isCorrect": false,
          "points": -2,
          "index": 3,
          "metadata": {"severity": "major", "reason": "mauvaise utilisation"}
        }
      ]
    },
    {
      "index": 8,
      "question": {
        "id": "MURYA_UI_Q8",
        "text": "Où et comment afficher un message d’erreur de formulaire ?",
        "timeLimitInSeconds": 35,
        "points": 2,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "forms", "difficulty": "medium"}
      },
      "responses": [
        {
          "id": "MURYA_UI_Q8_A",
          "questionId": "MURYA_UI_Q8",
          "text": "Près du champ concerné, message clair et actionnable",
          "isCorrect": true,
          "points": 2,
          "index": 0
        },
        {
          "id": "MURYA_UI_Q8_B",
          "questionId": "MURYA_UI_Q8",
          "text": "Bannière générique en haut de page, sans détail",
          "isCorrect": false,
          "points": -2,
          "index": 1,
          "metadata": {"severity": "major", "reason": "peu actionnable"}
        },
        {
          "id": "MURYA_UI_Q8_C",
          "questionId": "MURYA_UI_Q8",
          "text": "Code d’erreur cryptique uniquement",
          "isCorrect": false,
          "points": -3,
          "index": 2,
          "metadata": {"severity": "critical", "reason": "incompréhensible"}
        },
        {
          "id": "MURYA_UI_Q8_D",
          "questionId": "MURYA_UI_Q8",
          "text": "Pop-up bloquante sans indication de correction",
          "isCorrect": false,
          "points": -2,
          "index": 3,
          "metadata": {"severity": "major", "reason": "interruption inutile"}
        }
      ]
    },
    {
      "index": 9,
      "question": {
        "id": "MURYA_UI_Q9",
        "text": "Format recommandé pour des icônes vectorielles scalables sur le web :",
        "timeLimitInSeconds": 30,
        "points": 1,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "icons", "difficulty": "easy"}
      },
      "responses": [
        {"id": "MURYA_UI_Q9_A", "questionId": "MURYA_UI_Q9", "text": "SVG", "isCorrect": true, "points": 1, "index": 0},
        {
          "id": "MURYA_UI_Q9_B",
          "questionId": "MURYA_UI_Q9",
          "text": "JPG",
          "isCorrect": false,
          "points": -1,
          "index": 1,
          "metadata": {"severity": "minor", "reason": "bitmap, pas vectoriel"}
        },
        {
          "id": "MURYA_UI_Q9_C",
          "questionId": "MURYA_UI_Q9",
          "text": "PNG",
          "isCorrect": false,
          "points": -1,
          "index": 2,
          "metadata": {"severity": "minor", "reason": "bitmap, pas vectoriel"}
        },
        {
          "id": "MURYA_UI_Q9_D",
          "questionId": "MURYA_UI_Q9",
          "text": "BMP",
          "isCorrect": false,
          "points": -3,
          "index": 3,
          "metadata": {"severity": "critical", "reason": "format obsolète, lourd"}
        }
      ]
    },
    {
      "index": 10,
      "question": {
        "id": "MURYA_UI_Q10",
        "text": "Boutons vs liens : quelle règle est correcte ?",
        "timeLimitInSeconds": 30,
        "points": 1,
        "type": "single_choice",
        "mediaUrl": "",
        "metadata": {"topic": "buttons", "difficulty": "easy"}
      },
      "responses": [
        {
          "id": "MURYA_UI_Q10_A",
          "questionId": "MURYA_UI_Q10",
          "text": "Utiliser des boutons pour des actions, des liens pour la navigation",
          "isCorrect": true,
          "points": 1,
          "index": 0
        },
        {
          "id": "MURYA_UI_Q10_B",
          "questionId": "MURYA_UI_Q10",
          "text": "Toujours des boutons, même pour aller vers une autre page",
          "isCorrect": false,
          "points": -2,
          "index": 1,
          "metadata": {"severity": "major", "reason": "mauvaise sémantique"}
        },
        {
          "id": "MURYA_UI_Q10_C",
          "questionId": "MURYA_UI_Q10",
          "text": "Toujours des liens, même pour soumettre un formulaire",
          "isCorrect": false,
          "points": -2,
          "index": 2,
          "metadata": {"severity": "major", "reason": "mauvaise sémantique"}
        },
        {
          "id": "MURYA_UI_Q10_D",
          "questionId": "MURYA_UI_Q10",
          "text": "Peu importe : bouton ou lien, c’est la même chose",
          "isCorrect": false,
          "points": -3,
          "index": 3,
          "metadata": {"severity": "critical", "reason": "accessibilité & attentes rompues"}
        }
      ]
    }
  ]
};
