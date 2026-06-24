import 'dart:io';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/clothing_item.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(ClothingItem)? onClothingTap;

  const ChatBubble({
    super.key,
    required this.message,
    this.onClothingTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isUser ? 64 : 0,
          right: isUser ? 0 : 64,
          bottom: 8,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 图片
            if (message.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(message.imagePath!),
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 180,
                      height: 180,
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.broken_image, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
            // 文字气泡
            if (message.text != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser
                      ? cs.primary
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                ),
                child: _buildMarkdownText(
                  message.text!,
                  TextStyle(
                    color: isUser ? cs.onPrimary : cs.onSurface,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            // 衣物卡片列表
            if (message.clothingCards != null && message.clothingCards!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: message.clothingCards!.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = message.clothingCards![index];
                      return _ClothingMiniCard(
                        item: item,
                        onTap: () => onClothingTap?.call(item),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 简单解析 Markdown 格式（**加粗**、*斜体*、~~删除线~~）
  Widget _buildMarkdownText(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    // 匹配 **bold**、*italic*、~~strikethrough~~
    final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|~~(.+?)~~');
    var lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      // 匹配前的普通文本
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(1) != null) {
        // **加粗**
        spans.add(TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(2) != null) {
        // *斜体*
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(3) != null) {
        // ~~删除线~~
        spans.add(TextSpan(
          text: match.group(3),
          style: baseStyle.copyWith(decoration: TextDecoration.lineThrough),
        ));
      }

      lastEnd = match.end;
    }

    // 剩余普通文本
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    if (spans.isEmpty) {
      return Text(text, style: baseStyle);
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

class _ClothingMiniCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;

  const _ClothingMiniCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.file(
                  File(item.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: cs.surfaceContainerHigh,
                    child: Icon(Icons.checkroom, color: cs.onSurfaceVariant),
                  ),
                ),
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
}
