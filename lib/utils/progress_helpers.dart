import '../models/vocabulary_set.dart';
import '../models/vocabulary_word.dart';
import '../models/word_progress.dart';

class SetStats {
  const SetStats({
    required this.totalWords,
    required this.reviewedCount,
    required this.quizCount,
    required this.spellingCount,
    required this.typedCount,
    required this.masteredCount,
    required this.completedSteps,
    required this.totalSteps,
    required this.quizAttempts,
    required this.quizCorrectCount,
  });

  final int totalWords;
  final int reviewedCount;
  final int quizCount;
  final int spellingCount;
  final int typedCount;
  final int masteredCount;
  final int completedSteps;
  final int totalSteps;
  final int quizAttempts;
  final int quizCorrectCount;

  double get completionPercent =>
      totalSteps == 0 ? 0 : completedSteps / totalSteps;

  int? get quizAccuracyPercent {
    if (quizAttempts == 0) return null;
    return ((quizCorrectCount / quizAttempts) * 100).round();
  }

  String get statusLabel {
    if (completedSteps == 0) return 'Not Started';
    if (completedSteps >= totalSteps) return 'Complete';
    return 'In Progress';
  }
}

int totalStepsForWord(VocabularyWord word) => word.isMultiWord ? 3 : 4;

int completedStepsForWord(WordProgress progress, VocabularyWord word) {
  var completed = 0;
  if (progress.reviewed) completed++;
  if (progress.quizCorrect) completed++;
  if (progress.typedCompleted) completed++;
  if (!word.isMultiWord && progress.spellingCompleted) completed++;
  return completed;
}

bool isWordComplete(
  WordProgress progress, {
  required bool requireTyped,
}) {
  return progress.reviewed &&
      progress.quizCorrect &&
      progress.spellingCompleted &&
      (!requireTyped || progress.typedCompleted);
}

bool isWordPartiallyComplete(WordProgress progress) {
  return progress.reviewed ||
      progress.quizCorrect ||
      progress.spellingCompleted ||
      progress.typedCompleted;
}

WordProgress getWordProgress(
  Map<String, WordProgress> progressMap,
  String wordId,
) {
  return progressMap[wordId] ?? WordProgress.empty(wordId);
}

SetStats computeSetStats(
  VocabularySet set,
  Map<String, WordProgress> progressMap, {
  required bool requireTyped,
}) {
  var reviewed = 0;
  var quiz = 0;
  var spelling = 0;
  var typed = 0;
  var mastered = 0;
  var completedSteps = 0;
  var totalSteps = 0;
  var quizAttempts = 0;
  var quizCorrectCount = 0;

  for (final word in set.words) {
    final progress = getWordProgress(progressMap, word.id);
    totalSteps += totalStepsForWord(word);
    completedSteps += completedStepsForWord(progress, word);
    if (progress.reviewed) reviewed++;
    if (progress.quizCorrect) quiz++;
    if (progress.spellingCompleted) spelling++;
    if (progress.typedCompleted) typed++;
    if (isWordComplete(progress, requireTyped: requireTyped)) mastered++;
    quizAttempts += progress.quizAttempts;
    quizCorrectCount += progress.quizCorrectCount;
  }

  return SetStats(
    totalWords: set.words.length,
    reviewedCount: reviewed,
    quizCount: quiz,
    spellingCount: spelling,
    typedCount: typed,
    masteredCount: mastered,
    completedSteps: completedSteps,
    totalSteps: totalSteps,
    quizAttempts: quizAttempts,
    quizCorrectCount: quizCorrectCount,
  );
}

int countSetsInProgress(
  List<VocabularySet> sets,
  Map<String, Map<String, WordProgress>> allSetProgress, {
  required bool requireTyped,
}) {
  var count = 0;
  for (final set in sets) {
    final stats = computeSetStats(
      set,
      allSetProgress[set.id] ?? {},
      requireTyped: requireTyped,
    );
    if (stats.completedSteps > 0 && stats.completedSteps < stats.totalSteps) {
      count++;
    }
  }
  return count;
}

List<VocabularyWord> incompleteWords(
  VocabularySet set,
  Map<String, WordProgress> progressMap,
  bool Function(WordProgress progress) isComplete,
) {
  return set.words
      .where((word) => !isComplete(getWordProgress(progressMap, word.id)))
      .toList();
}
