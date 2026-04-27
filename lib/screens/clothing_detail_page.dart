import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../providers/clothing_provider.dart';
import 'edit_clothing_page.dart';

class ClothingDetailPage extends StatelessWidget {
  final ClothingItem item;

  const ClothingDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('衣物详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditClothingPage(item: item),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 衣物图片
            Hero(
              tag: 'clothing_${item.id}',
              child: Container(
                height: 400,
                width: double.infinity,
                color: Colors.grey[200],
                child: item.imagePath.isNotEmpty
                    ? Image.file(
                        File(item.imagePath),
                        fit: BoxFit.cover,
                      )
                    : const Center(
                        child: Icon(Icons.checkroom, size: 80, color: Colors.grey),
                      ),
              ),
            ),

            // 衣物信息
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 品类
                  _buildInfoRow('品类', item.category),
                  const SizedBox(height: 12),

                  // 颜色
                  _buildInfoRow('颜色', item.color),
                  const SizedBox(height: 12),

                  // 材质
                  _buildInfoRow('材质', item.material),
                  const SizedBox(height: 12),

                  // 风格
                  _buildInfoRow('风格', item.style),
                  const SizedBox(height: 12),

                  // 季节
                  if (item.season.isNotEmpty) ...[
                    _buildInfoRow('季节', item.season),
                    const SizedBox(height: 12),
                  ],

                  // 状态
                  _buildInfoRow(
                    '状态',
                    item.status == 'active' ? '正常使用' : '闲置中',
                  ),
                  const SizedBox(height: 12),

                  // 存放地点
                  if (item.storageLocation.isNotEmpty) ...[
                    _buildInfoRow('存放地点', item.storageLocation),
                    const SizedBox(height: 12),
                  ],

                  // 闲置日期
                  if (item.idleUntil != null) ...[
                    _buildInfoRow(
                      '闲置状态',
                      _formatIdleDuration(item.idleUntil!),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 个人标签
                  if (item.customTags.isNotEmpty) ...[
                    const Text(
                      '个人标签',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: item.customTags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 创建时间
                  _buildInfoRow(
                    '录入时间',
                    '${item.createdDate.year}-${item.createdDate.month.toString().padLeft(2, '0')}-${item.createdDate.day.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 底部操作按钮
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('帮我搭配'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已为你搭配')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(
                  item.status == 'active' ? Icons.pause_circle : Icons.play_circle,
                ),
                label: Text(item.status == 'active' ? '设为闲置' : '唤醒'),
                onPressed: () async {
                  if (item.status == 'active') {
                    // 设为闲置
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
                      await context.read<ClothingProvider>().setIdle(
                            item.id!,
                            date,
                            '主卧衣柜',
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已设为闲置')),
                        );
                        Navigator.pop(context);
                      }
                    }
                  } else {
                    // 唤醒
                    await context.read<ClothingProvider>().wakeUpIdle(item.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已唤醒')),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
}
