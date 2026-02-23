import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_providers.dart';

// Provider for the ThemeMode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;

  ThemeModeNotifier(this._prefs) : super(_getInitialTheme(_prefs));

  static ThemeMode _getInitialTheme(SharedPreferences? prefs) {
    if (prefs == null) return ThemeMode.system;
    final savedTheme = prefs.getString('theme_mode');
    if (savedTheme == 'light') return ThemeMode.light;
    if (savedTheme == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    if (_prefs != null) {
      String value = 'system';
      if (mode == ThemeMode.light) value = 'light';
      if (mode == ThemeMode.dark) value = 'dark';
      await _prefs!.setString('theme_mode', value);
    }
  }
}
