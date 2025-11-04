import 'dart:developer';

import 'package:murya/models/Job.dart';
import 'package:murya/repositories/base.repository.dart';

class JobRepository extends BaseRepository {
  JobRepository();

  Future<Result<List<Job>>> searchJobs({
    required String query,
  }) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get(
          '/jobs/',
          queryParameters: {
            'query': query,
          },
        );
        log('Jobs Search Response: ${response.data}');

        final List<Job> jobs =
            (response.data['data']['items'] as List).map((jobJson) => Job.fromJson(jobJson)).toList();
        return jobs;
      },
      parentFunctionName: 'JobRepository -> getJob',
      errorResult: <Job>[],
    );
  }

  Future<Result<Job>> getJobDetails(String jobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/jobs/$jobId/');

        final Job job = Job.fromJson(response.data['data']);
        return job;
      },
      parentFunctionName: 'JobRepository -> getJobDetails',
    );
  }

  Future<Result<CompetencyFamily>> getCFDetails(String jobId, String cfId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/jobs/$jobId/competency_families/$cfId/');

        final familyJson = response.data['data']['family'];
        familyJson['competencies'] = response.data['data']['competencies'];
        final CompetencyFamily cfamily = CompetencyFamily.fromJson(familyJson);
        return cfamily;
      },
      parentFunctionName: 'JobRepository -> getCFDetails',
    );
  }
}
