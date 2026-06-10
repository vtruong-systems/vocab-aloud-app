import 'word_progress.dart';

class SetProgress {
  const SetProgress({
    this.wordProgress = const {},
  });

  final Map<String, WordProgress> wordProgress;

  SetProgress copyWith({
    Map<String, WordProgress>? wordProgress,
  }) {
    return SetProgress(
      wordProgress: wordProgress ?? this.wordProgress,
    );
  }

  Map<String, dynamic> toJson() => {
        'wordProgress': wordProgress.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };

  factory SetProgress.fromJson(Map<String, dynamic> json) {
    final raw = json['wordProgress'] as Map<String, dynamic>? ?? {};
    return SetProgress(
      wordProgress: raw.map(
        (key, value) => MapEntry(
          key,
          WordProgress.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class ProfileProgress {
  const ProfileProgress({
    this.selectedSetId,
    this.lastModeBySet = const {},
    this.sets = const {},
  });

  final String? selectedSetId;
  final Map<String, String> lastModeBySet;
  final Map<String, SetProgress> sets;

  ProfileProgress copyWith({
    String? selectedSetId,
    bool clearSelectedSetId = false,
    Map<String, String>? lastModeBySet,
    Map<String, SetProgress>? sets,
  }) {
    return ProfileProgress(
      selectedSetId:
          clearSelectedSetId ? null : (selectedSetId ?? this.selectedSetId),
      lastModeBySet: lastModeBySet ?? this.lastModeBySet,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toJson() => {
        'selectedSetId': selectedSetId,
        'lastModeBySet': lastModeBySet,
        'sets': sets.map((key, value) => MapEntry(key, value.toJson())),
      };

  factory ProfileProgress.fromJson(Map<String, dynamic> json) {
    final rawSets = json['sets'] as Map<String, dynamic>? ?? {};
    return ProfileProgress(
      selectedSetId: json['selectedSetId'] as String?,
      lastModeBySet: (json['lastModeBySet'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as String)) ??
          {},
      sets: rawSets.map(
        (key, value) => MapEntry(
          key,
          SetProgress.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }
}
