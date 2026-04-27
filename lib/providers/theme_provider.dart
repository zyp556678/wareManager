import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  int _colorIndex = 0;
  ThemeMode _themeMode = ThemeMode.system;
  late SharedPreferences _prefs;

  static const List<String> colorNames = [
    '晨间燕麦',
    '海盐薄荷',
    '摩卡拿铁',
    '薰衣草灰',
    '极简石墨',
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
                primary: Color(0xFF9C7B6C),
                onPrimary: Colors.white,
                secondary: Color(0xFFE9DACB),
                onSecondary: Color(0xFF2C2A29),
                surface: Color(0xFFFDF8F5),
                onSurface: Color(0xFF2C2A29),
                error: Color(0xFFD97A7A),
                onError: Colors.white,
                outline: Color(0xFFEFE2D6),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFB5927F),
                onPrimary: Color(0xFF1E1A18),
                secondary: Color(0xFF3D332C),
                onSecondary: Color(0xFFE9DACB),
                surface: Color(0xFF1E1A18),
                onSurface: Color(0xFFFDF8F5),
                error: Color(0xFFE88D67),
                onError: Color(0xFF2C2A29),
                outline: Color(0xFF4A3F38),
              );
        break;
      case 1:
        colorScheme = isLight
            ? const ColorScheme.light(
                primary: Color(0xFF6C9E8A),
                onPrimary: Colors.white,
                secondary: Color(0xFFDEEDE6),
                onSecondary: Color(0xFF1F2E2A),
                surface: Color(0xFFF5FBF8),
                onSurface: Color(0xFF1F2E2A),
                error: Color(0xFFF4B784),
                onError: Color(0xFF1F2E2A),
                outline: Color(0xFFDCE9E2),
              )
            : const ColorScheme.dark(
                primary: Color(0xFF8BBBA5),
                onPrimary: Color(0xFF1A2A24),
                secondary: Color(0xFF2D3F38),
                onSecondary: Color(0xFFDEEDE6),
                surface: Color(0xFF1C2622),
                onSurface: Color(0xFFF5FBF8),
                error: Color(0xFFD99E6B),
                onError: Color(0xFF1F2E2A),
                outline: Color(0xFF3B5348),
              );
        break;
      case 2:
        colorScheme = isLight
            ? const ColorScheme.light(
                primary: Color(0xFFB87B5E),
                onPrimary: Colors.white,
                secondary: Color(0xFFF0E2D4),
                onSecondary: Color(0xFF3A2C28),
                surface: Color(0xFFFCF8F2),
                onSurface: Color(0xFF3A2C28),
                error: Color(0xFFC97B5A),
                onError: Colors.white,
                outline: Color(0xFFEADBCE),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFD49B7C),
                onPrimary: Color(0xFF2A1E18),
                secondary: Color(0xFF3D2E26),
                onSecondary: Color(0xFFF0E2D4),
                surface: Color(0xFF201A16),
                onSurface: Color(0xFFFCF8F2),
                error: Color(0xFFE0926A),
                onError: Color(0xFF2A1E18),
                outline: Color(0xFF4E3D32),
              );
        break;
      case 3:
        colorScheme = isLight
            ? const ColorScheme.light(
                primary: Color(0xFFA192B2),
                onPrimary: Colors.white,
                secondary: Color(0xFFEAE3F2),
                onSecondary: Color(0xFF2D2A33),
                surface: Color(0xFFFEFAFD),
                onSurface: Color(0xFF2D2A33),
                error: Color(0xFFF0A6A6),
                onError: Color(0xFF2D2A33),
                outline: Color(0xFFE8E0F0),
              )
            : const ColorScheme.dark(
                primary: Color(0xFFBDAAD0),
                onPrimary: Color(0xFF201C2A),
                secondary: Color(0xFF342E3D),
                onSecondary: Color(0xFFEAE3F2),
                surface: Color(0xFF1F1B24),
                onSurface: Color(0xFFFEFAFD),
                error: Color(0xFFF2B3B3),
                onError: Color(0xFF2D2A33),
                outline: Color(0xFF4A4159),
              );
        break;
      case 4:
        colorScheme = isLight
            ? const ColorScheme.light(
                primary: Color(0xFF3A7B70),
                onPrimary: Colors.white,
                secondary: Color(0xFFE9F0EF),
                onSecondary: Color(0xFF1E2422),
                surface: Color(0xFFF7F9F9),
                onSurface: Color(0xFF1E2422),
                error: Color(0xFFC44536),
                onError: Colors.white,
                outline: Color(0xFFE2E9E7),
              )
            : const ColorScheme.dark(
                primary: Color(0xFF5C9E8F),
                onPrimary: Color(0xFF1A2422),
                secondary: Color(0xFF2C3A36),
                onSecondary: Color(0xFFE9F0EF),
                surface: Color(0xFF1C2220),
                onSurface: Color(0xFFF7F9F9),
                error: Color(0xFFD96A5A),
                onError: Color(0xFF1E2422),
                outline: Color(0xFF3D4E48),
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
        elevation: 2,
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
        backgroundColor: Colors.transparent,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
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