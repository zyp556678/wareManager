import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeColorScreen extends StatelessWidget {
  const ThemeColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('主题配色'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ThemeProvider.colorNames.length,
            itemBuilder: (context, index) {
              final isSelected = themeProvider.colorIndex == index;
              final colors = _getThemeColors(index);

              return GestureDetector(
                onTap: () => themeProvider.setColorScheme(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: colorScheme.primary, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: colors['primary'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check,
                            color: colors['onPrimary'],
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ThemeProvider.colorNames[index],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors['onSurface'],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colors['primary'],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 32,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colors['secondary'],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 32,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: colors['surface'],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: colors['onSurface']!.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<String, Color> _getThemeColors(int index) {
    switch (index) {
      case 0:
        return {
          'primary': const Color(0xFF64B5F6),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFE3F2FD),
          'onSecondary': const Color(0xFF0D47A1),
          'surface': const Color(0xFFFAFAFA),
          'onSurface': const Color(0xFF37474F),
        };
      case 1:
        return {
          'primary': const Color(0xFF81C784),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFE8F5E9),
          'onSecondary': const Color(0xFF1B5E20),
          'surface': const Color(0xFFFAFAFA),
          'onSurface': const Color(0xFF37474F),
        };
      case 2:
        return {
          'primary': const Color(0xFFF48FB1),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFFCE4EC),
          'onSecondary': const Color(0xFF880E4F),
          'surface': const Color(0xFFFAFAFA),
          'onSurface': const Color(0xFF37474F),
        };
      case 3:
        return {
          'primary': const Color(0xFFBA68C8),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFF3E5F5),
          'onSecondary': const Color(0xFF4A148C),
          'surface': const Color(0xFFFAFAFA),
          'onSurface': const Color(0xFF37474F),
        };
      default:
        return {
          'primary': const Color(0xFF64B5F6),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFE3F2FD),
          'onSecondary': const Color(0xFF0D47A1),
          'surface': const Color(0xFFFAFAFA),
          'onSurface': const Color(0xFF37474F),
        };
    }
  }
}