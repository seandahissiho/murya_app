import 'package:dio/dio.dart';
import 'package:murya/models/resource.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'base.repository.dart';

class ResourcesRepository extends BaseRepository {
  late final SharedPreferences prefs;
  bool initialized = false;

  ResourcesRepository() {
    initPrefs().then((_) {
      initialized = true;
    });
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<Result<Resource?>> generateResource({required ResourceType type, required String userJobId}) async {
    return AppResponse.execute(
      action: () async {
        while (!initialized) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final Response response = await api.dio.post(
          '/userJobs/generateArticle/$userJobId',
        );
        if (response.data["data"] == null) {
          return null;
        }
        return Resource.fromJson(response.data["data"]);
      },
      parentFunctionName: "ResourcesRepository.generateResource",
    );
  }
}
