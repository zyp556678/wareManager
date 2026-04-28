import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/clothing_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/bento_grid.dart';
import '../widgets/weather_card.dart';
import 'clothing_detail_page.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  final Function(int)? onNavigateToWardrobeTab;

  const HomeScreen({super.key, this.onNavigateToTab, this.onNavigateToWardrobeTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _avatarPath;
  String _username = '用户';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClothingProvider>().loadClothingItems();
      _loadUserProfile();
      _loadWeather();
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _avatarPath = prefs.getString('avatar_path');
          _username = prefs.getString('username') ?? '用户';
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _loadWeather() async {
    final weatherProvider = context.read<WeatherProvider>();
    if (weatherProvider.hasData) return;

    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null && mounted) {
        await weatherProvider.loadWeatherByCoords(
          position.latitude,
          position.longitude,
        );
      }
    } catch (e) {
      debugPrint('HomeScreen: Failed to load weather: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早上好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: TextStyle(
                          fontSize: 15,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _username,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => widget.onNavigateToTab?.call(3),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _avatarPath != null && _avatarPath!.isNotEmpty
                            ? Image.file(File(_avatarPath!), fit: BoxFit.cover)
                            : Container(
                                color: cs.primaryContainer,
                                child: Icon(Icons.person, color: cs.onPrimaryContainer, size: 26),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const WeatherCard(),
              const SizedBox(height: 12),
              Consumer<ClothingProvider>(
                builder: (context, provider, child) {
                  final activeCount = provider.activeClothing.length;
                  final idleCount = provider.idleClothing.length;
                  final recentItems = provider.clothingItems.take(4).toList();

                  return BentoGrid(
                    crossAxisCount: 2,
                    items: [
                      BentoItem(
                        span: 2,
                        height: 120,
                        child: GlassCard(
                          onTap: () => widget.onNavigateToTab?.call(1),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.checkroom, color: cs.primary, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '衣橱总览',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: cs.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$activeCount 件在用 · $idleCount 件闲置',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: cs.onSurface.withValues(alpha: 0.3)),
                            ],
                          ),
                        ),
                      ),
                      BentoItem(
                        height: 140,
                        child: GlassCard(
                          onTap: () => widget.onNavigateToTab?.call(2),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.add_a_photo, color: cs.primary, size: 22),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '录入衣物',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '拍照或相册添加',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      BentoItem(
                        height: 140,
                        child: GlassCard(
                          onTap: () => widget.onNavigateToWardrobeTab?.call(1),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cs.error.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.archive_outlined, color: cs.error, size: 22),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '闲置管理',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$idleCount 件待处理',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (recentItems.isNotEmpty) ...[
                        BentoItem(
                          span: 2,
                          height: 180,
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '最近存入',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => widget.onNavigateToTab?.call(1),
                                      child: Text(
                                        '查看全部',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: cs.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 110,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: recentItems.length,
                                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                                    itemBuilder: (context, index) {
                                      final item = recentItems[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ClothingDetailPage(item: item),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Stack(
                                            children: [
                                              SizedBox(
                                                width: 90,
                                                height: 110,
                                                child: item.imagePath.isNotEmpty
                                                    ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                                                    : Container(
                                                        color: cs.secondary.withValues(alpha: 0.5),
                                                        child: Icon(
                                                          Icons.checkroom_outlined,
                                                          size: 36,
                                                          color: cs.onSurface.withValues(alpha: 0.3),
                                                        ),
                                                      ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                      colors: [
                                                        Colors.transparent,
                                                        Colors.black.withValues(alpha: 0.6),
                                                      ],
                                                    ),
                                                    borderRadius: const BorderRadius.vertical(
                                                      bottom: Radius.circular(14),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    item.category,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
