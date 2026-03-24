import 'package:flutter_timezone/flutter_timezone.dart';

Future<String?> detectPlatformTimezoneImpl() async {
  try {
    final timezone = await FlutterTimezone.getLocalTimezone();
    final identifier = timezone.identifier.trim();
    return identifier.isNotEmpty ? identifier : null;
  } catch (_) {
    return null;
  }
}
