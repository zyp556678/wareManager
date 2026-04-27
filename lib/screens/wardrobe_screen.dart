import 'package:flutter/material.dart';
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
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('我的衣橱'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '衣橱'),
            Tab(text: '闲置'),
            Tab(text: '日志'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          WardrobeTab(),
          IdleTab(),
          OutfitLogTab(),
        ],
      ),
    );
  }
}
