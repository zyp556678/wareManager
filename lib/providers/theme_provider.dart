import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  int _colorIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;
  String? _backgroundPath;
  bool _backgroundEnabled = false;
  double _backgroundOpacity = 0.3;
  late SharedPreferences _prefs;

  static const List<String> colorNames = [
    '冰川蓝',
    '翡翠绿',
    '玫瑰金',
    '星空紫',
    '月光银',
  ];

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _colorIndex = _prefs.getInt('colorIndex') ?? 0;
    final modeIndex = _prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[modeIndex];
    _backgroundPath = _prefs.getString('background_path');
    _backgroundEnabled = _prefs.getBool('background_enabled') ?? false;
    _backgroundOpacity = _prefs.getDouble('background_opacity') ?? 0.3;
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

  // 自定义背景
  String? get backgroundPath => _backgroundPath;
  bool get backgroundEnabled => _backgroundEnabled;

  void setBackground(String? path) {
    _backgroundPath = path;
    if (path != null) {
      _prefs.setString('background_path', path);
    } else {
      _prefs.remove('background_path');
    }
    notifyListeners();
  }

  void toggleBackground(bool enabled) {
    if (_backgroundEnabled == enabled) return;
    _backgroundEnabled = enabled;
    _prefs.setBool('background_enabled', enabled);
    notifyListeners();
  }

  double get backgroundOpacity => _backgroundOpacity;

  void setBackgroundOpacity(double value) {
    final clamped = value.clamp(0.0, 1.0);
    if (_backgroundOpacity == clamped) return;
    _backgroundOpacity = clamped;
    _prefs.setDouble('background_opacity', clamped);
    notifyListeners();
  }

  ThemeData get lightTheme => _buildThemeData(Brightness.light);
  ThemeData get darkTheme => _buildThemeData(Brightness.dark);

  ThemeData _buildThemeData(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    ColorScheme cs;
    switch (_colorIndex) {
      case 0:
        cs = isLight
            ? const ColorScheme.light(
                primary: Color(0xFF5B9BD5),
                onPrimary: Colors.white,
                secondary: Color(0xFFE8F4FD),
                onSecondary: Color(0xFF1A3C5E),
                surface: Color(0xFFF5F7FA),
                onSurface: Color(0xFF2C3E50),
                error: Color(0xFFE74C3C),
                onError: Colors.white,
                outline: Color(0xFFB8D4E8),
              )
            : const ColorScheme.dark(
                primary: Color(0xFF7BB8E0),
                onPrimary: Color(0xFF0D2137),
                secondary: Color(0xFF1A2A3A),
                onSecondary: Color(0xFFE8F4FD),
                surface: Color(0xFF0F1923),
                onSurface: Color(0xFFE8F4FD),
                error: Color(0xFFE74C3C),
                onError: Color(0xFF0F1923),
                outline: Color(0xFF2A4A6A),
              );
        break;
      case 1:
        cs = isLight
            ? const ColorScheme.light(
                primary: Color(0xFF4CAF50),
                onPrimary: Colors.white,
                secondary: Color(0xFFE8F5E9),
                onSecondary: Color(0xFF1B5E20),
                surface: Color(0xFFF5F7F5),
                onSurface: Color(0xFF2E4A3E),
                error: Color(0xFFE74C3C),
                onError: Colors.white,
                outline: Color(0xFFB8D4B8),
              )
            : const ColorScheme.dark(
                primary: Color(0xFF66BB6A),
                onPrimary: Color(0xFF0D2110),
                secondary: Color(0xFF1A2A1C),
                onSecondary: Color(0xFFE8F5E9),
                surface: Color(0xFF0F1910),
                onSurface: Color(0xFFE8F5E9),
                error: Color(0xFFE74C3C),
                onError: Color(0xFF0F1910),
                outline: Color(0xFF2A4A2E),
              );
        break;
      case 2:
        cs = isLight
            ? const ColorScheme.light(
                primary: Color(0xFFD4A574),
                onPrimary: Colors.white,
                secondary: Color(0xFFFDF5EB),
                onSecondary: Color(0xFF5C3A1E),
                surface: Color(0xFFFAF7F4),
                onSurface: Color(0xFF3E2C1C),
                error: Color(0xFFE74C3C),
                onError: Colors.white,
                outline: Color(0xFFE8D4BC),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFE0B88A),
                onPrimary: Color(0xFF2E1A0D),
                secondary: Color(0xFF2A2018),
                onSecondary: Color(0xFFFDF5EB),
                surface: Color(0xFF191410),
                onSurface: Color(0xFFFDF5EB),
                error: Color(0xFFE74C3C),
                onError: Color(0xFF191410),
                outline: Color(0xFF4A3A2A),
              );
        break;
      case 3:
        cs = isLight
            ? const ColorScheme.light(
                primary: Color(0xFF9B7ED8),
                onPrimary: Colors.white,
                secondary: Color(0xFFF3EEFA),
                onSecondary: Color(0xFF2E1A5E),
                surface: Color(0xFFF7F5FC),
                onSurface: Color(0xFF2C2040),
                error: Color(0xFFE74C3C),
                onError: Colors.white,
                outline: Color(0xFFD4C4E8),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFB09AE0),
                onPrimary: Color(0xFF1A0D37),
                secondary: Color(0xFF201A2A),
                onSecondary: Color(0xFFF3EEFA),
                surface: Color(0xFF141020),
                onSurface: Color(0xFFF3EEFA),
                error: Color(0xFFE74C3C),
                onError: Color(0xFF141020),
                outline: Color(0xFF3A2A5A),
              );
        break;
      case 4:
        cs = isLight
            ? const ColorScheme.light(
                primary: Color(0xFF95A5A6),
                onPrimary: Colors.white,
                secondary: Color(0xFFF0F2F3),
                onSecondary: Color(0xFF34495E),
                surface: Color(0xFFFAFBFC),
                onSurface: Color(0xFF2C3E50),
                error: Color(0xFFE74C3C),
                onError: Colors.white,
                outline: Color(0xFFD8DEE0),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFB0BEC5),
                onPrimary: Color(0xFF1A2128),
                secondary: Color(0xFF1E2428),
                onSecondary: Color(0xFFF0F2F3),
                surface: Color(0xFF121618),
                onSurface: Color(0xFFF0F2F3),
                error: Color(0xFFE74C3C),
                onError: Color(0xFF121618),
                outline: Color(0xFF3A4A50),
              );
        break;
      default:
        cs = isLight ? const ColorScheme.light() : const ColorScheme.dark();
    }
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      canvasColor: cs.surface,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.secondary.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface.withValues(alpha: 0.8),
        indicatorColor: cs.primary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 72,
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  bool get isDark {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  Color get glassColor => isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.6);

  Color get glassBorderColor => isDark
      ? Colors.white.withValues(alpha: 0.15)
      : Colors.white.withValues(alpha: 0.5);

  Color get glassOverlayColor => isDark
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.black.withValues(alpha: 0.03);
}
