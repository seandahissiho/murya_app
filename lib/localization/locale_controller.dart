import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _k = 'preferred_locale';
  Locale? _locale = const Locale('fr');

  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_k);
    if (code != 'fr') {
      _locale = const Locale('fr');
      await prefs.setString(_k, 'fr');
    } else {
      _locale = const Locale('fr');
    }
    notifyListeners();
  }

  Future<void> set(Locale? locale) async {
    _locale = const Locale('fr');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_k, 'fr');
    notifyListeners();
  }
}
