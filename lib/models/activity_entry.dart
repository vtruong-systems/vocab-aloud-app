enum ActivityType {
  learnWords,
  quiz,
  spellIt,
  typeIt,
}

class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.completedAt,
    required this.type,
    required this.setId,
    required this.setTitle,
    this.correctCount,
    this.totalCount,
  });

  final String id;
  final DateTime completedAt;
  final ActivityType type;
  final String setId;
  final String setTitle;
  final int? correctCount;
  final int? totalCount;

  ActivityEntry copyWith({
    String? id,
    DateTime? completedAt,
    ActivityType? type,
    String? setId,
    String? setTitle,
    int? correctCount,
    int? totalCount,
  }) {
    return ActivityEntry(
      id: id ?? this.id,
      completedAt: completedAt ?? this.completedAt,
      type: type ?? this.type,
      setId: setId ?? this.setId,
      setTitle: setTitle ?? this.setTitle,
      correctCount: correctCount ?? this.correctCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'completedAt': completedAt.toIso8601String(),
        'type': type.name,
        'setId': setId,
        'setTitle': setTitle,
        if (correctCount != null) 'correctCount': correctCount,
        if (totalCount != null) 'totalCount': totalCount,
      };

  factory ActivityEntry.fromJson(Map<String, dynamic> json) {
    return ActivityEntry(
      id: json['id'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      type: ActivityType.values.byName(json['type'] as String),
      setId: json['setId'] as String,
      setTitle: json['setTitle'] as String,
      correctCount: json['correctCount'] as int?,
      totalCount: json['totalCount'] as int?,
    );
  }
}
