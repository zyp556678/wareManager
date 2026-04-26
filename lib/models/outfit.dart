class Outfit {
  final int? id;
  final List<int> clothingIds;
  final String styleTag;
  final DateTime createdDate;
  final int timesWorn;

  Outfit({
    this.id,
    required this.clothingIds,
    required this.styleTag,
    required this.createdDate,
    this.timesWorn = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clothingIds': clothingIds.join(','),
      'styleTag': styleTag,
      'createdDate': createdDate.millisecondsSinceEpoch,
      'timesWorn': timesWorn,
    };
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'],
      clothingIds: map['clothingIds'] != null && map['clothingIds'].isNotEmpty
          ? (map['clothingIds'] as String).split(',').map(int.parse).toList()
          : [],
      styleTag: map['styleTag'],
      createdDate: DateTime.fromMillisecondsSinceEpoch(map['createdDate']),
      timesWorn: map['timesWorn'] ?? 0,
    );
  }
}
