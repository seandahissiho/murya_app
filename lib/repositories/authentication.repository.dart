import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class AuthenticationRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;

  AuthenticationRepository() {
    initPrefs().then((_) {
      initialized = true;
    });
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Result<(String, String)?>> getToken() async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        // get refresh token from shared preferences
        String? refreshToken = prefs.getString("refresh_token");
        if (refreshToken == null) {
          throw '';
        }

        // retrieve new access token from the server
        // final Response response = await Dio(BaseOptions(
        //     baseUrl: ApiEndPoint.baseUrl,
        //     receiveTimeout: const Duration(seconds: 120),
        //     connectTimeout: const Duration(seconds: 120),
        //     headers: {
        //       'Accept': 'application/json',
        //       'Content-Type': 'application/json',
        //       'Charset': 'utf-8',
        //     })).post(
        //   '/auth/refresh',
        //   data: {
        //     "refresh_token": refreshToken,
        //   },
        // );

        Map<String, dynamic> dataBeforeQuizz = {};
        Map<String, dynamic> dataAfterQuizz = {};

        final String accessToken = dataBeforeQuizz["data"]["access_token"];
        refreshToken = dataBeforeQuizz["data"]?["refresh_token"] ?? refreshToken;
        // final User user = User.fromJson(response.data["data"]["user"]);
        return (accessToken, refreshToken);
      },
      parentFunctionName: "AuthenticationRepository.getToken",
    );
  }

  Future<Result<bool>> signUp({required Map<String, dynamic> data}) async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final Response response = await api.dio.post(
          '/auth/signup',
          data: data,
        );
        return ResultWithMessage(
          response.statusCode == 201,
          response.data["message"] as String,
        );
      },
      parentFunctionName: "AuthenticationRepository.signUp",
    );
  }

  Future<Result<(String, String)>> signIn({required Map<String, dynamic> data}) async {
    return AppResponse.execute(
      action: () async {
        final Response response = await api.dio.post(
          '/auth/signin',
          data: data,
        );
        final String accessToken = response.data["data"]["access_token"];
        final String refreshToken = response.data["data"]["refresh_token"];
        // final User user = User.fromJson(response.data["data"]["user"]);

        // save refresh token to shared preferences
        prefs.setString("refresh_token", refreshToken);

        return (accessToken, refreshToken);
      },
      parentFunctionName: "AuthenticationRepository.signIn",
    );
  }

  Future<void> deleteToken() async {
    await prefs.remove("refresh_token");
  }

  Future<Result<bool>> signOut() async {
    return AppResponse.execute(
      action: () async {
        await prefs.remove("access_token");
        await deleteToken();
        return true;
      },
      parentFunctionName: "AuthenticationRepository.signOut",
    );
  }

  Future<Result<(String, String)>> register({required Map<String, dynamic> data}) async {
    return AppResponse.execute(
      action: () async {
        final Response response = await api.dio.post(
          '/auth/register',
          data: data,
        );
        final String accessToken = response.data["data"]["access_token"];
        final String refreshToken = response.data["data"]["refresh_token"];
        // final User user = User.fromJson(response.data["data"]["user"]);

        // save refresh token to shared preferences
        prefs.setString("refresh_token", refreshToken);

        return (accessToken, refreshToken);
      },
      parentFunctionName: "AuthenticationRepository.register",
    );
  }

  Future<Result<(String, String)>> registerTemp({required Map<String, dynamic> data}) async {
    return AppResponse.execute(
      action: () async {
        // final Response response = await api.dio.post(
        //   '/auth/register',
        //   data: data,
        // );
        Map<String, dynamic> dataBeforeQuizz = {
          "message": "Utilisateur enregistré avec succès",
          "data": {
            "access_token":
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI4YzQ3MTY5Mi0wZGZlLTQ1NGQtODFlMi04YzA2OTVhYTA0NjgiLCJ1c2VyUm9sZSI6IjZmMDBhMTMyLWY1NTUtNDYwMC1iMWJjLTg5ZWE1OGM3OThlYSIsImlzQWRtaW4iOmZhbHNlLCJpYXQiOjE3NjMzNjI2MTIsImV4cCI6MTc2MzM5MTQxMn0.Ka4fVHSMmMFgLbHq6YlP-Iu8Pi8YYVnNqXdUFuw4Br8",
            "refresh_token":
                "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI4YzQ3MTY5Mi0wZGZlLTQ1NGQtODFlMi04YzA2OTVhYTA0NjgiLCJ1c2VyUm9sZSI6IjZmMDBhMTMyLWY1NTUtNDYwMC1iMWJjLTg5ZWE1OGM3OThlYSIsImlzQWRtaW4iOmZhbHNlLCJpYXQiOjE3NjMzNjI2MTIsImV4cCI6MTc2NDU3MjIxMn0.3hsD112hXSvlRVu4K315wxUJjFL7Rf64r9nF07FMr5c"
          }
        };
        Map<String, dynamic> dataAfterQuizz = {};
        // dataBeforeQuizz = response.data;
        final String accessToken = (WE_ARE_BEFORE_QUIZZ ? dataBeforeQuizz : dataAfterQuizz)["data"]["access_token"];
        final String refreshToken = (WE_ARE_BEFORE_QUIZZ ? dataBeforeQuizz : dataAfterQuizz)["data"]["refresh_token"];
        // final User user = User.fromJson(response.data["data"]["user"]);

        // save refresh token to shared preferences
        prefs.setString("refresh_token", refreshToken);
        WE_ARE_BEFORE_FIRST_USER_FETCH = false;

        return (accessToken, refreshToken);
      },
      parentFunctionName: "AuthenticationRepository.registerTemp",
    );
  }

  void clearTokens() {
    prefs.remove("refresh_token");
    prefs.remove("access_token");
  }
}
