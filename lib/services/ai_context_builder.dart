import '../models/clothing_item.dart';
import '../providers/clothing_provider.dart';

class AIContextBuilder {
  final ClothingProvider _clothingProvider;

  AIContextBuilder(this._clothingProvider);

  /// 系统提示词
  String get systemPrompt => '''你是"穿戴管家"App 中的 AI 穿搭助手。你的职责是：
1. 根据用户的衣橱数据，提供穿搭建议和搭配方案
2. 分析用户的衣物风格、颜色搭配、季节适配
3. 回答关于衣物护理、收纳、闲置管理的问题
4. 帮助用户发现衣橱中的搭配可能性
5. 当用户发送图片时，你可以识别图片中的衣物，分析款式、颜色、材质，并给出搭配建议

回答要求：
- 简洁实用，避免冗长
- 如果推荐搭配，请明确指出具体的衣物（类别+颜色）
- 考虑季节、场合、颜色协调性
- 如果用户衣橱中没有合适的衣物，如实告知
- 如果用户发送了图片，请先描述你看到的衣物，再给出建议''';

  /// 构建衣物摘要上下文
  String buildClothingSummary() {
    final activeItems = _clothingProvider.activeClothing;
    final idleItems = _clothingProvider.idleClothing;

    if (activeItems.isEmpty && idleItems.isEmpty) {
      return '用户的衣橱是空的，还没有录入任何衣物。';
    }

    final categoryCount = <String, int>{};
    final seasonCount = <String, int>{};

    for (final item in activeItems) {
      categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
      if (item.season.isNotEmpty) {
        seasonCount[item.season] = (seasonCount[item.season] ?? 0) + 1;
      }
    }

    final buffer = StringBuffer();
    buffer.write('衣橱共${activeItems.length + idleItems.length}件：');
    buffer.write('在穿${activeItems.length}件');
    if (idleItems.isNotEmpty) buffer.write('，闲置${idleItems.length}件');
    buffer.write('。');

    if (categoryCount.isNotEmpty) {
      buffer.write('分类：');
      buffer.write(categoryCount.entries.map((e) => '${e.key}${e.value}件').join('、'));
      buffer.write('。');
    }

    if (seasonCount.isNotEmpty) {
      buffer.write('季节分布：');
      buffer.write(seasonCount.entries.map((e) => '${e.key}${e.value}件').join('、'));
      buffer.write('。');
    }

    return buffer.toString();
  }

  /// 构建衣物详情上下文（按需）
  String buildClothingDetail(ClothingItem item) {
    final buffer = StringBuffer();
    buffer.write('【${item.category}】');
    buffer.write('颜色：${item.color}，');
    buffer.write('材质：${item.material}，');
    buffer.write('风格：${item.style}');
    if (item.season.isNotEmpty) buffer.write('，季节：${item.season}');
    if (item.customTags.isNotEmpty) buffer.write('，标签：${item.customTags.join("、")}');
    if (item.status == 'idle') buffer.write('（闲置中）');
    return buffer.toString();
  }

  /// 构建完整对话上下文
  List<Map<String, String>> buildContext({
    List<Map<String, String>>? history,
    String? userMessage,
    ClothingItem? referencedClothing,
  }) {
    final messages = <Map<String, String>>[];

    // 系统提示 + 衣物摘要
    messages.add({
      'role': 'system',
      'content': '$systemPrompt\n\n${buildClothingSummary()}',
    });

    // 历史消息
    if (history != null) {
      messages.addAll(history);
    }

    // 用户消息（可能包含衣物引用）
    if (userMessage != null) {
      var content = userMessage;
      if (referencedClothing != null) {
        content += '\n\n[引用衣物] ${buildClothingDetail(referencedClothing)}';
      }
      messages.add({'role': 'user', 'content': content});
    }

    return messages;
  }
}
