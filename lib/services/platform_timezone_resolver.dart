import 'platform_timezone_resolver_stub.dart'
    if (dart.library.io) 'platform_timezone_resolver_io.dart'
    if (dart.library.html) 'platform_timezone_resolver_web.dart';

Future<String?> detectPlatformTimezone() => detectPlatformTimezoneImpl();
