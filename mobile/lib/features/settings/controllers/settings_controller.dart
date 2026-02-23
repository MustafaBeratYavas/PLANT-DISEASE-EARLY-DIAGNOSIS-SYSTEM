import 'package:flutter/material.dart';
import '../../../services/storage/preferences_service.dart';

class SettingsController with ChangeNotifier {
  final PreferencesService _preferencesService;

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  SettingsController(this._preferencesService);

  // State getters
  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  // Load persisted settings
  Future<void> loadSettings() async {
    _themeMode = await _preferencesService.getThemeMode();
    _locale = await _preferencesService.getLocale();
    notifyListeners();
  }

  // Update theme mode
  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();
    await _preferencesService.saveThemeMode(newThemeMode);
  }

  // Update application locale
  Future<void> updateLocale(Locale? newLocale) async {
    if (newLocale == null) return;
    if (newLocale == _locale) return;

    _locale = newLocale;
    notifyListeners();
    await _preferencesService.saveLocale(newLocale.languageCode);
  }
}