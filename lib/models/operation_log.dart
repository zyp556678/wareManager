class OperationLog {
  final int? id;
  final String type;           // 操作类型：add/idle/wakeup/delete/edit
  final int? clothingId;
  final String? clothingName;
  final String? content;        // 操作描述
  final String? extra;         // 额外信息（如：闲置日期）
  final DateTime createdAt;

  OperationLog({
    this.id,
    required this.type,
    this.clothingId,
    this.clothingName,
    this.content,
    this.extra,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'clothing_id': clothingId,
      'clothing_name': clothingName,
      'content': content,
      'extra': extra,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory OperationLog.fromMap(Map<String, dynamic> map) {
    return OperationLog(
      id: map['id'],
      type: map['type'],
      clothingId: map['clothing_id'],
      clothingName: map['clothing_name'],
      content: map['content'],
      extra: map['extra'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  String get operationText {
    switch (type) {
      case 'add':
        return '录入';
      case 'idle':
        return '设为闲置';
      case 'wakeup':
        return '唤醒';
      case 'delete':
        return '删除';
      case 'edit':
        return '编辑';
      default:
        return '操作';
    }
  }
}