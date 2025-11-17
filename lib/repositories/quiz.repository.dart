import 'package:murya/blocs/modules/quizz/quiz_bloc.dart';
import 'package:murya/models/quiz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class QuizRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;

  QuizRepository() {
    initPrefs().then((_) {
      initialized = true;
    });
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Result<bool>> saveQuizResult(SaveQuizResults event) async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        // final Response response = await api.dio.post(
        //   '/userJobs/${event.jobId}/quiz/${event.quizId}',
        //   data: {
        //     "answers": event.dbResponses,
        //     "doneAt": DateTime.now().toDbString(),
        //   },
        // );
        Map<String, dynamic> dataBeforeQuizz = {
          "data": {
            "id": "66657715-8265-4d41-9cde-56e7934d1ad8",
            "userJobId": "c33bffbc-0fe0-49df-a228-654c957a8b67",
            "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
            "type": "POSITIONING",
            "status": "COMPLETED",
            "index": 0,
            "assignedAt": "2025-11-17T06:57:39.000Z",
            "startedAt": "2025-11-17T08:00:19.000Z",
            "completedAt": "2025-11-17T08:00:19.000Z",
            "totalScore": 1150,
            "bonusPoints": 300,
            "maxScore": 1150,
            "maxScoreWithBonus": DIAMONDS,
            "percentage": 100,
            "createdAt": "2025-11-17T06:57:39.000Z",
            "updatedAt": "2025-11-17T07:00:19.000Z"
          }
        };
        // dataBeforeQuizz = response.data;

        WE_ARE_BEFORE_QUIZZ = false;
        // return response.statusCode == 200;
        return true;
      },
      parentFunctionName: "QuizRepository.saveQuizResult",
    );
  }

  Future<Result<Quiz?>> getQuizForJob(String jobId) async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        // final Response response = await api.dio.get('/userJobs/$jobId/quiz');

        Map<String, dynamic> dataBeforeQuizz = {
          "data": {
            "id": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
            "jobId": "f3cb535f-abbc-4dc6-a2f3-2ffa8353ab73",
            "title": "Quiz 1 - Product Manager",
            "description": "Quiz de positionnement Product Manager (1/5)",
            "level": "MIX",
            "createdAt": "2025-11-17T06:48:36.000Z",
            "updatedAt": "2025-11-17T06:48:36.000Z",
            "questions": [
              {
                "id": "3e75463b-2b48-453f-868b-c24cb52a07ae",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "54284041-1964-41a0-a906-5c22c9b82bdb",
                "text":
                    "Laquelle de ces actions est la plus efficace pour comprendre les besoins réels des utilisateurs ?",
                "timeLimitInSeconds": 30,
                "points": 100,
                "level": "EASY",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 1,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "dfc95728-b163-48a2-ad71-07329e794541",
                    "questionId": "3e75463b-2b48-453f-868b-c24cb52a07ae",
                    "text": "Interviewer directement des utilisateurs sur leurs besoins",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "1b05484e-1f65-4acc-bc53-f9aa5bc80319",
                    "questionId": "3e75463b-2b48-453f-868b-c24cb52a07ae",
                    "text": "Se fier uniquement aux suppositions de l'équipe interne",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "a9f8acd1-e50b-4a5e-83f5-ad0ef2734bff",
                    "questionId": "3e75463b-2b48-453f-868b-c24cb52a07ae",
                    "text": "Écrire les spécifications sans consulter d'utilisateurs",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "c47ccb52-b13d-4893-b98f-ecb30138ef3a",
                    "questionId": "3e75463b-2b48-453f-868b-c24cb52a07ae",
                    "text": "Observer un seul utilisateur et généraliser ses besoins",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "54284041-1964-41a0-a906-5c22c9b82bdb",
                  "name": "Conduire des interviews",
                  "normalizedName": "conduire_des_interviews",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "HARD_SKILL",
                  "level": "MEDIUM",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              },
              {
                "id": "5f6fc7be-7dda-4cca-83db-3819e301b545",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "4c2555d5-631e-4f5d-9b39-08113938e7d8",
                "text":
                    "Laquelle de ces activités aide un PM débutant à mieux connaître son marché et ses concurrents ?",
                "timeLimitInSeconds": 30,
                "points": 100,
                "level": "EASY",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 2,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "258993ca-c927-45f1-aab9-aa18b34a4149",
                    "questionId": "5f6fc7be-7dda-4cca-83db-3819e301b545",
                    "text": "Réaliser une veille régulière des produits concurrents",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "a9887e2c-064a-4c20-a051-a77c77f8f355",
                    "questionId": "5f6fc7be-7dda-4cca-83db-3819e301b545",
                    "text": "Ignorer les concurrents et se concentrer uniquement sur son produit",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "9675ca3d-57b4-4eda-9245-6f39450356fe",
                    "questionId": "5f6fc7be-7dda-4cca-83db-3819e301b545",
                    "text": "Copier toutes les fonctionnalités du leader du marché sans analyse",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "6fa6e057-0b0f-4e2b-87b5-32107b350947",
                    "questionId": "5f6fc7be-7dda-4cca-83db-3819e301b545",
                    "text": "Consulter uniquement les avis des clients de son produit",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "4c2555d5-631e-4f5d-9b39-08113938e7d8",
                  "name": "Évaluer la concurrence",
                  "normalizedName": "evaluer_la_concurrence",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "HARD_SKILL",
                  "level": "HARD",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              },
              {
                "id": "7b34bd1e-bb31-40c2-8d2d-3b52e49d147f",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "b2e56af8-a8cb-4d9f-bb86-5464eee5153f",
                "text": "Quel critère est le plus important pour prioriser les fonctionnalités d'un produit ?",
                "timeLimitInSeconds": 30,
                "points": 110,
                "level": "MEDIUM",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 3,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "6e146738-a5dd-4b73-9b4d-722ac5a8aee3",
                    "questionId": "7b34bd1e-bb31-40c2-8d2d-3b52e49d147f",
                    "text": "L'impact potentiel de la fonctionnalité sur la valeur apportée aux utilisateurs",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "9411c9b4-aee6-4954-989f-39b3d4a3afcd",
                    "questionId": "7b34bd1e-bb31-40c2-8d2d-3b52e49d147f",
                    "text": "La facilité de développement de la fonctionnalité pour l'équipe technique",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "791ea42a-dc53-433a-974b-0a116c18e783",
                    "questionId": "7b34bd1e-bb31-40c2-8d2d-3b52e49d147f",
                    "text": "Le prestige de la technologie ou de la solution employée",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "3b430ffe-2253-48b6-97aa-9780a602acee",
                    "questionId": "7b34bd1e-bb31-40c2-8d2d-3b52e49d147f",
                    "text": "L'ordre chronologique de réception des demandes de fonctionnalité",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "b2e56af8-a8cb-4d9f-bb86-5464eee5153f",
                  "name": "Prioriser le backlog",
                  "normalizedName": "prioriser_le_backlog",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "HARD_SKILL",
                  "level": "HARD",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              },
              {
                "id": "d93933fd-0ac6-4915-a061-6b6e809c3bdd",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "c9d3fddc-da46-42a3-a017-14742fac3b1f",
                "text": "La roadmap produit sur 6–12 mois doit avant tout être :",
                "timeLimitInSeconds": 30,
                "points": 110,
                "level": "MEDIUM",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 4,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "6e516a2f-d9ef-46c9-bb63-83fae27fd4f5",
                    "questionId": "d93933fd-0ac6-4915-a061-6b6e809c3bdd",
                    "text": "Alignée sur la stratégie globale et régulièrement ajustée selon les retours",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "308420d6-bd71-4c9c-b44f-090bee40f320",
                    "questionId": "d93933fd-0ac6-4915-a061-6b6e809c3bdd",
                    "text": "Strictement figée dès sa validation initiale",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "44fb8d07-41b7-4de3-960c-ef5cb82e5029",
                    "questionId": "d93933fd-0ac6-4915-a061-6b6e809c3bdd",
                    "text": "Élaborée sans impliquer les parties prenantes externes ou internes",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "9715e2eb-a066-4eab-afe6-c9ed86a54a51",
                    "questionId": "d93933fd-0ac6-4915-a061-6b6e809c3bdd",
                    "text": "Communiquée uniquement à la direction, pas aux équipes opérationnelles",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "c9d3fddc-da46-42a3-a017-14742fac3b1f",
                  "name": "Planifier les releases",
                  "normalizedName": "planifier_les_releases",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "HARD_SKILL",
                  "level": "MEDIUM",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              },
              {
                "id": "d5cd8dc3-27e4-4f1e-97f3-3c7926a36fea",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "c77226b0-b51e-4c93-b972-4b2a9141228a",
                "text": "Quel est le principal objectif de l'analyse des données d'usage d'un produit ?",
                "timeLimitInSeconds": 30,
                "points": 110,
                "level": "MEDIUM",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 5,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "3ad7e36d-b2af-4c17-bf69-720ea010315d",
                    "questionId": "d5cd8dc3-27e4-4f1e-97f3-3c7926a36fea",
                    "text": "Identifier des tendances d'usage afin d'orienter les décisions produit",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "81feb302-61c0-40ee-826e-a74dc1eeb6de",
                    "questionId": "d5cd8dc3-27e4-4f1e-97f3-3c7926a36fea",
                    "text": "Confirmer sans remise en question les intuitions initiales du Product Manager",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "779b1796-fdd4-4c42-8d3f-32ac7df45562",
                    "questionId": "d5cd8dc3-27e4-4f1e-97f3-3c7926a36fea",
                    "text": "Remplacer tous les retours qualitatifs utilisateurs par de simples chiffres",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "62bd46f7-cc86-4ef3-bbcb-52552648cbfa",
                    "questionId": "d5cd8dc3-27e4-4f1e-97f3-3c7926a36fea",
                    "text": "Mesurer uniquement des indicateurs techniques comme la vitesse ou la stabilité",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "c77226b0-b51e-4c93-b972-4b2a9141228a",
                  "name": "Interpréter les données",
                  "normalizedName": "interpreter_les_donnees",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "HARD_SKILL",
                  "level": "HARD",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              },
              {
                "id": "5ac42ede-5a28-41e3-b948-312c659ceca4",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "2d8dcd7c-9765-482c-9a2f-f734a749de7f",
                "text":
                    "Laquelle de ces mesures peut servir de KPI pertinent pour suivre la performance d'un produit ?",
                "timeLimitInSeconds": 30,
                "points": 110,
                "level": "MEDIUM",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 6,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "cf92b348-d25b-4712-8dd9-13d2272ee6a2",
                    "questionId": "5ac42ede-5a28-41e3-b948-312c659ceca4",
                    "text": "Le taux de conversion des utilisateurs gratuits en clients payants",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "70e8fc95-1fde-4621-a61e-96d14384276b",
                    "questionId": "5ac42ede-5a28-41e3-b948-312c659ceca4",
                    "text": "Le nombre de réunions tenues par l'équipe produit chaque mois",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "2fd7a946-fdb1-44cd-bdc3-121abe2e3f31",
                    "questionId": "5ac42ede-5a28-41e3-b948-312c659ceca4",
                    "text": "La couleur ou le design du logo du produit",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "6dd54315-7c0c-4151-bbe3-0030cdce25a1",
                    "questionId": "5ac42ede-5a28-41e3-b948-312c659ceca4",
                    "text": "Le volume de café consommé par l'équipe de développement",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "2d8dcd7c-9765-482c-9a2f-f734a749de7f",
                  "name": "Définir les métriques",
                  "normalizedName": "definir_les_metriques",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "HARD_SKILL",
                  "level": "MEDIUM",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              },
              {
                "id": "6560cb15-f94b-4c51-b46e-e44fd898b3f1",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "ebd1f61e-d034-425e-b445-fbc251111106",
                "text":
                    "Vous pilotez un projet produit complexe impliquant plusieurs équipes. Quelle action assure un suivi efficace de bout en bout ?",
                "timeLimitInSeconds": 30,
                "points": 120,
                "level": "HARD",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 7,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "46777051-da27-40bb-8a76-12a512a59ca2",
                    "questionId": "6560cb15-f94b-4c51-b46e-e44fd898b3f1",
                    "text": "Définir dès le départ des jalons clairs et suivre régulièrement l'avancement",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "18de346a-46bc-4534-a73a-73d516daa2d6",
                    "questionId": "6560cb15-f94b-4c51-b46e-e44fd898b3f1",
                    "text": "Ne pas formaliser de plan pour garder une totale flexibilité jusqu'à la livraison",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "c8bc9db6-db46-485e-9b1a-5b9130a508dd",
                    "questionId": "6560cb15-f94b-4c51-b46e-e44fd898b3f1",
                    "text": "Communiquer uniquement en fin de projet lorsque toutes les fonctionnalités sont terminées",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "66747245-9f6b-423b-b560-188f459c30e9",
                    "questionId": "6560cb15-f94b-4c51-b46e-e44fd898b3f1",
                    "text": "Confier la coordination à chaque équipe et éviter de suivre les détails au quotidien",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "ebd1f61e-d034-425e-b445-fbc251111106",
                  "name": "Suivre l'avancement",
                  "normalizedName": "suivre_l_avancement",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "HARD_SKILL",
                  "level": "EASY",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              },
              {
                "id": "7e25250e-9e54-4910-9ef6-76293b04d902",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "0b278f8c-fe13-41d5-8688-84a2e8de34ee",
                "text":
                    "L'équipe produit passe de 1 à 5 équipes en parallèle. Quelle mesure aide à adapter les processus de développement à cette échelle ?",
                "timeLimitInSeconds": 30,
                "points": 130,
                "level": "EXPERT",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 8,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "95cea0fc-fd0d-4516-8dbf-4c018c9e0289",
                    "questionId": "7e25250e-9e54-4910-9ef6-76293b04d902",
                    "text": "Mettre en place des processus unifiés et des outils communs pour toutes les équipes",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "90462772-1969-4245-b861-60530348be17",
                    "questionId": "7e25250e-9e54-4910-9ef6-76293b04d902",
                    "text": "Laisser chaque équipe définir ses propres processus sans les harmoniser",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "ea184179-4d79-4d74-9316-4f3da07757b6",
                    "questionId": "7e25250e-9e54-4910-9ef6-76293b04d902",
                    "text":
                        "Doubler la durée des sprints de chaque équipe pour compenser les difficultés de coordination",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "2f1f6121-089e-48c3-baee-af9fd9f1310e",
                    "questionId": "7e25250e-9e54-4910-9ef6-76293b04d902",
                    "text": "Réduire la fréquence des synchronisations entre équipes pour gagner du temps",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "0b278f8c-fe13-41d5-8688-84a2e8de34ee",
                  "name": "Améliorer les processus",
                  "normalizedName": "ameliorer_les_processus",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "HARD_SKILL",
                  "level": "HARD",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              },
              {
                "id": "e719116c-3be5-4113-9e1a-485a7e28aa11",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "a61c2395-8474-4979-b249-0fd165bdf710",
                "text":
                    "Un PM n'a pas d'autorité hiérarchique sur les équipes. Comment peut-il malgré tout les mobiliser efficacement ?",
                "timeLimitInSeconds": 30,
                "points": 130,
                "level": "EXPERT",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 9,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "1c432f97-fca6-4a20-a4ab-35e2711c54eb",
                    "questionId": "e719116c-3be5-4113-9e1a-485a7e28aa11",
                    "text": "En partageant une vision claire du produit et en instaurant un climat de confiance",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "4da01fca-d760-4e01-9ef6-fca9b51e979d",
                    "questionId": "e719116c-3be5-4113-9e1a-485a7e28aa11",
                    "text": "En rappelant constamment aux équipes qu'il est le « chef » du produit",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "82058ecd-91e9-4222-af16-e7ab33393e36",
                    "questionId": "e719116c-3be5-4113-9e1a-485a7e28aa11",
                    "text": "En demandant à son supérieur hiérarchique d'imposer les tâches aux équipes",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "5a0d4f2a-13fb-4288-a2cf-090cfc73e042",
                    "questionId": "e719116c-3be5-4113-9e1a-485a7e28aa11",
                    "text": "En écartant les avis de l'équipe pour prendre les décisions de manière autonome",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "a61c2395-8474-4979-b249-0fd165bdf710",
                  "name": "Porter la vision produit",
                  "normalizedName": "porter_la_vision_produit",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "SOFT_SKILL",
                  "level": "EXPERT",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              },
              {
                "id": "3ce09ef6-0650-4b54-9057-178907facd40",
                "quizId": "bcbadd8a-db8b-49a1-ba4a-479626bb9a65",
                "competencyId": "44fa51f1-c2db-40f4-9d2a-2feeceb99700",
                "text":
                    "Quelle est une bonne pratique pour un PM expérimenté qui mentore des membres juniors de son équipe produit ?",
                "timeLimitInSeconds": 30,
                "points": 130,
                "level": "EXPERT",
                "type": "single_choice",
                "mediaUrl": "",
                "index": 10,
                "metadata": null,
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "responses": [
                  {
                    "id": "146e9537-f498-427c-84d9-29902b5e5113",
                    "questionId": "3ce09ef6-0650-4b54-9057-178907facd40",
                    "text": "Partager régulièrement son expérience et fournir des conseils adaptés à chaque membre",
                    "metadata": null,
                    "isCorrect": true,
                    "index": 0,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "68505819-1af1-4500-9bd2-d1bf6c3efcb2",
                    "questionId": "3ce09ef6-0650-4b54-9057-178907facd40",
                    "text": "Réaliser le travail à leur place pour assurer la qualité du résultat final",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 1,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "ad25026f-053b-4b93-b597-0d3f951d6845",
                    "questionId": "3ce09ef6-0650-4b54-9057-178907facd40",
                    "text": "Souligner publiquement chacune de leurs erreurs pour qu'ils apprennent plus vite",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 2,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  },
                  {
                    "id": "69a33162-4ed9-4514-81e6-f25e5e6487ce",
                    "questionId": "3ce09ef6-0650-4b54-9057-178907facd40",
                    "text": "Garder ses connaissances pour lui afin de conserver un avantage sur les autres",
                    "metadata": null,
                    "isCorrect": false,
                    "index": 3,
                    "createdAt": "2025-11-17T06:48:36.000Z",
                    "updatedAt": "2025-11-17T06:48:36.000Z",
                    "answerOptions": []
                  }
                ],
                "competency": {
                  "id": "44fa51f1-c2db-40f4-9d2a-2feeceb99700",
                  "name": "Développer les talents",
                  "normalizedName": "developper_les_talents",
                  "beginnerScore": 1,
                  "intermediateScore": 2.5,
                  "advancedScore": 3.75,
                  "expertScore": 4.5,
                  "maxScore": 5,
                  "type": "SOFT_SKILL",
                  "level": "MEDIUM",
                  "createdAt": "2025-11-17T06:48:36.000Z",
                  "updatedAt": "2025-11-17T06:48:36.000Z"
                }
              }
            ]
          }
        };
        Map<String, dynamic> dataAfterQuizz = {};
        // dataBeforeQuizz = response.data;

        return Quiz.fromJson((WE_ARE_BEFORE_QUIZZ ? dataBeforeQuizz : dataAfterQuizz)["data"]);
      },
      parentFunctionName: "QuizRepository.getQuizForJob",
    );
  }
}
