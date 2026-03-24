import 'package:dio/dio.dart';
import 'package:murya/models/resource.dart';
import 'package:murya/services/cache.service.dart';
import 'package:murya/services/timezone.service.dart';
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

  Future<Result<ResourceGenerationReceipt?>> generateResource({
    required ResourceType type,
    required String topic,
    required String level,
    required String userJobId,
    required String idempotencyKey,
  }) async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final Response response = await api.dio.post(
          '/resources/generate',
          data: {
            'type': type.toJson(),
            'topic': topic,
            'level': level,
            'userJobId': userJobId,
          },
          options: Options(
            headers: {
              'Idempotency-Key': idempotencyKey,
            },
          ),
        );

        return ResourceGenerationReceipt.fromJson(response.data);
      },
      parentFunctionName: "ResourcesRepository.generateResource",
    );
  }

  Future<Result<List<Resource>>> fetchResources(String userJobId) async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'en';
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
        final payload = <String, dynamic>{
          'timezone': await AppTimezoneService.instance.getRequestTimezone(
            preferred: timezone,
          ),
        };
        final response = await api.dio.post('/resources/$resourceId/open',
            data: payload.isEmpty ? null : payload);
        return _resourceFromTrackingResponse(response.data);
      },
      parentFunctionName: 'ResourcesRepository -> openResource',
    );
  }

  Future<Result<Resource>> collectResource({
    required String resourceId,
    String? timezone,
  }) async {
    return AppResponse.execute(
      action: () async {
        final payload = <String, dynamic>{
          'timezone': await AppTimezoneService.instance.getRequestTimezone(
            preferred: timezone,
          ),
        };
        final response = await api.dio.post(
          '/resources/$resourceId/collect',
          data: payload.isEmpty ? null : payload,
        );
        final data = response.data is Map<String, dynamic>
            ? response.data['data']
            : null;
        if (data is Map<String, dynamic>) {
          return Resource.fromJson(data);
        }
        if (response.data is Map<String, dynamic>) {
          return Resource.fromJson(response.data);
        }
        throw Exception('Invalid collect resource response data');
      },
      parentFunctionName: 'ResourcesRepository -> collectResource',
    );
  }

  Future<Result<Resource>> readResource({
    required String resourceId,
    String? timezone,
    double? progress,
  }) async {
    return AppResponse.execute(
      action: () async {
        final payload = <String, dynamic>{
          'timezone': await AppTimezoneService.instance.getRequestTimezone(
            preferred: timezone,
          ),
        };
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

  Future<Result<Resource>> likeResource({
    required String resourceId,
    required bool like,
    String? timezone,
  }) async {
    return AppResponse.execute(
      action: () async {
        final payload = <String, dynamic>{
          'like': like,
          'timezone': await AppTimezoneService.instance.getRequestTimezone(
            preferred: timezone,
          ),
        };
        final response = await api.dio.post(
          '/resources/$resourceId/like',
          data: payload,
        );
        return _resourceFromTrackingResponse(response.data);
      },
      parentFunctionName: 'ResourcesRepository -> likeResource',
    );
  }

  Future<Result<List<Resource>>> fetchResourcesCached(String userJobId) async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'en';
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
        api.dio.options.headers['accept-language']?.toString() ?? 'en';
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

class ResourceGenerationReceipt {
  final String requestId;
  final String status;
  final ResourceType type;
  final String topic;
  final String level;
  final String userJobId;
  final int? costDiamonds;
  final int? walletDiamonds;

  const ResourceGenerationReceipt({
    required this.requestId,
    required this.status,
    required this.type,
    required this.topic,
    required this.level,
    required this.userJobId,
    this.costDiamonds,
    this.walletDiamonds,
  });

  factory ResourceGenerationReceipt.fromJson(Map<String, dynamic> json) {
    final wallet = json['wallet'];
    final walletDiamonds = wallet is Map<String, dynamic>
        ? (wallet['diamonds'] as num?)?.toInt()
        : null;

    return ResourceGenerationReceipt(
      requestId: json['requestId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      type: ResourceTypeX.fromJson(json['type'] as String?),
      topic: json['topic'] as String? ?? '',
      level: json['level'] as String? ?? '',
      userJobId: json['userJobId'] as String? ?? '',
      costDiamonds: (json['costDiamonds'] as num?)?.toInt(),
      walletDiamonds: walletDiamonds,
    );
  }
}
