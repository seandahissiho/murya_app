import 'package:dio/dio.dart';
import 'package:murya/blocs/modules/quizz/quiz_bloc.dart';
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

  Future<Result<bool>> saveQuizResult(SaveQuizResults event) async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final Response response = await api.dio.post(
          '/quiz/save',
          data: {
            "quiz_id": event.quizId,
            "answers": event.responses,
          },
        );
        return true;
      },
      parentFunctionName: "QuizRepository.saveQuizResult",
    );
  }
}
