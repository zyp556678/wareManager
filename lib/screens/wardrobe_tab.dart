import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/clothing_provider.dart';
import '../models/clothing_item.dart';
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
    debugPrint('DEBUG: Showing menu for item ${item.id}: ${item.category}');
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.pause_circle_outline),
            title: const Text('设为闲置'),
            onTap: () {
              debugPrint('DEBUG: User tapped "Set as idle"');
              Navigator.pop(context);
              _setAsIdle(item);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('编辑'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditClothingPage(item: item),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('删除', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirm(context, item);
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('帮我搭配'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已为你搭配')),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setAsIdle(ClothingItem item) async {
    debugPrint('DEBUG: _setAsIdle called for item ${item.id}');
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('zh', 'CN'),
      helpText: '选择闲置开始日期',
      confirmText: '确认',
      cancelText: '取消',
    );

    debugPrint('DEBUG: Date picker result: $date');
    if (date != null && mounted) {
      await context.read<ClothingProvider>().setIdle(
            item.id!,
            date,
            '主卧衣柜',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已设为闲置'),
            action: SnackBarAction(
              label: '查看',
              onPressed: () {
                // 返回主页并切换到“我的”页面
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirm(BuildContext context, ClothingItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除衣物'),
        content: const Text('确定要删除这件衣物吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ClothingProvider>().deleteClothingItem(item.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 品类筛选栏
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
              );
            },
          ),
        ),

        // 衣物网格
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
                      Icon(
                        Icons.checkroom_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无衣物',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClothingDetailPage(item: item),
                        ),
                      );
                    },
                    onLongPress: () => _showItemMenu(context, item),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: Hero(
                              tag: 'clothing_${item.id}',
                              child: Container(
                                color: Colors.grey[200],
                                child: item.imagePath.isNotEmpty
                                    ? Image.file(
                                        File(item.imagePath),
                                        fit: BoxFit.cover,
                                      )
                                    : const Center(
                                        child: Icon(Icons.checkroom, size: 40),
                                      ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.color,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
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
