import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/clothing_provider.dart';
import '../models/clothing_item.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../utils/idle_utils.dart';
import 'clothing_detail_page.dart';
import 'edit_clothing_page.dart';

class WardrobeTab extends StatefulWidget {
  const WardrobeTab({super.key});

  @override
  State<WardrobeTab> createState() => _WardrobeTabState();
}

class _WardrobeTabState extends State<WardrobeTab> {
  String _selectedCategory = '全部';
  final List<String> _categories = ['全部', '上衣', '裤子', '裙装', '外套', '鞋子', '配饰'];

  void _showItemMenu(BuildContext context, ClothingItem item) {
    final pageContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => GlassCard(
        margin: const EdgeInsets.all(16),
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.pause_circle_outline, color: Theme.of(pageContext).colorScheme.primary),
              title: const Text('设为闲置'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _setAsIdle(item);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: Theme.of(pageContext).colorScheme.primary),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                Navigator.push(
                  pageContext,
                  MaterialPageRoute(builder: (_) => EditClothingPage(item: item)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showDeleteConfirm(pageContext, item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setAsIdle(ClothingItem item) async {
    // 第 1 步：选择闲置开始日期（默认今天）
    final idleFrom = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('zh', 'CN'),
      helpText: '选择闲置开始日期',
      confirmText: '确认',
      cancelText: '取消',
    );
    if (idleFrom == null || !mounted) return;

    // 第 2 步：选择闲置结束日期（默认开始日期后 30 天，必须晚于开始日期）
    final idleUntil = await showDatePicker(
      context: context,
      initialDate: idleFrom.add(const Duration(days: 30)),
      firstDate: idleFrom.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      locale: const Locale('zh', 'CN'),
      helpText: '选择闲置结束日期',
      confirmText: '确认',
      cancelText: '取消',
    );
    if (idleUntil == null || !mounted) return;

    // 第 3 步：选择存放地点
    final location = await showLocationPicker(context);
    if (location == null || !mounted) return;

    // 调用 provider 保存
    await context.read<ClothingProvider>().setIdle(
          item.id!,
          idleFrom,
          idleUntil,
          location,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已设为闲置')),
      );
    }
  }

  Future<void> _showDeleteConfirm(BuildContext context, ClothingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除衣物'),
        content: const Text('确定要删除这件衣物吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ClothingProvider>().deleteClothingItem(item.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已删除')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.separated(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return GlassButton(
                isSelected: isSelected,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                onTap: () => setState(() => _selectedCategory = category),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Consumer<ClothingProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = _selectedCategory == '全部'
                  ? provider.activeClothing
                  : provider.getByCategory(_selectedCategory);

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.checkroom_outlined, size: 56, color: cs.primary.withValues(alpha: 0.6)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无衣物',
                        style: TextStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                );
              }

              return MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ClothingDetailPage(item: item)),
                      );
                    },
                    onLongPress: () => _showItemMenu(context, item),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: item.imagePath.isNotEmpty ? 0.8 : 1,
                            child: Container(
                              color: isDark ? cs.secondary.withValues(alpha: 0.2) : cs.secondary.withValues(alpha: 0.4),
                              child: item.imagePath.isNotEmpty
                                  ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                                  : Icon(Icons.checkroom_outlined, size: 48, color: cs.onSurface.withValues(alpha: 0.2)),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                                ),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.color,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.75),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
