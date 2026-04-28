import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../providers/clothing_provider.dart';
import '../widgets/glass_card.dart';
import 'edit_clothing_page.dart';

class ClothingDetailPage extends StatelessWidget {
  final ClothingItem item;

  const ClothingDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'clothing_${item.id}',
                child: Container(
                  color: isDark ? cs.secondary.withValues(alpha: 0.2) : cs.secondary.withValues(alpha: 0.3),
                  child: item.imagePath.isNotEmpty
                      ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                      : const Center(child: Icon(Icons.checkroom, size: 80)),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditClothingPage(item: item)),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow('品类', item.category, cs),
                        const Divider(height: 24),
                        _buildInfoRow('颜色', item.color, cs),
                        const Divider(height: 24),
                        _buildInfoRow('材质', item.material, cs),
                        const Divider(height: 24),
                        _buildInfoRow('风格', item.style, cs),
                        const Divider(height: 24),
                        _buildInfoRow('季节', item.season.isNotEmpty ? item.season : '四季', cs),
                        const Divider(height: 24),
                        _buildInfoRow(
                          '状态',
                          item.status == 'active' ? '正常使用' : '闲置中',
                          cs,
                        ),
                        if (item.storageLocation.isNotEmpty) ...[
                          const Divider(height: 24),
                          _buildInfoRow('存放地点', item.storageLocation, cs),
                        ],
                        if (item.idleUntil != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow('闲置状态', _formatIdleDuration(item.idleUntil!), cs),
                        ],
                      ],
                    ),
                  ),
                  if (item.customTags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('个人标签', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.customTags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(tag, style: TextStyle(color: cs.primary, fontSize: 13)),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: _buildInfoRow(
                      '录入时间',
                      '${item.createdDate.year}-${item.createdDate.month.toString().padLeft(2, '0')}-${item.createdDate.day.toString().padLeft(2, '0')}',
                      cs,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: isDark ? cs.surface.withValues(alpha: 0.9) : cs.secondary.withValues(alpha: 0.7),
          border: Border(
            top: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5), width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('帮我搭配'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已为你搭配')));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(item.status == 'active' ? Icons.pause_circle : Icons.play_circle),
                label: Text(item.status == 'active' ? '设为闲置' : '唤醒'),
                onPressed: () async {
                  if (item.status == 'active') {
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
                    if (date != null && context.mounted) {
                      await context.read<ClothingProvider>().setIdle(item.id!, date, '主卧衣柜');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已设为闲置')));
                        Navigator.pop(context);
                      }
                    }
                  } else {
                    await context.read<ClothingProvider>().wakeUpIdle(item.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已唤醒')));
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 70, child: Text(label, style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.5)))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    );
  }

  String _formatIdleDuration(DateTime idleUntil) {
    final now = DateTime.now();
    final difference = idleUntil.difference(now).inDays;
    if (difference < 0) {
      final pastDays = difference.abs();
      if (pastDays < 30) return '已闲置 $pastDays 天';
      if (pastDays < 365) return '已闲置 ${pastDays ~/ 30} 个月';
      return '已闲置 ${pastDays ~/ 365} 年';
    }
    if (difference == 0) return '今天开始闲置';
    if (difference < 30) return '$difference 天后闲置结束';
    if (difference < 365) return '${difference ~/ 30} 个月后闲置结束';
    return '${difference ~/ 365} 年后闲置结束';
  }
}
