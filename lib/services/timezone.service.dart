import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import 'platform_timezone_resolver.dart';

enum SharedPeriod { today, week, month }

extension SharedPeriodApi on SharedPeriod {
  String get apiValue {
    switch (this) {
      case SharedPeriod.today:
        return 'today';
      case SharedPeriod.week:
        return 'week';
      case SharedPeriod.month:
        return 'month';
    }
  }
}

class SharedPeriodWindow {
  final DateTime from;
  final DateTime to;

  const SharedPeriodWindow({
    required this.from,
    required this.to,
  });
}

class AppTimezoneService {
  AppTimezoneService._();

  static final AppTimezoneService instance = AppTimezoneService._();

  static const String _deviceTimezoneKey = 'murya_device_timezone';
  static const String _serverTimezoneKey = 'murya_server_timezone';
  static const String defaultUserTimezone = 'UTC';
  static const String defaultSharedTimezone = 'Europe/Paris';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String? normalizeTimezone(String? candidate) {
    if (candidate == null) {
      return null;
    }

    final trimmed = candidate.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      tz.getLocation(trimmed);
      return trimmed;
    } catch (_) {
      return null;
    }
  }

  String get sharedTimezone {
    return normalizeTimezone(dotenv.env['APP_SHARED_TIMEZONE']) ??
        defaultSharedTimezone;
  }

  Future<String> detectSystemTimezone() async {
    final prefs = await _getPrefs();
    final detectedTimezone = normalizeTimezone(await detectPlatformTimezone());
    if (detectedTimezone != null) {
      await prefs.setString(_deviceTimezoneKey, detectedTimezone);
      return detectedTimezone;
    }

    final cachedDeviceTimezone =
        normalizeTimezone(prefs.getString(_deviceTimezoneKey));
    final cachedServerTimezone =
        normalizeTimezone(prefs.getString(_serverTimezoneKey));
    final fallbackTimezone =
        cachedDeviceTimezone ?? cachedServerTimezone ?? defaultUserTimezone;

    await prefs.setString(_deviceTimezoneKey, fallbackTimezone);
    return fallbackTimezone;
  }

  Future<String> getRequestTimezone({String? preferred}) async {
    final preferredTimezone = normalizeTimezone(preferred);
    if (preferredTimezone != null) {
      return preferredTimezone;
    }

    return detectSystemTimezone();
  }

  Future<String> getCurrentUserTimezone({String? preferred}) async {
    final preferredTimezone = normalizeTimezone(preferred);
    if (preferredTimezone != null) {
      return preferredTimezone;
    }

    final prefs = await _getPrefs();
    final cachedServerTimezone =
        normalizeTimezone(prefs.getString(_serverTimezoneKey));
    if (cachedServerTimezone != null) {
      return cachedServerTimezone;
    }

    return detectSystemTimezone();
  }

  Future<void> rememberServerTimezone(String? timezone) async {
    final normalized = normalizeTimezone(timezone);
    if (normalized == null) {
      return;
    }

    final prefs = await _getPrefs();
    await prefs.setString(_serverTimezoneKey, normalized);
  }

  SharedPeriodWindow getSharedPeriodWindow(
    SharedPeriod period, {
    DateTime? referenceDate,
  }) {
    final location = tz.getLocation(sharedTimezone);
    final now = tz.TZDateTime.from(referenceDate ?? DateTime.now(), location);

    late final tz.TZDateTime start;
    late final tz.TZDateTime end;

    switch (period) {
      case SharedPeriod.today:
        start = tz.TZDateTime(location, now.year, now.month, now.day);
        end = tz.TZDateTime(location, now.year, now.month, now.day + 1);
        break;
      case SharedPeriod.week:
        final startOfDay = tz.TZDateTime(
          location,
          now.year,
          now.month,
          now.day,
        );
        final deltaDays = now.weekday - DateTime.monday;
        start = startOfDay.subtract(Duration(days: deltaDays));
        end = start.add(const Duration(days: 7));
        break;
      case SharedPeriod.month:
        start = tz.TZDateTime(location, now.year, now.month, 1);
        end = now.month < DateTime.december
            ? tz.TZDateTime(location, now.year, now.month + 1, 1)
            : tz.TZDateTime(location, now.year + 1, 1, 1);
        break;
    }

    return SharedPeriodWindow(from: start.toUtc(), to: end.toUtc());
  }

  String toApiUtcString(DateTime value) {
    final utc = value.toUtc();
    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    final millisecond = utc.millisecond.toString().padLeft(3, '0');
    return '$year-$month-$day'
        'T$hour:$minute:$second.$millisecond'
        'Z';
  }
}
