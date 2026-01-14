import 'package:dio/dio.dart';
import 'package:murya/models/landing_module.dart';
import 'package:murya/models/module.dart';
import 'package:murya/repositories/base.repository.dart';

class ModulesRepository extends BaseRepository {
  static const String errorUnauthorized = 'error_auth_required';
  static const String errorModuleUnavailable = 'error_module_unavailable';
  static const String errorDefaultRequired = 'error_default_required';
  static const String errorNotFound = 'error_not_found';
  static const String errorAlreadyAdded = 'error_already_added';
  static const String errorUnknown = 'error_unknown';

  ModulesRepository();

  Future<Result<List<Module>>> getModules({
    String include = 'full',
    int? limit,
    String? cursor,
  }) async {
    try {
      final response = await api.dio.get(
        '/modules',
        queryParameters: {
          'include': include,
          if (limit != null) 'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );
      final raw = response.data['data'];
      final items = _extractItems(raw);
      final modules = items.map((item) => Module.fromApiJson(Map<String, dynamic>.from(item))).toList();
      return Result.success(modules, null);
    } on DioException catch (error) {
      return _errorResult(error, <Module>[]);
    } catch (_) {
      return Result(<Module>[], errorUnknown, null);
    }
  }

  Future<Result<List<LandingModule>>> getLandingModules(String userId) async {
    try {
      final response = await api.dio.get('/users/$userId/landing-modules');
      final raw = response.data['data'];
      final items = _extractItems(raw);
      final modules = items.map((item) => LandingModule.fromJson(Map<String, dynamic>.from(item))).toList();
      return Result.success(modules, null);
    } on DioException catch (error) {
      return _errorResult(error, <LandingModule>[]);
    } catch (_) {
      return Result(<LandingModule>[], errorUnknown, null);
    }
  }

  Future<Result<bool>> addLandingModule(String userId, String moduleId) async {
    try {
      await api.dio.post('/users/$userId/landing-modules', data: {
        'moduleId': moduleId,
      });
      return Result.success(true, null);
    } on DioException catch (error) {
      return _errorResult(error, false);
    } catch (_) {
      return Result(false, errorUnknown, null);
    }
  }

  Future<Result<bool>> removeLandingModule(String userId, String moduleId) async {
    try {
      await api.dio.delete('/users/$userId/landing-modules/$moduleId');
      return Result.success(true, null);
    } on DioException catch (error) {
      return _errorResult(error, false);
    } catch (_) {
      return Result(false, errorUnknown, null);
    }
  }

  Future<Result<bool>> reorderLandingModules(String userId, List<Map<String, dynamic>> orders) async {
    try {
      await api.dio.put('/users/$userId/landing-modules/order', data: {
        'orders': orders,
      });
      return Result.success(true, null);
    } on DioException catch (error) {
      return _errorResult(error, false);
    } catch (_) {
      return Result(false, errorUnknown, null);
    }
  }

  Future<Result<List<LandingEvent>>> getLandingAudit(String userId, {DateTime? since}) async {
    try {
      final response = await api.dio.get(
        '/users/$userId/landing-modules/audit',
        queryParameters: {
          if (since != null) 'since': since.toIso8601String(),
        },
      );
      final raw = response.data['data'];
      final items = _extractItems(raw);
      final events = items.map((item) => LandingEvent.fromJson(Map<String, dynamic>.from(item))).toList();
      return Result.success(events, null);
    } on DioException catch (error) {
      return _errorResult(error, <LandingEvent>[]);
    } catch (_) {
      return Result(<LandingEvent>[], errorUnknown, null);
    }
  }

  Result<T> _errorResult<T>(DioException error, T fallback) {
    final status = error.response?.statusCode;
    switch (status) {
      case 400:
        return Result(fallback, errorModuleUnavailable, null);
      case 401:
        return Result(fallback, errorUnauthorized, null);
      case 403:
        return Result(fallback, errorDefaultRequired, null);
      case 404:
        return Result(fallback, errorNotFound, null);
      case 409:
        return Result(fallback, errorAlreadyAdded, null);
      default:
        return Result(fallback, errorUnknown, null);
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic raw) {
    if (raw is List) {
      return raw.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    if (raw is Map) {
      final items = raw['items'] ?? raw['modules'] ?? raw['events'];
      if (items is List) {
        return items.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
    }
    return [];
  }
}
