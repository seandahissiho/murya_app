// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:js' as js;

Future<String?> detectPlatformTimezoneImpl() async {
  try {
    final intl = js.context['Intl'];
    if (intl == null) {
      return null;
    }

    final formatter = js.JsObject.fromBrowserObject(intl).callMethod(
      'DateTimeFormat',
    );
    final options = (formatter as js.JsObject).callMethod('resolvedOptions');
    final timezone = (options as js.JsObject)['timeZone'];
    if (timezone is String && timezone.trim().isNotEmpty) {
      return timezone.trim();
    }
  } catch (_) {
    return null;
  }

  return null;
}
