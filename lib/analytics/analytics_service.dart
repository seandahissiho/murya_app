import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:murya/analytics/analytics_events.dart';
import 'package:murya/models/app_user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'posthog_web_bootstrap_stub.dart'
    if (dart.library.html) 'posthog_web_bootstrap_web.dart';

enum AnalyticsRuntimeEnv { local, staging, production }

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  static const _trueValues = <String>{
    '1',
    'true',
    'yes',
    'y',
    'on',
  };
  static const _falseValues = <String>{
    '0',
    'false',
    'no',
    'n',
    'off',
  };

  final Posthog _posthog = Posthog();

  bool _enabled = false;
  bool _initialized = false;
  bool _replayEnabled = false;
  bool _debug = false;
  String _currentLang = _initialLanguageCode();
  String? _currentRoute;
  String? _currentScreenName;
  String? _identifiedUserId;
  String? _appVersion;
  AnalyticsRuntimeEnv _runtimeEnv = AnalyticsRuntimeEnv.local;

  bool get isEnabled => _enabled;

  bool get isReplayEnabled => _enabled && _replayEnabled;

  String? get currentRoute => _currentRoute;

  String? get currentScreenName => _currentScreenName;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    _installGlobalErrorHandlers();

    final apiKey = (dotenv.env['POSTHOG_PROJECT_API_KEY'] ?? '').trim();
    final explicitEnabled = _parseBool(dotenv.env['POSTHOG_ENABLED']);
    _debug = _parseBool(dotenv.env['POSTHOG_DEBUG']) ?? false;
    _runtimeEnv = _inferRuntimeEnv();

    final normalizedHost = _normalizeHost(
      dotenv.env['POSTHOG_PROXY_HOST'] ?? dotenv.env['POSTHOG_HOST'] ?? '',
    );
    _enabled = explicitEnabled ??
        (apiKey.isNotEmpty &&
            (_runtimeEnv == AnalyticsRuntimeEnv.staging ||
                _runtimeEnv == AnalyticsRuntimeEnv.production));
    _replayEnabled =
        _parseBool(dotenv.env['POSTHOG_REPLAY_ENABLED']) ?? _enabled;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
    } catch (_) {
      _appVersion = null;
    }

    if (!_enabled || apiKey.isEmpty) {
      return;
    }

    if (kIsWeb && normalizedHost.isNotEmpty) {
      await bootstrapPosthogWeb(
        apiKey: apiKey,
        host: normalizedHost,
        debug: _debug,
      );
    }

    final host =
        normalizedHost.isNotEmpty ? normalizedHost : 'https://us.i.posthog.com';

    final config = PostHogConfig(apiKey);
    config.host = host;
    config.debug = _debug;
    config.captureApplicationLifecycleEvents = false;
    config.personProfiles = PostHogPersonProfiles.identifiedOnly;
    config.sessionReplay = _replayEnabled;
    config.sessionReplayConfig.maskAllImages = false;
    config.sessionReplayConfig.maskAllTexts = false;
    config.beforeSend = [
      (event) {
        if (event.event == r'$screen') {
          return null;
        }

        final mergedProperties = <String, Object?>{
          ...?event.properties,
          'env': _runtimeEnv.name,
          'lang': _currentLang,
          'platform': _platformName,
          if (_appVersion != null && _appVersion!.isNotEmpty)
            'app_version': _appVersion,
          if (_currentRoute != null && _currentRoute!.isNotEmpty)
            'route': _currentRoute,
          if (_currentScreenName != null && _currentScreenName!.isNotEmpty)
            'screen_name': _currentScreenName,
        };

        event.properties = _sanitizeProperties(mergedProperties);
        return event;
      },
    ];

    await _posthog.setup(config);
    await _registerCommonProperties();
  }

  Future<void> screen({
    required String route,
    required String screenName,
  }) async {
    final normalizedRoute = normalizeAnalyticsRoute(route);
    if (normalizedRoute.isEmpty || screenName.isEmpty) {
      return;
    }

    _currentRoute = normalizedRoute;
    _currentScreenName = screenName;

    if (!_enabled) {
      return;
    }

    await _registerCommonProperties();
    await _posthog.screen(
      screenName: screenName,
      properties: _sanitizeProperties({
        'route': normalizedRoute,
      }),
    );
    await captureUi(
      AnalyticsEventNames.screenViewed,
      properties: {
        'route': normalizedRoute,
        'screen_name': screenName,
      },
    );
  }

  Future<void> captureUi(
    String eventName, {
    Map<String, Object?> properties = const {},
  }) async {
    if (!_enabled || eventName.isEmpty) {
      return;
    }

    await _posthog.capture(
      eventName: eventName,
      properties: _sanitizeProperties({
        ...properties,
        if (!properties.containsKey('route')) 'route': _currentRoute,
        if (!properties.containsKey('screen_name'))
          'screen_name': _currentScreenName,
      }),
    );
  }

  Future<void> identifyUser(User user) async {
    final userId = user.id?.trim() ?? '';
    if (!_enabled || userId.isEmpty || userId == _identifiedUserId) {
      return;
    }

    _identifiedUserId = userId;
    updateLanguage(user.preferredLangCode);

    await _posthog.identify(
      userId: userId,
      userProperties: _sanitizeProperties({
        'auth_mode': _resolveAuthMode(user),
        'is_temp_account': _isTempAccount(user),
        if ((user.preferredLangCode ?? '').isNotEmpty)
          'preferred_lang_code': user.preferredLangCode,
      }),
    );
  }

  Future<void> reset() async {
    _identifiedUserId = null;
    if (!_enabled) {
      return;
    }
    await _posthog.reset();
    await _registerCommonProperties();
  }

  Future<bool> isFeatureEnabled(String key, {bool fallback = false}) async {
    if (!_enabled || key.trim().isEmpty) {
      return fallback;
    }

    try {
      return await _posthog.isFeatureEnabled(key);
    } catch (_) {
      return fallback;
    }
  }

  Future<void> reloadFlags() async {
    if (!_enabled) {
      return;
    }

    try {
      await _posthog.reloadFeatureFlags();
    } catch (_) {
      // Best-effort flags refresh.
    }
  }

  void updateLanguage(String? languageCode) {
    final normalized = _normalizeLanguageCode(languageCode);
    if (normalized == null || normalized == _currentLang) {
      return;
    }

    _currentLang = normalized;
    if (_enabled) {
      unawaited(_registerCommonProperties());
    }
  }

  Future<void> captureRuntimeError(
    Object error,
    StackTrace stackTrace, {
    required String source,
    bool fatal = false,
  }) async {
    if (!_enabled) {
      return;
    }

    await _posthog.captureException(
      error: error,
      stackTrace: stackTrace,
      properties: _sanitizeProperties({
        'error_source': source,
        'fatal': fatal,
        'route': _currentRoute,
        'screen_name': _currentScreenName,
      }),
    );
  }

  Future<void> captureHandledError(
    Object error,
    StackTrace stackTrace, {
    required String source,
  }) async {
    if (!_enabled) {
      return;
    }

    await _posthog.captureException(
      error: error,
      stackTrace: stackTrace,
      properties: _sanitizeProperties({
        'error_source': source,
        'handled': true,
        'route': _currentRoute,
        'screen_name': _currentScreenName,
      }),
    );
  }

  Future<void> captureApiError(
    DioException error, {
    String? parentFunctionName,
  }) async {
    if (!_enabled) {
      return;
    }

    final requestUri = error.requestOptions.uri;
    final responseData = error.response?.data;
    final errorCode = responseData is Map<String, dynamic>
        ? responseData['code']?.toString()
        : null;

    await _posthog.captureException(
      error: error.error ?? error,
      stackTrace: error.stackTrace,
      properties: _sanitizeProperties({
        'error_source': 'dio',
        'error_code': errorCode,
        'error_message': _sanitizeString(
          error.message ?? error.error?.toString() ?? 'HTTP error',
        ),
        'http_method': error.requestOptions.method,
        'http_status_code': error.response?.statusCode,
        'parent_function': parentFunctionName,
        'request_path': _sanitizeRequestPath(requestUri),
        'route': _currentRoute,
        'screen_name': _currentScreenName,
      }),
    );
  }

  Future<void> _registerCommonProperties() async {
    if (!_enabled) {
      return;
    }

    await _safeRegister('env', _runtimeEnv.name);
    await _safeRegister('lang', _currentLang);
    await _safeRegister('platform', _platformName);

    if (_appVersion != null && _appVersion!.isNotEmpty) {
      await _safeRegister('app_version', _appVersion!);
    }

    if (_currentRoute != null && _currentRoute!.isNotEmpty) {
      await _safeRegister('route', _currentRoute!);
    }

    if (_currentScreenName != null && _currentScreenName!.isNotEmpty) {
      await _safeRegister('screen_name', _currentScreenName!);
    }
  }

  Future<void> _safeRegister(String key, Object value) async {
    try {
      await _posthog.register(key, value);
    } catch (_) {
      // Ignore SDK registration failures so analytics never blocks the UI.
    }
  }

  void _installGlobalErrorHandlers() {
    final previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      unawaited(
        captureRuntimeError(
          details.exception,
          details.stack ?? StackTrace.current,
          source: 'flutter_error',
          fatal: true,
        ),
      );
      if (previousFlutterOnError != null) {
        previousFlutterOnError(details);
      } else {
        FlutterError.presentError(details);
      }
    };

    final previousPlatformOnError = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(
        captureRuntimeError(
          error,
          stackTrace,
          source: 'platform_dispatcher',
          fatal: true,
        ),
      );
      return previousPlatformOnError?.call(error, stackTrace) ?? false;
    };
  }

  static bool? _parseBool(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    if (_trueValues.contains(normalized)) {
      return true;
    }
    if (_falseValues.contains(normalized)) {
      return false;
    }
    return null;
  }

  AnalyticsRuntimeEnv _inferRuntimeEnv() {
    final apiUrl = (dotenv.env['API_URL'] ?? '').toLowerCase();
    final proxyHost = (dotenv.env['POSTHOG_PROXY_HOST'] ?? '').toLowerCase();
    final combined = '$apiUrl $proxyHost';

    if (combined.contains('localhost') ||
        combined.contains('127.0.0.1') ||
        combined.contains('0.0.0.0')) {
      return AnalyticsRuntimeEnv.local;
    }

    if (combined.contains('staging')) {
      return AnalyticsRuntimeEnv.staging;
    }

    return kReleaseMode
        ? AnalyticsRuntimeEnv.production
        : AnalyticsRuntimeEnv.local;
  }

  String get _platformName {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  static String _initialLanguageCode() {
    return _normalizeLanguageCode(
          Intl.defaultLocale ??
              WidgetsBinding.instance.platformDispatcher.locale.languageCode,
        ) ??
        'en';
  }

  static String? _normalizeLanguageCode(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    final locale = normalized.contains('_') || normalized.contains('-')
        ? normalized.split(RegExp(r'[-_]')).first
        : normalized;
    return locale.toLowerCase();
  }

  static String _normalizeHost(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  static String _sanitizeRequestPath(Uri? uri) {
    if (uri == null) {
      return '';
    }

    final path = uri.path.isEmpty ? uri.toString().split('?').first : uri.path;
    return path.isEmpty ? '/' : path;
  }

  static Map<String, Object> _sanitizeProperties(
      Map<String, Object?> properties) {
    final sanitized = <String, Object>{};
    properties.forEach((key, value) {
      final sanitizedValue = _sanitizeValue(value);
      if (sanitizedValue != null) {
        sanitized[key] = sanitizedValue;
      }
    });
    return sanitized;
  }

  static Object? _sanitizeValue(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      final sanitized = _sanitizeString(value);
      return sanitized.isEmpty ? null : sanitized;
    }

    if (value is num || value is bool) {
      return value;
    }

    if (value is Enum) {
      return value.name;
    }

    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is Uri) {
      return _sanitizeString(value.toString());
    }

    if (value is Iterable) {
      final items = value
          .map((item) => _sanitizeValue(item))
          .whereType<Object>()
          .toList();
      return items;
    }

    if (value is Map) {
      final map = <String, Object>{};
      value.forEach((key, nestedValue) {
        final sanitizedValue = _sanitizeValue(nestedValue);
        if (sanitizedValue != null) {
          map[key.toString()] = sanitizedValue;
        }
      });
      return map;
    }

    return _sanitizeString(value.toString());
  }

  static String _resolveAuthMode(User user) {
    final hasEmail = (user.email ?? '').trim().isNotEmpty;
    final hasPhone = (user.phone ?? '').trim().isNotEmpty;

    if (hasEmail) {
      return 'email';
    }
    if (hasPhone) {
      return 'phone';
    }
    return 'device_only';
  }

  static bool _isTempAccount(User user) {
    final hasEmail = (user.email ?? '').trim().isNotEmpty;
    final hasPhone = (user.phone ?? '').trim().isNotEmpty;
    final hasDeviceId = (user.deviceId ?? '').trim().isNotEmpty;
    return !hasEmail && !hasPhone && hasDeviceId;
  }

  static String _sanitizeString(String value) {
    var sanitized = value.trim();
    if (sanitized.isEmpty) {
      return sanitized;
    }

    sanitized = sanitized.replaceAll(
      RegExp(r'Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*', caseSensitive: false),
      'Bearer [redacted]',
    );
    sanitized = sanitized.replaceAll(
      RegExp(
        r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
        caseSensitive: false,
      ),
      '[redacted_email]',
    );

    if (sanitized.length > 240) {
      sanitized = '${sanitized.substring(0, 240)}...';
    }

    return sanitized;
  }
}
