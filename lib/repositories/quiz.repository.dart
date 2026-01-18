import 'package:dio/dio.dart';
import 'package:murya/blocs/modules/quizz/quiz_bloc.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/quiz.dart';
import 'package:murya/models/quiz_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class QuizRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;

  QuizRepository() {
    initPrefs().then((_) {
      initialized = true;
    });
  }

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
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final Response response = await api.dio.get('/userJobs/$jobId/quiz');

        return Quiz.fromJson(response.data["data"]);
      },
      parentFunctionName: "QuizRepository.getQuizForJob",
    );
  }
}
