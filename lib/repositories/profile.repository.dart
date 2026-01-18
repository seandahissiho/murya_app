import 'package:dio/dio.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/quest.dart';
import 'package:murya/services/cache.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class ProfileRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;
  final CacheService cacheService;

  ProfileRepository({CacheService? cacheService}) : cacheService = cacheService ?? CacheService() {
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

  Future<Result<QuestList>> getQuests({
    required QuestScope scope,
    String? timezone,
    String? userJobId,
  }) async {
    if (scope == QuestScope.userJob && (userJobId == null || userJobId.isEmpty)) {
      return Result.failure('userJobId is required for USER_JOB scope');
    }
    return AppResponse.execute(
      action: () async {
        final queryParameters = <String, dynamic>{
          'scope': scope.apiValue,
          if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
          if (scope != QuestScope.user && userJobId != null && userJobId.isNotEmpty) 'userJobId': userJobId,
        };
        final Response response = await api.dio.get('/quests', queryParameters: queryParameters);
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        return QuestList.fromJson(Map<String, dynamic>.from(data));
      },
      parentFunctionName: 'ProfileRepository.getQuests',
      errorResult: QuestList.empty(),
    );
  }

  Future<Result<QuestGroupList>> getQuestGroups({
    required QuestScope scope,
    String? timezone,
    String? userJobId,
  }) async {
    if (scope == QuestScope.userJob && (userJobId == null || userJobId.isEmpty)) {
      return Result.failure('userJobId is required for USER_JOB scope');
    }
    return AppResponse.execute(
      action: () async {
        final queryParameters = <String, dynamic>{
          'scope': scope.apiValue,
          if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
          if (scope != QuestScope.user && userJobId != null && userJobId.isNotEmpty) 'userJobId': userJobId,
        };
        final Response response = await api.dio.get('/quest-groups', queryParameters: queryParameters);
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        return QuestGroupList.fromJson(Map<String, dynamic>.from(data));
      },
      parentFunctionName: 'ProfileRepository.getQuestGroups',
      errorResult: QuestGroupList.empty(),
    );
  }

  Future<Result<QuestInstance>> claimUserJobQuest(String questId) async {
    return AppResponse.execute(
      action: () async {
        final Response response = await api.dio.post('/user-job-quests/$questId/claim');
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        return QuestInstance.fromJson(Map<String, dynamic>.from(data));
      },
      parentFunctionName: 'ProfileRepository.claimUserJobQuest',
      errorResult: QuestInstance.empty(),
    );
  }

  Future<Result<QuestInstance>> claimUserQuest(String questId) async {
    return AppResponse.execute(
      action: () async {
        final Response response = await api.dio.post('/user-quests/$questId/claim');
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        return QuestInstance.fromJson(Map<String, dynamic>.from(data));
      },
      parentFunctionName: 'ProfileRepository.claimUserQuest',
      errorResult: QuestInstance.empty(),
    );
  }
}
