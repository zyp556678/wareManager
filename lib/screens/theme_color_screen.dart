import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';

class ThemeColorScreen extends StatelessWidget {
  const ThemeColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                child: GlassCard(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  borderColor: isSelected ? colorScheme.primary : null,
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
          'primary': const Color(0xFF9C7B6C),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFE9DACB),
          'onSecondary': const Color(0xFF2C2A29),
          'surface': const Color(0xFFFDF8F5),
          'onSurface': const Color(0xFF2C2A29),
        };
      case 1:
        return {
          'primary': const Color(0xFF6C9E8A),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFDEEDE6),
          'onSecondary': const Color(0xFF1F2E2A),
          'surface': const Color(0xFFF5FBF8),
          'onSurface': const Color(0xFF1F2E2A),
        };
      case 2:
        return {
          'primary': const Color(0xFFB87B5E),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFF0E2D4),
          'onSecondary': const Color(0xFF3A2C28),
          'surface': const Color(0xFFFCF8F2),
          'onSurface': const Color(0xFF3A2C28),
        };
      case 3:
        return {
          'primary': const Color(0xFFA192B2),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFEAE3F2),
          'onSecondary': const Color(0xFF2D2A33),
          'surface': const Color(0xFFFEFAFD),
          'onSurface': const Color(0xFF2D2A33),
        };
      case 4:
        return {
          'primary': const Color(0xFF3A7B70),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFE9F0EF),
          'onSecondary': const Color(0xFF1E2422),
          'surface': const Color(0xFFF7F9F9),
          'onSurface': const Color(0xFF1E2422),
        };
      default:
        return {
          'primary': const Color(0xFF9C7B6C),
          'onPrimary': Colors.white,
          'secondary': const Color(0xFFE9DACB),
          'onSecondary': const Color(0xFF2C2A29),
          'surface': const Color(0xFFFDF8F5),
          'onSurface': const Color(0xFF2C2A29),
        };
    }
  }
}