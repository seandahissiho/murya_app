import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/repositories/base.repository.dart';

class AppRepository extends BaseRepository {
  AppRepository();

  Future<Result<AppForex?>> getForex(String s) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/forex/$s');
        final data = response.data['data']['payload'] as Map<String, dynamic>;
        final AppForex forex = AppForex(
          result: data['result'] as String?,
          documentation: data['documentation'] as String?,
          termsOfUse: data['terms_of_use'] as String?,
          timeLastUpdateUnix: data['time_last_update_unix'] as int?,
          timeLastUpdateUtc: data['time_last_update_utc'] as String?,
          timeNextUpdateUnix: data['time_next_update_unix'] as int?,
          timeNextUpdateUtc: data['time_next_update_utc'] as String?,
          baseCode: data['base_code'] as String?,
          conversionRates: (data['conversion_rates'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toDouble())),
        );
        return forex;
      },
      parentFunctionName: "AppRepository.getForex",
    );
  }
}
