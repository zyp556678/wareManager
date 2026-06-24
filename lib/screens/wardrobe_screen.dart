import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'wardrobe_tab.dart';
import 'idle_tab.dart';
import 'outfit_log_tab.dart';

class WardrobeScreen extends StatefulWidget {
  final int initialTab;

  const WardrobeScreen({super.key, this.initialTab = 0});

  @override
  State<WardrobeScreen> createState() => WardrobeScreenState();
}

class WardrobeScreenState extends State<WardrobeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  void switchToTab(int index) {
    if (index >= 0 && index < 3) {
      _tabController.animateTo(index);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = ['衣橱', '闲置', '日志'];

    final tp = context.watch<ThemeProvider>();
    final bgColor = tp.backgroundEnabled
        ? cs.surface.withValues(alpha: tp.backgroundOpacity)
        : null;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    '我的衣橱',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? cs.secondary.withValues(alpha: 0.2) : cs.secondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: List.generate(tabs.length, (index) {
                    final isSelected = _tabController.index == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _tabController.animateTo(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? cs.primary.withValues(alpha: 0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tabs[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  WardrobeTab(),
                  IdleTab(),
                  OutfitLogTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
