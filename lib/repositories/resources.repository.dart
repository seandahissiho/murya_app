import 'package:murya/models/resource.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class ResourcesRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;

  ResourcesRepository() {
    initPrefs().then((_) {
      initialized = true;
    });
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Result<Resource?>> generateResource({required ResourceType type, required String userJobId}) async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        DIAMONDS -= 1000;
        // final Response response = await api.dio.post(
        //   '/userJobs/generateArticle/$userJobId',
        // );

        Map<String, dynamic> dataBeforeQuizz = {};
        Map<String, dynamic> dataAfterQuizz = {
          "data": {
            "id": "559f8b37-ec31-42d1-aa54-ae36fc27b9fd",
            "scope": "USER_JOB",
            "type": "ARTICLE",
            "source": "AI_GENERATED",
            "jobId": "f3cb535f-abbc-4dc6-a2f3-2ffa8353ab73",
            "userJobId": "c33bffbc-0fe0-49df-a228-654c957a8b67",
            "title": "Plan d'apprentissage personnalisé - Product Manager",
            "slug": null,
            "description": "Article généré à partir de la dernière évaluation (100% de réussite).",
            "content":
                "# Devenir un As du Product Management: Le Guide\n\nParlons du rôle d'un Product Manager (PM). Un métier fascinant et complexe qui ressemble beaucoup à jongler avec plusieurs balles en l'air tout en gardant l'œil sur la cible. Vous avez récemment passé une évaluation de vos compétences en tant que PM et, devinez quoi, vous avez fait un sans-faute. Félicitations! Mais ce n'est pas le moment de se reposer sur ses lauriers, n'est-ce pas? Alors, plongeons dans le vif du sujet.\n\n## Une journée dans la vie d'un Product Manager\n\nUn PM est un peu comme le chef d'orchestre d'une symphonie technologique. Vous conduisez des interviews pour comprendre les besoins des utilisateurs, évaluez la concurrence pour garder une longueur d'avance, et vous priorisez le backlog pour assurer une progression constante. Vous planifiez les releases comme un maestro, interprétez les données comme un détective et définissez les métriques comme un scientifique. Vous suivez l'avancement des projets comme un faucon, améliorez les processus pour plus d'efficacité et portez la vision du produit avec passion. Et en plus de tout cela, vous développez les talents de votre équipe. C'est un rôle exigeant, mais incroyablement gratifiant.\n\n## L'évaluation révèle...\n\nVotre évaluation a montré que vous maîtrisez bien la plupart des compétences clés. Vous savez comment conduire des interviews pour comprendre les besoins des utilisateurs, et comment évaluer la concurrence pour rester compétitif. Vous avez une bonne compréhension de comment prioriser le backlog, planifier les releases et interpréter les données. Vous savez aussi définir les métriques, suivre l'avancement, améliorer les processus, porter la vision du produit et développer les talents. C'est impressionnant!\n\n## Conseils pour progresser\n\nPour aller plus loin, je vous suggère de vous concentrer sur deux aspects. Tout d'abord, la communication. Même si vous n'avez pas d'autorité hiérarchique sur les équipes, vous pouvez les mobiliser efficacement en communiquant clairement et de manière inspirante la vision du produit. Pensez à Steve Jobs présentant l'iPhone pour la première fois. \n\nEnsuite, investissez du temps pour développer les talents de votre équipe. Un bon PM est aussi un bon mentor. Si vous voyez un membre junior de votre équipe qui a du potentiel, prenez-le sous votre aile. Partagez votre expérience, donnez-lui des conseils et des retours constructifs. \n\n## En route pour la réussite\n\nEn tant que PM, votre parcours d'apprentissage ne s'arrête jamais. Chaque jour apporte de nouveaux défis et de nouvelles opportunités pour grandir. Continuez à affiner vos compétences, à chercher des façons de vous améliorer et à rester curieux. Et n'oubliez pas, votre succès en tant que PM ne se mesure pas seulement à la performance du produit, mais aussi à la croissance de votre équipe. Alors, allons-y, il est temps de créer des produits incroyables et de développer des équipes exceptionnelles!\n",
            "mediaUrl": null,
            "thumbnailUrl": null,
            "languageCode": null,
            "estimatedDuration": null,
            "metadata": null,
            "createdAt": "2025-11-17T07:11:36.000Z",
            "updatedAt": "2025-11-17T07:11:36.000Z",
            "createdById": "8c471692-0dfe-454d-81e2-8c0695aa0468",
            "updatedById": null,
            "createdBy": {
              "id": "8c471692-0dfe-454d-81e2-8c0695aa0468",
              "firstname": null,
              "lastname": null,
              "email": null,
              "phone": null,
              "deviceId": "CF0249B2-DF6C-4B15-B25E-26995FD2BFD7",
              "password": null,
              "diamonds": DIAMONDS,
              "isActive": true,
              "isAdmin": false,
              "createdAt": "2025-11-17T06:56:52.000Z",
              "lastLogin": "2025-11-17T06:56:52.000Z",
              "avatarUrl": null,
              "birthDate": null,
              "genre": "UNDEFINED",
              "roleId": "6f00a132-f555-4600-b1bc-89ea58c798ea",
              "refreshToken":
                  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI4YzQ3MTY5Mi0wZGZlLTQ1NGQtODFlMi04YzA2OTVhYTA0NjgiLCJ1c2VyUm9sZSI6IjZmMDBhMTMyLWY1NTUtNDYwMC1iMWJjLTg5ZWE1OGM3OThlYSIsImlzQWRtaW4iOmZhbHNlLCJpYXQiOjE3NjMzNjI2MTIsImV4cCI6MTc2NDU3MjIxMn0.3hsD112hXSvlRVu4K315wxUJjFL7Rf64r9nF07FMr5c",
              "addressId": null,
              "preferredLangCode": null,
              "createdById": null,
              "updatedById": null
            }
          }
        };
        // dataBeforeQuizz = response.data;

        return Resource.fromJson((WE_ARE_BEFORE_QUIZZ ? dataBeforeQuizz : dataAfterQuizz)["data"]);
      },
      parentFunctionName: "ResourcesRepository.generateResource",
    );
  }
}
