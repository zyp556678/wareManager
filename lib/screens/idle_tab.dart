import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clothing_provider.dart';
import '../models/clothing_item.dart';
import 'clothing_detail_page.dart';
import 'edit_clothing_page.dart';

class IdleTab extends StatefulWidget {
  const IdleTab({super.key});

  @override
  State<IdleTab> createState() => _IdleTabState();
}

class _IdleTabState extends State<IdleTab> {
  Future<void> _wakeUpIdle(BuildContext context, ClothingItem item) async {
    await context.read<ClothingProvider>().wakeUpIdle(item.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已唤醒衣物')),
      );
    }
  }

  void _showIdleItemMenu(BuildContext context, ClothingItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined),
            title: const Text('唤醒'),
            onTap: () {
              Navigator.pop(context);
              _wakeUpIdle(context, item);
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
        ],
      ),
    );
  }

  String _formatIdleDuration(DateTime idleUntil) {
    final now = DateTime.now();
    final difference = idleUntil.difference(now).inDays;

    if (difference < 0) {
      final pastDays = difference.abs();
      if (pastDays == 1) {
        return '已闲置 1 天';
      } else if (pastDays < 30) {
        return '已闲置 $pastDays 天';
      } else if (pastDays < 365) {
        final months = (pastDays / 30).floor();
        return '已闲置 $months 个月';
      } else {
        final years = (pastDays / 365).floor();
        return '已闲置 $years 年';
      }
    } else if (difference == 0) {
      return '今天开始闲置';
    } else if (difference == 1) {
      return '明天闲置结束';
    } else if (difference < 30) {
      return '$difference 天后闲置结束';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '$months 个月后闲置结束';
    } else {
      final years = (difference / 365).floor();
      return '$years 年后闲置结束';
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
    return Consumer<ClothingProvider>(
      builder: (context, provider, child) {
        final idleItems = provider.idleClothing;

        if (idleItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.archive_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无闲置衣物',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: idleItems.length,
          itemBuilder: (context, index) {
            final item = idleItems[index];
            return Dismissible(
              key: Key(item.id.toString()),
              direction: DismissDirection.startToEnd,
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: Colors.green,
                child: const Icon(
                  Icons.wb_sunny,
                  color: Colors.white,
                ),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('唤醒衣物'),
                    content: const Text('确定要唤醒这件衣物吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('确认'),
                      ),
                    ],
                  ),
                );
              },
              onDismissed: (direction) {
                _wakeUpIdle(context, item);
              },
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClothingDetailPage(item: item),
                    ),
                  );
                },
                onLongPress: () => _showIdleItemMenu(context, item),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.category} · ${item.color}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatIdleDuration(item.idleUntil!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '存放于 ${item.storageLocation}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 半透明遮罩
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
            );
          },
        );
      },
    );
  }
}
