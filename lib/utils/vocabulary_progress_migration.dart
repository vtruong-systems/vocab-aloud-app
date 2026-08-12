import '../models/app_state.dart';
import '../models/profile_progress.dart';
import '../models/word_progress.dart';

class VocabularyProgressMigrationResult {
  const VocabularyProgressMigrationResult({
    required this.state,
    required this.changed,
  });

  final AppState state;
  final bool changed;
}

VocabularyProgressMigrationResult migrateVocabularyProgress(AppState state) {
  var changed = false;
  final migratedProfiles = <String, ProfileProgress>{};

  for (final entry in state.profileProgress.entries) {
    final result = _migrateProfileProgress(entry.value);
    migratedProfiles[entry.key] = result.progress;
    changed = changed || result.changed;
  }

  return VocabularyProgressMigrationResult(
    state: changed ? state.copyWith(profileProgress: migratedProfiles) : state,
    changed: changed,
  );
}

({ProfileProgress progress, bool changed}) _migrateProfileProgress(
  ProfileProgress progress,
) {
  var changed = false;

  final selectedSetId = _migrateSetId(progress.selectedSetId);
  changed = changed || selectedSetId != progress.selectedSetId;

  final migratedModes = <String, String>{};
  for (final entry in progress.lastModeBySet.entries) {
    final migratedId = _migrateSetId(entry.key)!;
    if (migratedId != entry.key) changed = true;
    migratedModes[migratedId] = entry.value;
  }

  final migratedSets = <String, SetProgress>{};
  final orderedSetEntries = [
    ...progress.sets.entries.where(
      (entry) => _migrateSetId(entry.key) != entry.key,
    ),
    ...progress.sets.entries.where(
      (entry) => _migrateSetId(entry.key) == entry.key,
    ),
  ];
  for (final entry in orderedSetEntries) {
    final migratedSetId = _migrateSetId(entry.key)!;
    if (migratedSetId != entry.key) changed = true;

    final migratedWords = <String, WordProgress>{
      ...?migratedSets[migratedSetId]?.wordProgress,
    };
    for (final wordEntry in entry.value.wordProgress.entries) {
      final migratedWordId = _migrateWordId(
        wordEntry.key,
        oldSetId: entry.key,
        newSetId: migratedSetId,
      );
      if (migratedWordId != wordEntry.key ||
          wordEntry.value.wordId != migratedWordId) {
        changed = true;
      }
      migratedWords[migratedWordId] = _copyWordProgressWithId(
        wordEntry.value,
        migratedWordId,
      );
    }
    migratedSets[migratedSetId] = SetProgress(wordProgress: migratedWords);
  }

  final migratedActivity = progress.activityLog.map((activity) {
    final migratedSetId = _migrateSetId(activity.setId)!;
    final migratedTitle = _migrateSetTitle(activity.setTitle);
    if (migratedSetId != activity.setId || migratedTitle != activity.setTitle) {
      changed = true;
      return activity.copyWith(setId: migratedSetId, setTitle: migratedTitle);
    }
    return activity;
  }).toList();

  if (!changed) return (progress: progress, changed: false);
  return (
    progress: ProfileProgress(
      selectedSetId: selectedSetId,
      lastModeBySet: migratedModes,
      sets: migratedSets,
      activityLog: migratedActivity,
    ),
    changed: true,
  );
}

String? _migrateSetId(String? setId) {
  if (setId == null) return null;
  if (setId.startsWith('vocab-set-')) return 'truong-$setId';
  return switch (setId) {
    'science-lab-basics' => 'truong-science-lab-basics',
    'school-words' => 'truong-school-words',
    _ => setId,
  };
}

String _migrateWordId(
  String wordId, {
  required String oldSetId,
  required String newSetId,
}) {
  if (oldSetId == newSetId || !wordId.startsWith('$oldSetId-')) {
    return wordId;
  }
  return '$newSetId-${wordId.substring(oldSetId.length + 1)}';
}

String _migrateSetTitle(String title) {
  if (title.startsWith('Vocabulary Set ')) return 'Truong $title';
  return switch (title) {
    'Science Lab Basics' => 'Truong Science Lab Basics',
    'School Words' => 'Truong School Words',
    _ => title,
  };
}

WordProgress _copyWordProgressWithId(WordProgress progress, String wordId) {
  if (progress.wordId == wordId) return progress;
  return WordProgress(
    wordId: wordId,
    reviewed: progress.reviewed,
    quizCorrect: progress.quizCorrect,
    spellingCompleted: progress.spellingCompleted,
    typedCompleted: progress.typedCompleted,
    quizAttempts: progress.quizAttempts,
    quizCorrectCount: progress.quizCorrectCount,
    spellingAttempts: progress.spellingAttempts,
    typedAttempts: progress.typedAttempts,
    lastPracticedAt: progress.lastPracticedAt,
  );
}
