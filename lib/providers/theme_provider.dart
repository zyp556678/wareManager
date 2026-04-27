import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  int _colorIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;
  late SharedPreferences _prefs;

  static const List<String> colorNames = [
    '曜石青蓝',
    '薄荷森绿',
    '晨曦柔粉',
    '暮光紫罗兰',
  ];

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _colorIndex = _prefs.getInt('colorIndex') ?? 0;
    final modeIndex = _prefs.getInt('themeMode') ?? 2;
    _themeMode = ThemeMode.values[modeIndex];
    notifyListeners();
  }

  int get colorIndex => _colorIndex;
  ThemeMode get themeMode => _themeMode;

  void setColorScheme(int index) {
    if (_colorIndex == index) return;
    _colorIndex = index;
    _prefs.setInt('colorIndex', index);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  ThemeData get lightTheme => _buildThemeData(Brightness.light);
  ThemeData get darkTheme => _buildThemeData(Brightness.dark);

  ThemeData _buildThemeData(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    ColorScheme colorScheme;
    switch (_colorIndex) {
      case 0:
        colorScheme = isLight
            ? const ColorScheme.light(
                primary: Color(0xFF64B5F6),
                onPrimary: Colors.white,
                secondary: Color(0xFFE3F2FD),
                onSecondary: Color(0xFF0D47A1),
                surface: Color(0xFFFAFAFA),
                onSurface: Color(0xFF37474F),
                error: Color(0xFFE57373),
                onError: Colors.white,
                outline: Color(0xFFBBDEFB),
              )
            : const ColorScheme.dark(
                primary: Color(0xFF90CAF9),
                onPrimary: Color(0xFF0D47A1),
                secondary: Color(0xFF1E3A5F),
                onSecondary: Color(0xFFE3F2FD),
                surface: Color(0xFF1A1A2E),
                onSurface: Color(0xFFE3F2FD),
                error: Color(0xFFEF9A9A),
                onError: Color(0xFF1A1A2E),
                outline: Color(0xFF2E5A8F),
              );
        break;
      case 1:
        colorScheme = isLight
            ? const ColorScheme.light(
                primary: Color(0xFF81C784),
                onPrimary: Colors.white,
                secondary: Color(0xFFE8F5E9),
                onSecondary: Color(0xFF1B5E20),
                surface: Color(0xFFFAFAFA),
                onSurface: Color(0xFF37474F),
                error: Color(0xFFE57373),
                onError: Colors.white,
                outline: Color(0xFFC8E6C9),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFA5D6A7),
                onPrimary: Color(0xFF1B5E20),
                secondary: Color(0xFF1B3D1F),
                onSecondary: Color(0xFFE8F5E9),
                surface: Color(0xFF1A2E1C),
                onSurface: Color(0xFFE8F5E9),
                error: Color(0xFFEF9A9A),
                onError: Color(0xFF1A2E1C),
                outline: Color(0xFF2E5530),
              );
        break;
      case 2:
        colorScheme = isLight
            ? const ColorScheme.light(
                primary: Color(0xFFF48FB1),
                onPrimary: Colors.white,
                secondary: Color(0xFFFCE4EC),
                onSecondary: Color(0xFF880E4F),
                surface: Color(0xFFFAFAFA),
                onSurface: Color(0xFF37474F),
                error: Color(0xFFE57373),
                onError: Colors.white,
                outline: Color(0xFFF8BBD0),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFF06292),
                onPrimary: Color(0xFF880E4F),
                secondary: Color(0xFF3D1A2A),
                onSecondary: Color(0xFFFCE4EC),
                surface: Color(0xFF1A1418),
                onSurface: Color(0xFFFCE4EC),
                error: Color(0xFFEF9A9A),
                onError: Color(0xFF1A1418),
                outline: Color(0xFF5E2A3D),
              );
        break;
      case 3:
        colorScheme = isLight
            ? const ColorScheme.light(
                primary: Color(0xFFBA68C8),
                onPrimary: Colors.white,
                secondary: Color(0xFFF3E5F5),
                onSecondary: Color(0xFF4A148C),
                surface: Color(0xFFFAFAFA),
                onSurface: Color(0xFF37474F),
                error: Color(0xFFE57373),
                onError: Colors.white,
                outline: Color(0xFFE1BEE7),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFCE93D8),
                onPrimary: Color(0xFF4A148C),
                secondary: Color(0xFF2E1A3E),
                onSecondary: Color(0xFFF3E5F5),
                surface: Color(0xFF1A1524),
                onSurface: Color(0xFFF3E5F5),
                error: Color(0xFFEF9A9A),
                onError: Color(0xFF1A1524),
                outline: Color(0xFF4A2A50),
              );
        break;
      default:
        colorScheme = isLight ? const ColorScheme.light() : const ColorScheme.dark();
    }
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.secondary.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
      ),
    );
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  Color get glassColor => isDark
      ? Colors.black.withValues(alpha: 0.6)
      : Colors.white.withValues(alpha: 0.7);

  Color get glassBorderColor => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.white.withValues(alpha: 0.3);

  Color get glassOverlayColor => isDark
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.black.withValues(alpha: 0.05);
}