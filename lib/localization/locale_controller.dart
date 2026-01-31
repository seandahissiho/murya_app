import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _k = 'preferred_locale';
  Locale? _locale = const Locale('fr');

  Locale? get locale => _locale;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_k);
    final resolvedCode = _normalizeCode(code);
    _locale = resolvedCode == null ? null : Locale(resolvedCode);
    _setIntlLocale(_locale);
    notifyListeners();
  }

  Future<void> set(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    final code = _normalizeCode(locale?.languageCode);
    if (code == null) {
      _locale = null;
      await prefs.remove(_k);
    } else {
      _locale = Locale(code);
      await prefs.setString(_k, code);
    }
    _setIntlLocale(_locale);
    notifyListeners();
  }

  String? _normalizeCode(String? code) {
    if (code == null) return null;
    if (code == 'fr' || code == 'en') return code;
    return 'fr';
  }

  void _setIntlLocale(Locale? locale) {
    final resolved = locale ?? WidgetsBinding.instance.platformDispatcher.locale;
    intl.Intl.defaultLocale = intl.Intl.canonicalizedLocale(resolved.toLanguageTag());
  }
}
