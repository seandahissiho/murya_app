import 'package:dio/dio.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/services/cache.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class ProfileRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;
  final CacheService cacheService;

  ProfileRepository({CacheService? cacheService})
      : cacheService = cacheService ?? CacheService() {
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

        if (response.data["data"] != null) {
          await cacheService.save('user_profile_me', response.data["data"]);
        }

        return User.fromJson(response.data["data"]);
      },
      parentFunctionName: "ProfileRepository.getMe",
      errorResult: User.empty(),
    );
  }

  Future<Result<User>> getMeCached() async {
    try {
      final cachedData = await cacheService.get('user_profile_me');
      if (cachedData != null) {
        final User user = User.fromJson(cachedData);
        return Result.success(user, null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(User.empty(), null);
  }
}
