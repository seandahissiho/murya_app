import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  static const String _prefix = 'murya_cache_';

  factory CacheService() {
    return _instance;
  }

  CacheService._internal();

  Future<void> save(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', json.encode(data));
  }

  Future<Map<String, dynamic>?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('$_prefix$key');
    if (jsonString == null) return null;
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith(_prefix)) {
        await prefs.remove(key);
      }
    }
  }
}
