class Location {
  final int? id;
  final String name;
  final String type; // home, office, gym, travel, other
  final String? description;
  final String? address;
  final DateTime createdAt;

  Location({
    this.id,
    required this.name,
    required this.type,
    this.description,
    this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'address': address,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      description: map['description'],
      address: map['address'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Location copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    String? address,
    DateTime? createdAt,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get typeLabel {
    switch (type) {
      case 'home':
        return '家';
      case 'office':
        return '办公室';
      case 'gym':
        return '健身房';
      case 'travel':
        return '旅行';
      case 'other':
        return '其他';
      default:
        return type;
    }
  }
}
