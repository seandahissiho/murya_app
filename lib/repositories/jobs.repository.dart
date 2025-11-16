import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/job_ranking.dart';
import 'package:murya/models/user_job_competency_profile.dart';
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

  // getUserCurrentJob
  Future<Result<UserJob>> getUserCurrentJob() async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/current/');

        final UserJob job = UserJob.fromJson(response.data['data']);
        return job;
      },
      parentFunctionName: 'JobRepository -> getUserCurrentJob',
    );
  }

  // getUserJobDetails
  Future<Result<UserJob>> getUserJobDetails(String jobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/$jobId/');

        final UserJob job = UserJob.fromJson(response.data['data']);
        return job;
      },
      parentFunctionName: 'JobRepository -> getUserJobDetails',
    );
  }

  Future<Result<(CompetencyFamily, Job)>> getCFDetails(String jobId, String cfId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/jobs/$jobId/competency_families/$cfId/');

        final familyJson = response.data['data']['family'];
        familyJson['competencies'] = response.data['data']['competencies'];
        final CompetencyFamily cfamily = CompetencyFamily.fromJson(familyJson);
        final Job job = Job.fromJson(response.data['data']['job']);
        return (cfamily, job);
      },
      parentFunctionName: 'JobRepository -> getCFDetails',
    );
  }

  // /leaderboard/job/:jobId
  Future<Result<JobRankings>> getRankingForJob(String jobId, DateTime? from, DateTime? to) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/leaderboard/job/$jobId/', queryParameters: {
          if (from != null) 'from': from.toDbString(),
          if (to != null) 'to': to.toDbString(),
        });

        final JobRankings ranking = JobRankings.fromJson(response.data['data']);
        return ranking;
      },
      parentFunctionName: 'JobRepository -> getRankingForJob',
      errorResult: JobRankings.empty(),
    );
  }

  // Future<Result<UserJobCompetencyProfile>> fetchUserJobCompetencyProfile
  Future<Result<UserJobCompetencyProfile>> fetchUserJobCompetencyProfile(String userJobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/$userJobId/competenciesProfile/');

        final UserJobCompetencyProfile profile = UserJobCompetencyProfile.fromJson(response.data['data']);
        return profile;
      },
      parentFunctionName: 'JobRepository -> fetchUserJobCompetencyProfile',
    );
  }
}
