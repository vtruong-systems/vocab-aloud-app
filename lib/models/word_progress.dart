class WordProgress {
  const WordProgress({
    required this.wordId,
    this.reviewed = false,
    this.quizCorrect = false,
    this.spellingCompleted = false,
    this.typedCompleted = false,
    this.quizAttempts = 0,
    this.quizCorrectCount = 0,
    this.spellingAttempts = 0,
    this.typedAttempts = 0,
    this.lastPracticedAt,
  });

  final String wordId;
  final bool reviewed;
  final bool quizCorrect;
  final bool spellingCompleted;
  final bool typedCompleted;
  final int quizAttempts;
  final int quizCorrectCount;
  final int spellingAttempts;
  final int typedAttempts;
  final DateTime? lastPracticedAt;

  WordProgress copyWith({
    bool? reviewed,
    bool? quizCorrect,
    bool? spellingCompleted,
    bool? typedCompleted,
    int? quizAttempts,
    int? quizCorrectCount,
    int? spellingAttempts,
    int? typedAttempts,
    DateTime? lastPracticedAt,
  }) {
    return WordProgress(
      wordId: wordId,
      reviewed: reviewed ?? this.reviewed,
      quizCorrect: quizCorrect ?? this.quizCorrect,
      spellingCompleted: spellingCompleted ?? this.spellingCompleted,
      typedCompleted: typedCompleted ?? this.typedCompleted,
      quizAttempts: quizAttempts ?? this.quizAttempts,
      quizCorrectCount: quizCorrectCount ?? this.quizCorrectCount,
      spellingAttempts: spellingAttempts ?? this.spellingAttempts,
      typedAttempts: typedAttempts ?? this.typedAttempts,
      lastPracticedAt: lastPracticedAt ?? this.lastPracticedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'reviewed': reviewed,
        'quizCorrect': quizCorrect,
        'spellingCompleted': spellingCompleted,
        'typedCompleted': typedCompleted,
        'quizAttempts': quizAttempts,
        'quizCorrectCount': quizCorrectCount,
        'spellingAttempts': spellingAttempts,
        'typedAttempts': typedAttempts,
        'lastPracticedAt': lastPracticedAt?.toIso8601String(),
      };

  factory WordProgress.fromJson(Map<String, dynamic> json) {
    return WordProgress(
      wordId: json['wordId'] as String? ?? '',
      reviewed: json['reviewed'] as bool? ?? false,
      quizCorrect: json['quizCorrect'] as bool? ?? false,
      spellingCompleted: json['spellingCompleted'] as bool? ?? false,
      typedCompleted: json['typedCompleted'] as bool? ?? false,
      quizAttempts: json['quizAttempts'] as int? ?? 0,
      quizCorrectCount: json['quizCorrectCount'] as int? ?? 0,
      spellingAttempts: json['spellingAttempts'] as int? ?? 0,
      typedAttempts: json['typedAttempts'] as int? ?? 0,
      lastPracticedAt: json['lastPracticedAt'] != null
          ? DateTime.parse(json['lastPracticedAt'] as String)
          : null,
    );
  }

  static WordProgress empty(String wordId) => WordProgress(wordId: wordId);
}
