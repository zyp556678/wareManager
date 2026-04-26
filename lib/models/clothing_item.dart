class ClothingItem {
  final int? id;
  final String imagePath;
  final String category; // 上衣/裤子/裙装/外套等
  final String color;
  final String material;
  final String style;
  final String season;
  final List<String> customTags;
  final String status; // active/idle
  final DateTime? idleUntil;
  final String storageLocation;
  final DateTime createdDate;

  ClothingItem({
    this.id,
    required this.imagePath,
    required this.category,
    required this.color,
    required this.material,
    required this.style,
    this.season = '',
    this.customTags = const [],
    this.status = 'active',
    this.idleUntil,
    this.storageLocation = '',
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'category': category,
      'color': color,
      'material': material,
      'style': style,
      'season': season,
      'customTags': customTags.join(','),
      'status': status,
      'idleUntil': idleUntil?.millisecondsSinceEpoch,
      'storageLocation': storageLocation,
      'createdDate': createdDate.millisecondsSinceEpoch,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      imagePath: map['imagePath'],
      category: map['category'],
      color: map['color'],
      material: map['material'],
      style: map['style'],
      season: map['season'] ?? '',
      customTags: map['customTags'] != null && map['customTags'].isNotEmpty
          ? (map['customTags'] as String).split(',')
          : [],
      status: map['status'] ?? 'active',
      idleUntil: map['idleUntil'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['idleUntil'])
          : null,
      storageLocation: map['storageLocation'] ?? '',
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate']),
    );
  }

  ClothingItem copyWith({
    int? id,
    String? imagePath,
    String? category,
    String? color,
    String? material,
    String? style,
    String? season,
    List<String>? customTags,
    String? status,
    DateTime? idleUntil,
    String? storageLocation,
    DateTime? createdDate,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
      color: color ?? this.color,
      material: material ?? this.material,
      style: style ?? this.style,
      season: season ?? this.season,
      customTags: customTags ?? this.customTags,
      status: status ?? this.status,
      idleUntil: idleUntil ?? this.idleUntil,
      storageLocation: storageLocation ?? this.storageLocation,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
