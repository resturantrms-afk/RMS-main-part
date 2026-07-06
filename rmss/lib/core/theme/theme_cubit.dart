import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme(); // Load the saved theme when the Cubit is initialized
  }

  static const _themeKey = 'theme_preference';

  // 1. Read from Disk on Startup
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'light') {
      emit(ThemeMode.light);
    } else if (savedTheme == 'dark') {
      emit(ThemeMode.dark);
    }
  }

  // 2. Write to Disk when Changed (Supports both toggle without args, and explicit set)
  Future<void> toggleTheme([bool? isDark]) async {
    final prefs = await SharedPreferences.getInstance();
    
    final newMode = isDark != null 
        ? (isDark ? ThemeMode.dark : ThemeMode.light) 
        : (state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);

    emit(newMode);
    await prefs.setString(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
  }
}
