import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(const ThemeState());

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    final themeMode = ThemeMode.values[themeIndex];
    emit(ThemeState(themeMode: themeMode));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
    emit(ThemeState(themeMode: mode));
  }

  Future<void> toggleTheme() async {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  bool get isDarkMode => state.themeMode == ThemeMode.dark;
}
