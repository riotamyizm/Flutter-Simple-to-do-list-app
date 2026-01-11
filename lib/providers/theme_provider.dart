import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _notificationKey = 'notifications_enabled';

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null && themeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeIndex];
      }

      _notificationsEnabled = prefs.getBool(_notificationKey) ?? true;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
      // Keep defaults on error
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  Future<void> toggleNotifications(bool enabled) async {
    if (_notificationsEnabled == enabled) return;

    _notificationsEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, enabled);
    } catch (e) {
      debugPrint('Error saving notification preference: $e');
    }
  }

  Future<void> reset() async {
    _themeMode = ThemeMode.system;
    _notificationsEnabled = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeKey);
      await prefs.remove(_notificationKey);
    } catch (e) {
      debugPrint('Error resetting preferences: $e');
    }
  }
}