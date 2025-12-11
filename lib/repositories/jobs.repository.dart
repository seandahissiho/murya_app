import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/job_ranking.dart';
import 'package:murya/models/user_job_competency_profile.dart';
import 'package:murya/repositories/base.repository.dart';

class JobRepository extends BaseRepository {
  JobRepository();

  Future<Result<List<Job>>> searchJobs({
    required String query,
  }) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get(
          '/jobs/',
          queryParameters: {
            'query': query,
          },
        );
        Map<String, dynamic> dataBeforeQuizz = {
          "data": {
            "items": [
              {
                "id": "f3cb535f-abbc-4dc6-a2f3-2ffa8353ab73",
                "jobFamilyId": null,
                "title": "Product Manager",
                "slug": "product_manager",
                "description":
                    "Responsable de la vision, de la stratégie et de la livraison du produit, en coordonnant équipes et parties prenantes pour maximiser la valeur client et business.",
                "createdAt": "2025-11-17T06:48:36.000Z",
                "updatedAt": "2025-11-17T06:48:36.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-2",
                "jobFamilyId": null,
                "title": "Product Owner",
                "slug": "product_owner",
                "description":
                    "Garant du backlog produit, responsable de la définition des besoins, de la priorisation et de la valeur délivrée à chaque itération.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-3",
                "jobFamilyId": null,
                "title": "Agile Master",
                "slug": "agile_master",
                "description":
                    "Facilite les pratiques agiles, optimise les processus d’équipe et élimine les obstacles pour garantir un rythme de livraison constant et efficace.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-4",
                "jobFamilyId": null,
                "title": "UX Designer",
                "slug": "ux_designer",
                "description":
                    "Conçoit des expériences utilisateur fluides et intuitives grâce à la recherche, l’analyse comportementale et la création de parcours optimisés.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-5",
                "jobFamilyId": null,
                "title": "UI Designer",
                "slug": "ui_designer",
                "description":
                    "Crée l’interface visuelle du produit, en définissant les maquettes, les systèmes graphiques et l’esthétique globale pour garantir cohérence et efficacité.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-6",
                "jobFamilyId": null,
                "title": "Product Designer",
                "slug": "product_designer",
                "description":
                    "Assure la conception globale du produit, combinant recherche utilisateur, UX, UI et stratégie design pour maximiser la valeur et la satisfaction client.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-7",
                "jobFamilyId": null,
                "title": "Développeur Frontend",
                "slug": "developpeur_frontend",
                "description":
                    "Développe les interfaces utilisateur en utilisant les technologies web modernes, garantissant performance, accessibilité et fluidité.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-8",
                "jobFamilyId": null,
                "title": "Développeur Backend",
                "slug": "developpeur_backend",
                "description":
                    "Conçoit et maintient les services, bases de données et API garantissant la logique métier, la sécurité et les performances du système.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-9",
                "jobFamilyId": null,
                "title": "Développeur Fullstack",
                "slug": "developpeur_fullstack",
                "description":
                    "Travaille sur le frontend et le backend, garantissant cohérence, performance et rapidité de livraison sur l’ensemble du produit.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-10",
                "jobFamilyId": null,
                "title": "Content Manager",
                "slug": "content_manager",
                "description":
                    "Planifie, crée et optimise les contenus éditoriaux pour renforcer la visibilité, la crédibilité et l’engagement des audiences ciblées.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-11",
                "jobFamilyId": null,
                "title": "Community Manager",
                "slug": "community_manager",
                "description":
                    "Gère et anime les communautés en ligne, crée du contenu engageant et assure le lien entre marque et utilisateurs.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-12",
                "jobFamilyId": null,
                "title": "Growth Marketer",
                "slug": "growth_marketer",
                "description":
                    "Optimise l’acquisition, l’activation et la rétention grâce à des stratégies data-driven, des expérimentations rapides et des optimisations continues.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-13",
                "jobFamilyId": null,
                "title": "Data Analyst",
                "slug": "data_analyst",
                "description":
                    "Analyse et interprète les données afin d’aider à la prise de décision, via des tableaux de bord, des études et des recommandations concrètes.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-14",
                "jobFamilyId": null,
                "title": "Data Scientist",
                "slug": "data_scientist",
                "description":
                    "Crée des modèles avancés, explore les données et met en place des solutions prédictives pour générer de la valeur à partir de la donnée.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              },
              {
                "id": "uuid-15",
                "jobFamilyId": null,
                "title": "IT Specialist",
                "slug": "it_specialist",
                "description":
                    "Assure le support technique, la maintenance des systèmes, la sécurité et le bon fonctionnement des environnements informatiques.",
                "createdAt": "2025-11-17T04:54:55.000Z",
                "updatedAt": "2025-11-17T04:54:55.000Z",
                "isActive": true,
                "popularity": 0,
                "backgroundColor": "#FFFFFFFF",
                "foregroundColor": "#FFFFFFFF",
                "textColor": "#FFFFFFFF",
                "overlayColor": "#FFFFFFFF",
                "imageIndex": 0,
                "jobFamily": null
              }
            ],
            "pagination": {"page": 1, "perPage": 20, "total": 1, "totalPages": 1}
          }
        };
        Map<String, dynamic> dataAfterQuizz = dataBeforeQuizz;
        // dataBeforeQuizz = response.data;

        final List<Job> jobs =
            (response.data["data"]['items'] as List).map((jobJson) => Job.fromJson(jobJson)).toList();
        return jobs.whereOrEmpty((job) => job.title.toLowerCase().contains(query.toLowerCase()) ?? false).toList();
      },
      parentFunctionName: 'JobRepository -> getJob',
      errorResult: <Job>[],
    );
  }

  Future<Result<Job>> getJobDetails(String jobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/jobs/$jobId/');

        final Job job = Job.fromJson(response.data["data"]);
        return job;
      },
      parentFunctionName: 'JobRepository -> getJobDetails',
    );
  }

  // getUserCurrentJob
  Future<Result<UserJob?>> getUserCurrentJob() async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/current/');

        final UserJob? job = response.data["data"] != null ? UserJob.fromJson(response.data["data"]) : null;
        return job;
      },
      parentFunctionName: 'JobRepository -> getUserCurrentJob',
    );
  }

  // getUserJobDetails
  Future<Result<UserJob>> getUserJobDetails(String jobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/$jobId/');

        final UserJob job = UserJob.fromJson(response.data["data"]);
        return job;
      },
      parentFunctionName: 'JobRepository -> getUserJobDetails',
    );
  }

  Future<Result<(CompetencyFamily, Job)>> getCFDetails(String jobId, String cfId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/jobs/$jobId/competency_families/$cfId/');

        final familyJson = response.data["data"]['family'];
        familyJson['competencies'] = response.data["data"]['competencies'];
        final CompetencyFamily cfamily = CompetencyFamily.fromJson(familyJson);
        final Job job = Job.fromJson(response.data["data"]['job']);
        return (cfamily, job);
      },
      parentFunctionName: 'JobRepository -> getCFDetails',
    );
  }

  // /leaderboard/job/:jobId
  Future<Result<JobRankings>> getRankingForJob(String jobId, DateTime? from, DateTime? to) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/leaderboard/job/$jobId/', queryParameters: {
          if (from != null) 'from': from.toDbString(),
          if (to != null) 'to': to.toDbString(),
        });
        Map<String, dynamic> dataBeforeQuizz = {};
        Map<String, dynamic> dataAfterQuizz = {
          "data": {
            "jobId": "f3cb535f-abbc-4dc6-a2f3-2ffa8353ab73",
            "from": "2025-11-17T00:00:00.000Z",
            "to": "2025-11-17T23:59:59.000Z",
            "count": 3,
            "results": [
              {
                "userJobId": "237373d8-db97-4c39-bb53-e2c179ca590e",
                "userId": "6af14fff-dd37-4b18-9500-6775157fc66f",
                "firstname": null,
                "lastname": null,
                "jobId": "f3cb535f-abbc-4dc6-a2f3-2ffa8353ab73",
                "jobTitle": "Product Manager",
                "totalScore": 1150,
                "maxScoreSum": 1150,
                "percentage": 100,
                "completedQuizzes": 1,
                "lastQuizAt": "2025-11-17T12:44:14.000Z",
                "rank": 1
              },
              {
                "userJobId": "8f7215cd-86ec-4c40-8a11-7e4f3fde0fa1",
                "userId": "481d226b-b7df-4e11-935c-0401b7d752cd",
                "firstname": null,
                "lastname": null,
                "jobId": "f3cb535f-abbc-4dc6-a2f3-2ffa8353ab73",
                "jobTitle": "Product Manager",
                "totalScore": 820,
                "maxScoreSum": 1150,
                "percentage": 71.3,
                "completedQuizzes": 1,
                "lastQuizAt": "2025-11-17T12:48:16.000Z",
                "rank": 2
              },
              {
                "userJobId": "c33bffbc-0fe0-49df-a228-654c957a8b67",
                "userId": "8c471692-0dfe-454d-81e2-8c0695aa0468",
                "firstname": null,
                "lastname": null,
                "jobId": "f3cb535f-abbc-4dc6-a2f3-2ffa8353ab73",
                "jobTitle": "Product Manager",
                "totalScore": 210,
                "maxScoreSum": 1150,
                "percentage": 18.26,
                "completedQuizzes": 1,
                "lastQuizAt": "2025-11-17T12:53:33.000Z",
                "rank": 3
              }
            ]
          }
        };
        // dataAfterQuizz = response.data;

        final JobRankings ranking = JobRankings.fromJson(response.data["data"]);
        return ranking;
      },
      parentFunctionName: 'JobRepository -> getRankingForJob',
      errorResult: JobRankings.empty(),
    );
  }

  // Future<Result<UserJobCompetencyProfile>> fetchUserJobCompetencyProfile
  Future<Result<UserJobCompetencyProfile>> fetchUserJobCompetencyProfile(String userJobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/$userJobId/competenciesProfile/');

        final UserJobCompetencyProfile profile = UserJobCompetencyProfile.fromJson(response.data["data"]);
        return profile;
      },
      parentFunctionName: 'JobRepository -> fetchUserJobCompetencyProfile',
    );
  }
}
