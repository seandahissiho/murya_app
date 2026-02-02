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

  ProfileRepository({CacheService? cacheService})
      : cacheService = cacheService ?? CacheService() {
    initPrefs().then((_) {
      initialized = true;
    });
  }

  String _questCacheKey(String type, QuestScope scope, String? timezone,
      String? userJobId, String languageCode) {
    final tz = timezone != null && timezone.isNotEmpty ? timezone : 'null';
    final jobId =
        userJobId != null && userJobId.isNotEmpty ? userJobId : 'null';
    return 'quests_${type}_${scope.apiValue}_${tz}_${jobId}_$languageCode';
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Result<User>> getMe() async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final Response response = await api.dio.get('/auth/me');

        if (response.data["data"] != null) {
          await cacheService.save(
              'user_profile_me_$languageCode', response.data["data"]);
        }

        return User.fromJson(response.data["data"]);
      },
      parentFunctionName: "ProfileRepository.getMe",
      errorResult: User.empty(),
    );
  }

  Future<Result<User>> getMeCached() async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    try {
      final cachedData =
          await cacheService.get('user_profile_me_$languageCode');
      if (cachedData != null) {
        final User user = User.fromJson(cachedData);
        return Result.success(user, null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(User.empty(), null);
  }

  // update Me
  Future<Result<User>> updateMe(User updatedUser, {User? baseline}) async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    return AppResponse.execute(
      action: () async {
        final Response response = await api.dio
            .put('/auth/me', data: updatedUser.toJson(baseline: baseline));
        if (response.data["data"] != null) {
          await cacheService.save(
              'user_profile_me_$languageCode', response.data["data"]);
        }
        return User.fromJson(response.data["data"]);
      },
      parentFunctionName: "ProfileRepository.updateMe",
      errorResult: User.empty(),
    );
  }

  Future<Result<QuestList>> getQuests({
    required QuestScope scope,
    String? timezone,
    String? userJobId,
  }) async {
    if (scope == QuestScope.userJob &&
        (userJobId == null || userJobId.isEmpty)) {
      return Result.failure('userJobId is required for USER_JOB scope');
    }
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    return AppResponse.execute(
      action: () async {
        final queryParameters = <String, dynamic>{
          'scope': scope.apiValue,
          if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
          if (scope != QuestScope.user &&
              userJobId != null &&
              userJobId.isNotEmpty)
            'userJobId': userJobId,
        };
        final Response response =
            await api.dio.get('/quests', queryParameters: queryParameters);
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        await cacheService.save(
          _questCacheKey('list', scope, timezone, userJobId, languageCode),
          Map<String, dynamic>.from(data),
        );
        return QuestList.fromJson(Map<String, dynamic>.from(data));
      },
      parentFunctionName: 'ProfileRepository.getQuests',
      errorResult: QuestList.empty(),
    );
  }

  Future<Result<QuestList>> getQuestsCached({
    required QuestScope scope,
    String? timezone,
    String? userJobId,
  }) async {
    if (scope == QuestScope.userJob &&
        (userJobId == null || userJobId.isEmpty)) {
      return Result.failure('userJobId is required for USER_JOB scope');
    }
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    try {
      final cachedData = await cacheService.get(
          _questCacheKey('list', scope, timezone, userJobId, languageCode));
      if (cachedData != null) {
        return Result.success(
            QuestList.fromJson(Map<String, dynamic>.from(cachedData)), null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(QuestList.empty(), null);
  }

  Future<Result<QuestGroupList>> getQuestGroups({
    required QuestScope scope,
    String? timezone,
    String? userJobId,
  }) async {
    if (scope == QuestScope.userJob &&
        (userJobId == null || userJobId.isEmpty)) {
      return Result.failure('userJobId is required for USER_JOB scope');
    }
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    return AppResponse.execute(
      action: () async {
        final queryParameters = <String, dynamic>{
          'scope': scope.apiValue,
          if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
          if (scope != QuestScope.user &&
              userJobId != null &&
              userJobId.isNotEmpty)
            'userJobId': userJobId,
        };
        final Response response = await api.dio
            .get('/quest-groups', queryParameters: queryParameters);
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        await cacheService.save(
          _questCacheKey('groups', scope, timezone, userJobId, languageCode),
          Map<String, dynamic>.from(data),
        );
        return QuestGroupList.fromJson(Map<String, dynamic>.from(data));
      },
      parentFunctionName: 'ProfileRepository.getQuestGroups',
      errorResult: QuestGroupList.empty(),
    );
  }

  Future<Result<QuestGroupList>> getQuestGroupsCached({
    required QuestScope scope,
    String? timezone,
    String? userJobId,
  }) async {
    if (scope == QuestScope.userJob &&
        (userJobId == null || userJobId.isEmpty)) {
      return Result.failure('userJobId is required for USER_JOB scope');
    }
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    try {
      final cachedData = await cacheService.get(
          _questCacheKey('groups', scope, timezone, userJobId, languageCode));
      if (cachedData != null) {
        return Result.success(
            QuestGroupList.fromJson(Map<String, dynamic>.from(cachedData)),
            null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(QuestGroupList.empty(), null);
  }

  Future<Result<QuestLineage>> getQuestLineage({
    required QuestScope scope,
    String? timezone,
    String? userJobId,
  }) async {
    if (scope == QuestScope.userJob &&
        (userJobId == null || userJobId.isEmpty)) {
      return Result.failure('userJobId is required for USER_JOB scope');
    }
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    return AppResponse.execute(
      action: () async {
        final queryParameters = <String, dynamic>{
          'scope': scope.apiValue,
          if (timezone != null && timezone.isNotEmpty) 'timezone': timezone,
          if (scope != QuestScope.user &&
              userJobId != null &&
              userJobId.isNotEmpty)
            'userJobId': userJobId,
        };
        final Response response = await api.dio
            .get('/quests/lineage', queryParameters: queryParameters);
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        await cacheService.save(
          _questCacheKey('lineage', scope, timezone, userJobId, languageCode),
          Map<String, dynamic>.from(data),
        );
        return QuestLineage.fromJson(Map<String, dynamic>.from(data));
      },
      parentFunctionName: 'ProfileRepository.getQuestLineage',
      errorResult: QuestLineage.empty(),
    );
  }

  Future<Result<QuestLineage>> getQuestLineageCached({
    required QuestScope scope,
    String? timezone,
    String? userJobId,
  }) async {
    if (scope == QuestScope.userJob &&
        (userJobId == null || userJobId.isEmpty)) {
      return Result.failure('userJobId is required for USER_JOB scope');
    }
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    try {
      final cachedData = await cacheService.get(
          _questCacheKey('lineage', scope, timezone, userJobId, languageCode));
      if (cachedData != null) {
        return Result.success(
            QuestLineage.fromJson(Map<String, dynamic>.from(cachedData)), null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(QuestLineage.empty(), null);
  }

  Future<Result<QuestInstance>> claimUserJobQuest(String questId) async {
    return AppResponse.execute(
      action: () async {
        final Response response =
            await api.dio.post('/user-job-quests/$questId/claim');
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
        final Response response =
            await api.dio.post('/user-quests/$questId/claim');
        final data = response.data['data'] as Map<String, dynamic>? ?? const {};
        return QuestInstance.fromJson(Map<String, dynamic>.from(data));
      },
      parentFunctionName: 'ProfileRepository.claimUserQuest',
      errorResult: QuestInstance.empty(),
    );
  }
}
