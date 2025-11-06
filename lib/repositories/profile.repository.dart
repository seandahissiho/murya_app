import 'package:dio/dio.dart';
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
        final Response response = await api.dio.get('/auth/me');
        return User.fromJson(response.data["data"]);
      },
      parentFunctionName: "ProfileRepository.getMe",
    );
  }
}
