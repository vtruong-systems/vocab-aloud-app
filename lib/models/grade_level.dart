enum GradeLevel {
  preK,
  k,
  g1,
  g2,
  g3,
  g4,
  g5;

  static const GradeLevel defaultAll = GradeLevel.g5;

  int get order => index;

  /// Display level shown in the app: Pre-K = 1, K = 2, 1st grade = 3, etc.
  int get displayLevel => order + 1;

  String get label => 'Level $displayLevel';

  String get shortLabel => displayLevel.toString();

  static GradeLevel? fromCsv(String value) {
    switch (value.trim()) {
      case 'Pre-K':
        return GradeLevel.preK;
      case 'K':
        return GradeLevel.k;
      case '1':
        return GradeLevel.g1;
      case '2':
        return GradeLevel.g2;
      case '3':
        return GradeLevel.g3;
      case '4':
        return GradeLevel.g4;
      case '5':
        return GradeLevel.g5;
      default:
        return null;
    }
  }

  static GradeLevel? fromJson(String? value) {
    if (value == null) return null;
    return GradeLevel.values.firstWhere(
      (level) => level.name == value,
      orElse: () => GradeLevel.g5,
    );
  }

  String toJson() => name;

  static GradeLevel effectiveMax(GradeLevel? maxLevel) =>
      maxLevel ?? GradeLevel.defaultAll;
}
