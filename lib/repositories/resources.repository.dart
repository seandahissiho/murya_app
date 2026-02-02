import 'package:dio/dio.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/services/cache.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class ResourcesRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;
  final CacheService cacheService;

  ResourcesRepository({CacheService? cacheService})
      : cacheService = cacheService ?? CacheService() {
    initPrefs().then((_) {
      initialized = true;
    });
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Result<Resource?>> generateResource(
      {required ResourceType type, required String userJobId}) async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final Response response = await api.dio.post(
          '/userJobs/generateArticle/$userJobId',
        );

        return Resource.fromJson(response.data["data"]);
      },
      parentFunctionName: "ResourcesRepository.generateResource",
    );
  }

  Future<Result<List<Resource>>> fetchResources(String userJobId) async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/$userJobId/resources');

        if (response.data["data"] != null) {
          await cacheService.save(
              'user_job_resources_${userJobId}_$languageCode', response.data);
        }

        final List<Resource> resources = (response.data["data"] as List)
            .map((e) => Resource.fromJson(e))
            .toList();
        return resources;
      },
      parentFunctionName: 'ResourcesRepository -> fetchResources',
    );
  }

  Future<Result<Resource>> openResource({
    required String resourceId,
    String? timezone,
  }) async {
    return AppResponse.execute(
      action: () async {
        final payload = <String, dynamic>{};
        if (timezone != null && timezone.isNotEmpty) {
          payload['timezone'] = timezone;
        }
        final response = await api.dio.post('/resources/$resourceId/open',
            data: payload.isEmpty ? null : payload);
        return _resourceFromTrackingResponse(response.data);
      },
      parentFunctionName: 'ResourcesRepository -> openResource',
    );
  }

  Future<Result<Resource>> readResource({
    required String resourceId,
    String? timezone,
    double? progress,
  }) async {
    return AppResponse.execute(
      action: () async {
        final payload = <String, dynamic>{};
        if (timezone != null && timezone.isNotEmpty) {
          payload['timezone'] = timezone;
        }
        if (progress != null) {
          payload['progress'] = progress;
        }
        final response = await api.dio.post('/resources/$resourceId/read',
            data: payload.isEmpty ? null : payload);
        return _resourceFromTrackingResponse(response.data);
      },
      parentFunctionName: 'ResourcesRepository -> readResource',
    );
  }

  Future<Result<List<Resource>>> fetchResourcesCached(String userJobId) async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    try {
      final cachedData = await cacheService
          .get('user_job_resources_${userJobId}_$languageCode');
      if (cachedData != null && cachedData['data'] != null) {
        final List<Resource> resources = (cachedData["data"] as List)
            .map((e) => Resource.fromJson(e))
            .toList();
        return Result.success(resources, null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success([], null);
  }

  Future<void> updateCachedResourceUserState({
    required String userJobId,
    required Resource updated,
  }) async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    try {
      final cachedData = await cacheService
          .get('user_job_resources_${userJobId}_$languageCode');
      if (cachedData == null || cachedData['data'] == null) return;
      if (updated.userState == null) return;

      final List<dynamic> rawList = cachedData['data'] as List<dynamic>;
      bool updatedAny = false;

      for (var i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          if (map['id'] == updated.id) {
            map['userState'] = updated.userState!.toJson();
            rawList[i] = map;
            updatedAny = true;
            break;
          }
        }
      }

      if (updatedAny) {
        cachedData['data'] = rawList;
        await cacheService.save(
            'user_job_resources_${userJobId}_$languageCode', cachedData);
      }
    } catch (_) {
      // ignore cache update errors
    }
  }

  Resource _resourceFromTrackingResponse(dynamic responseData) {
    final data =
        responseData is Map<String, dynamic> ? responseData['data'] : null;
    if (data is Map<String, dynamic>) {
      final resourceJson = data['resource'] as Map<String, dynamic>?;
      final userStateJson = data['userState'] as Map<String, dynamic>?;
      if (resourceJson != null) {
        final resource = Resource.fromJson(resourceJson);
        if (userStateJson != null) {
          return resource.copyWith(
            userState: UserResourceState.fromJson(userStateJson),
          );
        }
        return resource;
      }
    }

    if (responseData is Map<String, dynamic>) {
      return Resource.fromJson(responseData);
    }

    throw Exception('Invalid tracking response data');
  }
}
