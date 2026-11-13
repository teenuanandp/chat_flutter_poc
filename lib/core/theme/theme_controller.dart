
import 'package:flutter/material.dart';
import 'theme_storage.dart';

class ThemeController extends ChangeNotifier {
  final ThemeStorage _storage;

  ThemeController(this._storage);

  // Default theme selection
  ThemeMode _themeMode = ThemeMode.system;

  // Read-only access
  ThemeMode get themeMode => _themeMode;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Load saved preference
  Future<void> loadPreferences() async {
    _themeMode = await _storage.getThemeMode();

    _isInitialized = true;

    notifyListeners();
  }

  // Update selected theme
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;

    // Notify UI about the change
    notifyListeners();

    // Save preference
    await _storage.saveThemeMode(mode);
  }
}
