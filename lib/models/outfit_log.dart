class OutfitLog {
  final int? id;
  final int outfitId;
  final DateTime date;
  final String weather;
  final String occasion;

  OutfitLog({
    this.id,
    required this.outfitId,
    required this.date,
    required this.weather,
    required this.occasion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'outfitId': outfitId,
      'date': date.millisecondsSinceEpoch,
      'weather': weather,
      'occasion': occasion,
    };
  }

  factory OutfitLog.fromMap(Map<String, dynamic> map) {
    return OutfitLog(
      id: map['id'],
      outfitId: map['outfitId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      weather: map['weather'],
      occasion: map['occasion'],
    );
  }
}
