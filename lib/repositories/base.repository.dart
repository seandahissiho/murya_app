import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// bool WE_ARE_BEFORE_QUIZZ = true;
// bool WE_ARE_BEFORE_FIRST_USER_FETCH = true;
// int DIAMONDS = 0;

class BaseRepository {
  final Api api;

  BaseRepository() : api = Api();

  void updateDio(String token, BuildContext context) {
    api.updateContext(context);
    api.updateToken(token);
  }

  void updateLanguage(String languageCode) {
    api.updateLanguage(languageCode);
  }
}

class ApiEndPoint {
  static String baseUrl = dotenv.env["API_URL"]!;
}

class Api {
  late final Dio dio;

  Api._internal() : dio = createDio();

  static final _singleton = Api._internal();

  factory Api() => _singleton;

  static Dio createDio() {
    var dio = Dio(BaseOptions(
        baseUrl: ApiEndPoint.baseUrl,
        receiveTimeout: const Duration(seconds: 120),
        connectTimeout: const Duration(seconds: 120),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Charset': 'utf-8',
        }));

    dio.interceptors.addAll({AppInterceptors(dio)});

    return dio;
  }

  void updateToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void updateLanguage(String languageCode) {
    dio.options.headers['accept-language'] = languageCode;
  }

  void updateContext(BuildContext context) {
    dio.interceptors.clear();
    dio.interceptors.addAll({AppInterceptors(dio, context: context)});
  }
}

///Interceptors
class BaseInterceptor extends Interceptor {
  final Dio dio;
  final BuildContext? context;

  BaseInterceptor(this.dio, {this.context});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // final responseData = err.response?.data;

    if (err.response?.statusCode == 401) {
      // try {
      //   context?.read<AuthenticationBloc>().add(TryAutoLogin());
      // } catch (e) {
      //   log("Error while trying to auto-login: $e", name: "BaseInterceptor.onError");
      // }
      super.onError(err, handler);
    } else {
      super.onError(err, handler);
    }
  }
}

class AppInterceptors extends BaseInterceptor {
  AppInterceptors(super.dio, {super.context});
}

class AppResponse {
  static Future<Result<T>> execute<T>(
      {required Future<dynamic> Function() action, required String parentFunctionName, dynamic errorResult}) async {
    try {
      final dynamic result = await action();
      if (result is ResultWithMessage) {
        return Result.success(result.$1, result.$2);
      } else {
        return Result.success(result, null);
      }
    } on DioException catch (error, stacktrace) {
      // debugPrintStack(
      //   stackTrace: stacktrace,
      //   label: "$error [$parentFunctionName]",
      //   maxFrames: 20,
      // );
      // debugPrint("\n\n\n");
      String? errorToDisplay = error.response?.statusCode == 404
          ? "Ressource non trouvée"
          : error.response?.statusCode == 500
              ? "Erreur interne du serveur"
              : null;

      errorToDisplay ??=
          error.response?.data is Map ? (error.response?.data["error"] ?? error.response?.data["message"]) : null;

      errorToDisplay ??= _handleBackEndValidatorsException(error);

      return Result(errorResult, errorToDisplay ?? "Une erreur est survenue", null);
    } catch (error, stacktrace) {
      // debugPrintStack(
      //   stackTrace: stacktrace,
      //   label: "$error [$parentFunctionName]",
      //   maxFrames: 20,
      // );
      // debugPrint("\n\n\n");

      return Result(errorResult, error is String ? error : "Une erreur est survenue", null);
    }
  }

  static String? _handleFirebaseException(dynamic error) {
    // if (error is FirebaseException ||
    //     error is FirebaseAuthException ||
    //     error is FirebaseAuthMultiFactorException) {
    //   return firebaseErrors[error.code] ?? "Une erreur est survenue";
    // }
    return null;
  }
}

/*
{
  "errors" : [ {
    "type" : "field",
    "msg" : "La référence est requise",
    "path" : "ref",
    "location" : "body"
  }, {
    "type" : "field",
    "msg" : "Type de produit invalide, doit être PRODUCT ou SERVICE",
    "path" : "type",
    "location" : "body"
  }, {
    "type" : "field",
    "msg" : "Le prix doit être un nombre positif",
    "path" : "price",
    "location" : "body"
  }, {
    "type" : "field",
    "msg" : "Le prix TTC doit être un nombre positif",
    "path" : "priceTtc",
    "location" : "body"
  } ]
}
 */

String? _handleBackEndValidatorsException(DioException error) {
  if (error.response?.data is Map) {
    final data = error.response!.data as Map<String, dynamic>;
    if (data.containsKey("errors")) {
      final errors = data["errors"] as List<dynamic>;
      if (errors.isNotEmpty) {
        final firstError = errors.first;
        if (firstError is Map<String, dynamic> && firstError.containsKey("msg")) {
          return firstError["msg"] as String?;
        }
      }
    }
  }
  return null;
}

class Result<T> {
  final T? data;
  final String? error;
  final String? message;

  Result(
    this.data,
    this.error,
    this.message,
  );

  bool get isError => error != null || data == null;

  static Result<T> success<T>(T? data, String? message) => Result<T>(data, null, message);

  static Result<T> failure<T>(String error) => Result<T>(null, error, null);
}

class ResultWithMessage<T> {
  final T $1;
  final String? $2;

  ResultWithMessage(this.$1, this.$2);
}
