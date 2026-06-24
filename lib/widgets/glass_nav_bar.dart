import 'package:flutter/material.dart';

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 32 + bottomSafe),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final innerWidth = constraints.maxWidth - 12; // 水平 padding 6*2
          final itemWidth = innerWidth / items.length;
          const indicatorWidth = 58.0;
          final indicatorLeft = currentIndex * itemWidth + (itemWidth - indicatorWidth) / 2;

          return Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A2E).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 滑动指示器
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: 2,
                  bottom: 2,
                  left: indicatorLeft,
                  width: indicatorWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(44),
                    ),
                  ),
                ),
                // 导航项
                Row(
                  children: List.generate(items.length, (index) {
                    final isSelected = index == currentIndex;
                    final item = items[index];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected
                                  ? cs.primary
                                  : cs.onSurface.withValues(alpha: 0.5),
                              size: 22,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? cs.primary
                                    : cs.onSurface.withValues(alpha: 0.5),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NavBarItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavBarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
