import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/clothing_provider.dart';
import '../models/clothing_item.dart';
import '../widgets/glass_card.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已唤醒衣物')));
    }
  }

  void _showIdleItemMenu(BuildContext context, ClothingItem item) {
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
              leading: Icon(Icons.wb_sunny_outlined, color: Theme.of(pageContext).colorScheme.primary),
              title: const Text('唤醒'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _wakeUpIdle(pageContext, item);
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

  String _formatIdleDuration(DateTime idleUntil) {
    final now = DateTime.now();
    final difference = idleUntil.difference(now).inDays;

    if (difference < 0) {
      final pastDays = difference.abs();
      if (pastDays < 30) return '已闲置 $pastDays 天';
      if (pastDays < 365) return '已闲置 ${(pastDays ~/ 30)} 个月';
      return '已闲置 ${(pastDays ~/ 365)} 年';
    }
    if (difference == 0) return '今天开始闲置';
    if (difference < 30) return '$difference 天后闲置结束';
    if (difference < 365) return '${difference ~/ 30} 个月后闲置结束';
    return '${difference ~/ 365} 年后闲置结束';
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

    return Consumer<ClothingProvider>(
      builder: (context, provider, child) {
        final idleItems = provider.idleClothing;

        if (idleItems.isEmpty) {
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
                  child: Icon(Icons.archive_outlined, size: 56, color: cs.primary.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无闲置衣物',
                  style: TextStyle(fontSize: 16, color: cs.onSurface.withValues(alpha: 0.6)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          itemCount: idleItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = idleItems[index];
            return Dismissible(
              key: Key(item.id.toString()),
              direction: DismissDirection.startToEnd,
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.wb_sunny, color: Colors.white, size: 28),
              ),
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('唤醒衣物'),
                    content: const Text('确定要唤醒这件衣物吗？'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('确认')),
                    ],
                  ),
                );
              },
              onDismissed: (direction) => _wakeUpIdle(context, item),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ClothingDetailPage(item: item)),
                  );
                },
                onLongPress: () => _showIdleItemMenu(context, item),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: item.imagePath.isNotEmpty
                              ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                              : Container(
                                  color: isDark ? cs.secondary.withValues(alpha: 0.2) : cs.secondary.withValues(alpha: 0.4),
                                  child: Icon(Icons.checkroom_outlined, size: 36, color: cs.onSurface.withValues(alpha: 0.25)),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.category} · ${item.color}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _formatIdleDuration(item.idleUntil!),
                                style: TextStyle(fontSize: 11, color: cs.error),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '存放于 ${item.storageLocation}',
                              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
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
        );
      },
    );
  }
}
