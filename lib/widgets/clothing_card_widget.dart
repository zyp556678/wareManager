import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../screens/clothing_detail_page.dart';

/// AI 回复中的衣物卡片组件
class ClothingCardWidget extends StatelessWidget {
  final ClothingItem item;
  final bool compact;

  const ClothingCardWidget({
    super.key,
    required this.item,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (compact) {
      return _buildCompactCard(context, cs);
    }
    return _buildFullCard(context, cs);
  }

  Widget _buildCompactCard(BuildContext context, ColorScheme cs) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildImage(90),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                '${item.category}\n${item.color}',
                style: TextStyle(fontSize: 10, color: cs.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context, ColorScheme cs) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(width: 56, height: 56, child: _buildImage(56)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.category} · ${item.color}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.material} · ${item.style}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  if (item.season.isNotEmpty)
                    Text(
                      item.season,
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            if (item.status == 'idle')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('闲置', style: TextStyle(fontSize: 10, color: cs.error)),
              ),
            Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(double size) {
    return Image.file(
      File(item.imagePath),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.checkroom),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ClothingDetailPage(item: item)),
    );
  }
}

/// 横向衣物卡片列表
class ClothingCardList extends StatelessWidget {
  final List<ClothingItem> items;

  const ClothingCardList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ClothingCardWidget(item: items[index], compact: true);
        },
      ),
    );
  }
}
