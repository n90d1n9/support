import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme mode with persistence.
///
/// Theme preference is saved to SharedPreferences and restored on app restart.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (_) => ThemeModeNotifier(),
);

/// Notifier for theme mode that handles persistence.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _prefsKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  /// Loads the saved theme mode from SharedPreferences.
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getInt(_prefsKey);
      if (savedTheme != null) {
        state = ThemeMode.values[savedTheme];
      }
    } catch (e) {
      // Silently fail and use default theme
      debugPrint('Failed to load theme preference: $e');
    }
  }

  /// Sets the theme mode and persists it to SharedPreferences.
  Future<void> setTheme(ThemeMode mode) async {
    try {
      state = mode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, mode.index);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }

  /// Toggles between light and dark mode.
  Future<void> toggle() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }
}
