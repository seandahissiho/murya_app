import 'package:dio/dio.dart';
import 'package:murya/models/resource.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

import 'package:murya/services/cache.service.dart';

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
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/$userJobId/resources');

        if (response.data["data"] != null) {
          await cacheService.save(
              'user_job_resources_$userJobId', response.data);
        }

        final List<Resource> resources = (response.data["data"] as List)
            .map((e) => Resource.fromJson(e))
            .toList();
        return resources;
      },
      parentFunctionName: 'ResourcesRepository -> fetchResources',
    );
  }

  Future<Result<List<Resource>>> fetchResourcesCached(String userJobId) async {
    try {
      final cachedData =
          await cacheService.get('user_job_resources_$userJobId');
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
}
