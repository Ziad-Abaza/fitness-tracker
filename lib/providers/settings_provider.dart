import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';

class SettingsProvider with ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  late SharedPreferences _prefs;
  
  String _currentLocale = 'en';
  bool _isInitialized = false;

  String get currentLocale => _currentLocale;
  bool get isInitialized => _isInitialized;
  bool get isArabic => _currentLocale == 'ar';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _currentLocale = _prefs.getString(_localeKey) ?? 'en';
    Exercise.currentLocale = _currentLocale;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setLocale(String localeCode) async {
    if (_currentLocale == localeCode) return;
    
    _currentLocale = localeCode;
    Exercise.currentLocale = _currentLocale;
    await _prefs.setString(_localeKey, localeCode);
    notifyListeners();
  }

  void toggleLanguage() {
    setLocale(_currentLocale == 'en' ? 'ar' : 'en');
  }
}
