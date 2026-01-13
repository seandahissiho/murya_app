import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/job_ranking.dart';
import 'package:murya/models/user_job_competency_profile.dart';
import 'package:murya/repositories/base.repository.dart';
import 'package:murya/services/cache.service.dart';

class JobRepository extends BaseRepository {
  final CacheService cacheService;

  JobRepository({CacheService? cacheService}) : cacheService = cacheService ?? CacheService();

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
            (response.data["data"]['items'] as List).map((jobJson) => Job.fromJson(jobJson)).toList();
        return jobs.whereOrEmpty((job) => job.title.toLowerCase().contains(query.toLowerCase()) ?? false).toList();
      },
      parentFunctionName: 'JobRepository -> getJob',
      errorResult: <Job>[],
    );
  }

  Future<Result<Job>> getJobDetails(String jobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/jobs/$jobId/');

        if (response.data["data"] != null) {
          await cacheService.save('job_details_$jobId', response.data["data"]);
        }

        final Job job = Job.fromJson(response.data["data"]);
        return job;
      },
      parentFunctionName: 'JobRepository -> getJobDetails',
    );
  }

  Future<Result<Job>> getJobDetailsCached(String jobId) async {
    try {
      final cachedData = await cacheService.get('job_details_$jobId');
      if (cachedData != null) {
        final Job job = Job.fromJson(cachedData);
        return Result.success(job, null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(Job.empty(), null);
  }

  // getUserCurrentJob
  Future<Result<UserJob?>> getUserCurrentJob() async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/current/');

        if (response.data["data"] != null) {
          await cacheService.save('user_current_job', response.data["data"]);
        }

        final UserJob? job = response.data["data"] != null ? UserJob.fromJson(response.data["data"]) : null;
        return job;
      },
      parentFunctionName: 'JobRepository -> getUserCurrentJob',
    );
  }

  Future<Result<UserJob?>> getUserCurrentJobCached() async {
    try {
      final cachedData = await cacheService.get('user_current_job');
      if (cachedData != null) {
        final UserJob job = UserJob.fromJson(cachedData);
        return Result.success(job, null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(null, null);
  }

  Future<Result<UserJob?>> setUserCurrentJob(String jobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.post('/userJobs/current/$jobId');

        if (response.data["data"] != null) {
          await cacheService.save('user_current_job', response.data["data"]);
        }

        final UserJob? job = response.data["data"] != null ? UserJob.fromJson(response.data["data"]) : null;
        return job;
      },
      parentFunctionName: 'JobRepository -> setUserCurrentJob',
    );
  }

  // getUserJobDetails
  Future<Result<UserJob>> getUserJobDetails(String jobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/$jobId/');

        if (response.data["data"] != null) {
          await cacheService.save('user_job_details_$jobId', response.data["data"]);
        }

        final UserJob job = UserJob.fromJson(response.data["data"]);
        return job;
      },
      parentFunctionName: 'JobRepository -> getUserJobDetails',
    );
  }

  Future<Result<UserJob>> getUserJobDetailsCached(String jobId) async {
    try {
      final cachedData = await cacheService.get('user_job_details_$jobId');
      if (cachedData != null) {
        final UserJob job = UserJob.fromJson(cachedData);
        return Result.success(job, null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(UserJob.empty(), null);
  }

  // getCFDetails
  Future<Result<(CompetencyFamily, Job)>> getCFDetails(String jobId, String cfId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/jobs/$jobId/competency_families/$cfId/');

        if (response.data["data"] != null) {
          await cacheService.save('cf_details_${jobId}_$cfId', response.data["data"]);
        }

        final familyJson = response.data["data"]['family'];
        familyJson['competencies'] = response.data["data"]['competencies'];
        final CompetencyFamily cfamily = CompetencyFamily.fromJson(familyJson);
        final Job job = Job.fromJson(response.data["data"]['job']);
        return (cfamily, job);
      },
      parentFunctionName: 'JobRepository -> getCFDetails',
    );
  }

  Future<Result<(CompetencyFamily, Job)>> getCFDetailsCached(String jobId, String cfId) async {
    try {
      final cachedData = await cacheService.get('cf_details_${jobId}_$cfId');
      if (cachedData != null) {
        final familyJson = cachedData['family'];
        familyJson['competencies'] = cachedData['competencies'];
        final CompetencyFamily cfamily = CompetencyFamily.fromJson(familyJson);
        final Job job = Job.fromJson(cachedData['job']);
        return Result.success((cfamily, job), null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success((CompetencyFamily.empty(), Job.empty()), null);
  }

  // /leaderboard/job/:jobId
  Future<Result<JobRankings>> getRankingForJob(String jobId, DateTime? from, DateTime? to) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/leaderboard/job/$jobId/', queryParameters: {
          if (from != null) 'from': from.toDbString(),
          if (to != null) 'to': to.toDbString(),
        });

        if (response.data["data"] != null) {
          await cacheService.save('job_ranking_$jobId-${from?.toDbString() ?? 'null'}_${to?.toDbString() ?? 'null'}',
              response.data["data"]);
        }

        final JobRankings ranking = JobRankings.fromJson(response.data["data"]);
        return ranking;
      },
      parentFunctionName: 'JobRepository -> getRankingForJob',
      errorResult: JobRankings.empty(),
    );
  }

  Future<Result<JobRankings>> getRankingForJobCached(String jobId, DateTime? from, DateTime? to) async {
    try {
      final cachedData =
          await cacheService.get('job_ranking_$jobId-${from?.toDbString() ?? 'null'}_${to?.toDbString() ?? 'null'}');
      if (cachedData != null) {
        final JobRankings ranking = JobRankings.fromJson(cachedData);
        return Result.success(ranking, null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(JobRankings.empty(), null);
  }

  // Future<Result<UserJobCompetencyProfile>> fetchUserJobCompetencyProfile
  Future<Result<UserJobCompetencyProfile>> fetchUserJobCompetencyProfile(String userJobId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/userJobs/$userJobId/competenciesProfile/');

        if (response.data["data"] != null) {
          await cacheService.save('user_job_competency_profile_$userJobId', response.data["data"]);
        }

        final UserJobCompetencyProfile profile = UserJobCompetencyProfile.fromJson(response.data["data"]);
        return profile;
      },
      parentFunctionName: 'JobRepository -> fetchUserJobCompetencyProfile',
    );
  }

  Future<Result<UserJobCompetencyProfile>> fetchUserJobCompetencyProfileCached(String userJobId) async {
    try {
      final cachedData = await cacheService.get('user_job_competency_profile_$userJobId');
      if (cachedData != null) {
        final UserJobCompetencyProfile profile = UserJobCompetencyProfile.fromJson(cachedData);
        return Result.success(profile, null);
      }
    } catch (e) {
      // ignore cache errors
    }
    return Result.success(UserJobCompetencyProfile.empty(), null);
  }
}
