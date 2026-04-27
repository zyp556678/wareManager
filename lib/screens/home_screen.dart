import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clothing_provider.dart';
import '../widgets/glass_card.dart';
import 'clothing_detail_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 加载衣物数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClothingProvider>().loadClothingItems();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '早上好';
    } else if (hour < 18) {
      return '下午好';
    } else {
      return '晚上好';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 现代化顶部栏
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
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
                                fontSize: 16,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '我的衣橱',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 最近存入区域
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '最近存入',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('查看全部'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: const SizedBox(height: 12),
            ),

            // 衣物列表
            Consumer<ClothingProvider>(
              builder: (context, provider, child) {
                final recentItems = provider.clothingItems.take(5).toList();

                if (recentItems.isEmpty) {
                  return SliverToBoxAdapter(
                    child: GlassCard(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 40,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暂无衣物',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '点击下方 + 按钮开始录入',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverToBoxAdapter(
                  child: GlassCard(
                    borderRadius: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: recentItems.length,
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
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 16),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: 220,
                                      width: 160,
                                      child: item.imagePath.isNotEmpty
                                          ? Image.file(
                                              File(item.imagePath),
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              color: colorScheme.surfaceContainerHighest,
                                              child: Icon(
                                                Icons.checkroom_outlined,
                                                size: 50,
                                                color: colorScheme.onSurface.withValues(alpha: 0.3),
                                              ),
                                            ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 80,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(alpha: 0.7),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 12,
                                      right: 12,
                                      bottom: 12,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item.category,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.style,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            // 底部留白
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }
}
