import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/glass_card.dart';

class ThemeColorScreen extends StatelessWidget {
  const ThemeColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('主题配色')),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ThemeProvider.colorNames.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final isSelected = themeProvider.colorIndex == index;
              final colors = _getThemeColors(index);

              return GestureDetector(
                onTap: () => themeProvider.setColorScheme(index),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: colors['primary'],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: colors['onPrimary'], size: 28)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ThemeProvider.colorNames[index],
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _colorDot(colors['primary']!),
                                const SizedBox(width: 6),
                                _colorDot(colors['secondary']!),
                                const SizedBox(width: 6),
                                _colorDot(colors['surface']!, borderColor: Colors.grey.withValues(alpha: 0.3)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelected) Icon(Icons.check_circle, color: cs.primary, size: 26),
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

  Widget _colorDot(Color color, {Color? borderColor}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor ?? Colors.transparent, width: 1),
      ),
    );
  }

  Map<String, Color> _getThemeColors(int index) {
    switch (index) {
      case 0:
        return {'primary': const Color(0xFF5B9BD5), 'onPrimary': Colors.white, 'secondary': const Color(0xFFE8F4FD), 'surface': const Color(0xFFF5F7FA)};
      case 1:
        return {'primary': const Color(0xFF4CAF50), 'onPrimary': Colors.white, 'secondary': const Color(0xFFE8F5E9), 'surface': const Color(0xFFF5F7F5)};
      case 2:
        return {'primary': const Color(0xFFD4A574), 'onPrimary': Colors.white, 'secondary': const Color(0xFFFDF5EB), 'surface': const Color(0xFFFAF7F4)};
      case 3:
        return {'primary': const Color(0xFF9B7ED8), 'onPrimary': Colors.white, 'secondary': const Color(0xFFF3EEFA), 'surface': const Color(0xFFF7F5FC)};
      case 4:
        return {'primary': const Color(0xFF95A5A6), 'onPrimary': Colors.white, 'secondary': const Color(0xFFF0F2F3), 'surface': const Color(0xFFFAFBFC)};
      default:
        return {'primary': const Color(0xFF5B9BD5), 'onPrimary': Colors.white, 'secondary': const Color(0xFFE8F4FD), 'surface': const Color(0xFFF5F7FA)};
    }
  }
}
