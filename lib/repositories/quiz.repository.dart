import 'package:dio/dio.dart';
import 'package:murya/blocs/modules/quizz/quiz_bloc.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/quiz.dart';
import 'package:murya/models/quiz_result.dart';
import 'package:murya/services/cache.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class QuizRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;
  final CacheService cacheService;

  QuizRepository({CacheService? cacheService})
      : cacheService = cacheService ?? CacheService() {
    initPrefs().then((_) {
      initialized = true;
    });
  }

  String _quizCacheKey(String jobId, String languageCode) =>
      'quiz_${jobId}_$languageCode';

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Result<UserQuizResult?>> saveQuizResult(SaveQuizResults event) async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final Response response = await api.dio.post(
          '/userJobs/${event.jobId}/quiz/${event.quizId}',
          data: {
            "answers": event.dbResponses,
            "doneAt": DateTime.now().toDbString(),
          },
        );

        final data = response.data["data"];
        if (data is Map<String, dynamic>) {
          return UserQuizResult.fromJson(data);
        }
        if (data is Map) {
          return UserQuizResult.fromJson(Map<String, dynamic>.from(data));
        }
        return null;
      },
      parentFunctionName: "QuizRepository.saveQuizResult",
    );
  }

  Future<Result<Quiz?>> getQuizForJob(String jobId) async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'en';
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final Response response = await api.dio.get('/userJobs/$jobId/quiz');

        final data = response.data["data"];
        if (data is Map<String, dynamic>) {
          await cacheService.save(_quizCacheKey(jobId, languageCode), data);
          return Quiz.fromJson(data);
        }
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          await cacheService.save(_quizCacheKey(jobId, languageCode), map);
          return Quiz.fromJson(map);
        }
        return Quiz.fromJson(response.data["data"]);
      },
      parentFunctionName: "QuizRepository.getQuizForJob",
    );
  }

  Future<Result<Quiz?>> getQuizForJobCached(String jobId) async {
    final languageCode =
        api.dio.options.headers['accept-language']?.toString() ?? 'en';
    try {
      final cachedData =
          await cacheService.get(_quizCacheKey(jobId, languageCode));
      if (cachedData != null) {
        return Result.success(
            Quiz.fromJson(Map<String, dynamic>.from(cachedData)), null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(null, null);
  }
}
