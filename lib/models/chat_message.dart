import 'clothing_item.dart';

class ChatMessage {
  final String id;
  final String role; // 'user' / 'assistant'
  final String? text;
  final String? imagePath;
  final List<ClothingItem>? clothingCards;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    this.text,
    this.imagePath,
    this.clothingCards,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'text': text,
      'imagePath': imagePath,
      'clothingIds': clothingCards?.map((c) => c.id.toString()).join(','),
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, {List<ClothingItem>? clothingCards}) {
    return ChatMessage(
      id: map['id'],
      role: map['role'],
      text: map['text'],
      imagePath: map['imagePath'],
      clothingCards: clothingCards,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdDate;
  final DateTime lastMessageDate;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdDate,
    required this.lastMessageDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'lastMessageDate': lastMessageDate.millisecondsSinceEpoch,
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'],
      title: map['title'],
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate']),
      lastMessageDate: DateTime.fromMillisecondsSinceEpoch(map['lastMessageDate']),
    );
  }
}
