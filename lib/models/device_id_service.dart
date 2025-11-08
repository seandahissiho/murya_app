import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdService {
  static const _storageKey = 'app_device_id';
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const Uuid _uuid = Uuid();

  Future<String> getUniqueDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedDeviceId = prefs.getString(_storageKey);

    if (storedDeviceId != null) {
      return storedDeviceId;
    }

    // Generate and store a new device ID
    String newDeviceId = await _generateDeviceId();
    await prefs.setString(_storageKey, newDeviceId);
    return newDeviceId;
  }

  Future<String> _generateDeviceId() async {
    if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      final seed = '${webInfo.vendor}${webInfo.userAgent}${webInfo.hardwareConcurrency}';
      return _uuid.v5(Uuid.NAMESPACE_URL, seed);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id ?? _uuid.v4(); // ANDROID_ID (unique per device)
      case TargetPlatform.iOS:
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? _uuid.v4();
      case TargetPlatform.macOS:
        final macInfo = await _deviceInfo.macOsInfo;
        return macInfo.systemGUID ?? _uuid.v4();
      case TargetPlatform.windows:
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.deviceId ?? _uuid.v4();
      case TargetPlatform.linux:
        final linuxInfo = await _deviceInfo.linuxInfo;
        final seed = '${linuxInfo.machineId}${linuxInfo.prettyName}';
        return _uuid.v5(Uuid.NAMESPACE_URL, seed);
      default:
        // Fallback for unknown platforms
        return _uuid.v4();
    }
  }
}
