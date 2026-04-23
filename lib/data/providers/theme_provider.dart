import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  late Box _settingsBox;
  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = AppColors.primary;

  ThemeProvider() {
    _settingsBox = Hive.box(AppConstants.settingsBox);
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Color get accentColor => _accentColor;

  void _loadTheme() {
    // Загружаем режим (светлый/темный)
    final themeIndex = _settingsBox.get(AppConstants.keyThemeMode, defaultValue: 0);
    _themeMode = ThemeMode.values[themeIndex];
    
    // Загружаем акцентный цвет
    final colorValue = _settingsBox.get('accent_color');
    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }
    
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _settingsBox.put(AppConstants.keyThemeMode, _themeMode.index);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _settingsBox.put(AppConstants.keyThemeMode, mode.index);
    notifyListeners();
  }

  // Метод для "покупки" или смены темы в магазине
  void setAccentColor(Color color) {
    _accentColor = color;
    _settingsBox.put('accent_color', color.value);
    notifyListeners();
  }
}
