import 'package:flutter/cupertino.dart';
import 'package:murya/models/search_response.dart';
import 'package:murya/repositories/base.repository.dart';
import 'package:murya/services/cache.service.dart';

class SearchRepository extends BaseRepository {
  final CacheService cacheService;

  SearchRepository({CacheService? cacheService})
      : cacheService = cacheService ?? CacheService();

  String _normalizeQuery(String query) => query.trim().toLowerCase();

  String _searchCacheKey({
    required String query,
    required int limit,
    required bool includeTotal,
    required List<String> sections,
    required String languageCode,
  }) {
    final normalized = _normalizeQuery(query);
    final sectionKey = sections.join(',');
    return 'search_${Uri.encodeComponent(normalized)}_${limit}_${includeTotal}_${sectionKey}_$languageCode';
  }

  Future<Result<SearchResponse>> search({
    required String query,
    int limit = 10,
    bool includeTotal = true,
    List<String> sections = const [
      'jobs',
      'jobFamilies',
      'learningResources',
      'users'
    ],
    required BuildContext context,
  }) async {
    final normalized = _normalizeQuery(query);
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    return await AppResponse.execute<SearchResponse>(
      parentFunctionName: 'SearchRepository.search',
      action: () async {
        final queryParams = {
          'q': normalized,
          'limit': limit,
          'includeTotal': includeTotal,
          'sections': sections.join(','),
        };

        final response = await api.dio.get(
          '/search',
          queryParameters: queryParams,
        );

        final data = response.data;
        if (data is Map<String, dynamic>) {
          await cacheService.save(
            _searchCacheKey(
              query: normalized,
              limit: limit,
              includeTotal: includeTotal,
              sections: sections,
              languageCode: languageCode,
            ),
            data,
          );
          return SearchResponse.fromJson(data);
        }
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          await cacheService.save(
            _searchCacheKey(
              query: normalized,
              limit: limit,
              includeTotal: includeTotal,
              sections: sections,
              languageCode: languageCode,
            ),
            map,
          );
          return SearchResponse.fromJson(map);
        }
        return SearchResponse.fromJson(response.data);
      },
    );
  }

  Future<Result<SearchResponse>> searchCached({
    required String query,
    int limit = 10,
    bool includeTotal = true,
    List<String> sections = const [
      'jobs',
      'jobFamilies',
      'learningResources',
      'users'
    ],
  }) async {
    final normalized = _normalizeQuery(query);
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'fr';
    try {
      final cachedData = await cacheService.get(
        _searchCacheKey(
          query: normalized,
          limit: limit,
          includeTotal: includeTotal,
          sections: sections,
          languageCode: languageCode,
        ),
      );
      if (cachedData != null) {
        return Result.success(
            SearchResponse.fromJson(Map<String, dynamic>.from(cachedData)),
            null);
      }
    } catch (_) {
      // ignore cache errors
    }
    return Result.success(null, null);
  }
}
