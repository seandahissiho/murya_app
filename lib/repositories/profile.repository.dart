import 'package:murya/models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class ProfileRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;

  ProfileRepository() {
    initPrefs().then((_) {
      initialized = true;
    });
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Result<User>> getMe() async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        // final Response response = await api.dio.get('/auth/me');

        Map<String, dynamic> dataBeforeQuizz = WE_ARE_BEFORE_FIRST_USER_FETCH
            ? {}
            : {
                "message": "Informations de l'utilisateur récupérées avec succès",
                "data": {
                  "id": "8c471692-0dfe-454d-81e2-8c0695aa0468",
                  "firstname": null,
                  "lastname": null,
                  "email": null,
                  "phone": null,
                  "deviceId": "CF0249B2-DF6C-4B15-B25E-26995FD2BFD7",
                  "password": null,
                  "diamonds": 0,
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
                  "updatedById": null,
                  "role": {
                    "id": "6f00a132-f555-4600-b1bc-89ea58c798ea",
                    "name": "UNIDENTIFIED",
                    "createdAt": "2025-11-17T06:48:12.000Z",
                    "updatedAt": "2025-11-17T06:48:12.000Z"
                  }
                }
              };
        Map<String, dynamic> dataAfterQuizz = {
          "message": "Informations de l'utilisateur récupérées avec succès",
          "data": {
            "id": "8c471692-0dfe-454d-81e2-8c0695aa0468",
            "firstname": null,
            "lastname": null,
            "email": null,
            "phone": null,
            "deviceId": "CF0249B2-DF6C-4B15-B25E-26995FD2BFD7",
            "password": null,
            "diamonds": 1450,
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
            "updatedById": null,
            "role": {
              "id": "6f00a132-f555-4600-b1bc-89ea58c798ea",
              "name": "UNIDENTIFIED",
              "createdAt": "2025-11-17T06:48:12.000Z",
              "updatedAt": "2025-11-17T06:48:12.000Z"
            }
          }
        };
        // dataBeforeQuizz = response.data;

        return User.fromJson((WE_ARE_BEFORE_QUIZZ ? dataBeforeQuizz : dataAfterQuizz)["data"]);
      },
      parentFunctionName: "ProfileRepository.getMe",
      errorResult: User.empty(),
    );
  }
}
