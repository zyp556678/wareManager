import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../providers/clothing_provider.dart';
import '../widgets/glass_card.dart';
import '../utils/idle_utils.dart';
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
                        if (item.idleFrom != null && item.idleUntil != null) ...[
                          const Divider(height: 24),
                          _buildInfoRow('闲置状态', '${_formatDate(item.idleFrom!)} 至 ${_formatDate(item.idleUntil!)}', cs),
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
                    if (idleFrom == null || !context.mounted) return;

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
                    if (idleUntil == null || !context.mounted) return;

                    // 第 3 步：选择存放地点
                    final location = await showLocationPicker(context);
                    if (location == null || !context.mounted) return;

                    // 调用 provider 保存
                    await context.read<ClothingProvider>().setIdle(
                          item.id!,
                          idleFrom,
                          idleUntil,
                          location,
                        );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已设为闲置')),
                      );
                      Navigator.pop(context);
                    }
                  } else {
                    await context.read<ClothingProvider>().wakeUpIdle(item.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已唤醒')),
                      );
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
