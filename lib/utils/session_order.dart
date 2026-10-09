import 'dart:math';

import '../models/vocabulary_word.dart';
import '../models/word_progress.dart';
import 'progress_helpers.dart';

List<VocabularyWord> buildLearnSession(
  List<VocabularyWord> words,
  Map<String, WordProgress> progressMap,
) {
  return _orderPracticeSession(
    words,
    progressMap,
    (progress) => progress.reviewed,
  );
}

List<VocabularyWord> buildQuizSession(
  List<VocabularyWord> words,
  Map<String, WordProgress> progressMap,
) {
  return _orderPracticeSession(
    words,
    progressMap,
    (progress) => progress.quizCorrect,
  );
}

List<VocabularyWord> buildSpellingSession(
  List<VocabularyWord> words,
  Map<String, WordProgress> progressMap,
) {
  final eligible = words.where((word) => !word.isMultiWord).toList();
  return _orderPracticeSession(
    eligible,
    progressMap,
    (progress) => progress.spellingCompleted,
  );
}

List<VocabularyWord> buildTypeSession(
  List<VocabularyWord> words,
  Map<String, WordProgress> progressMap,
) {
  return _orderPracticeSession(
    words,
    progressMap,
    (progress) => progress.typedCompleted,
  );
}

/// New words first, then words last practiced on an earlier day, then words
/// already practiced today.
List<VocabularyWord> _orderPracticeSession(
  List<VocabularyWord> words,
  Map<String, WordProgress> progressMap,
  bool Function(WordProgress progress) isDone, {
  DateTime? now,
}) {
  final fresh = <VocabularyWord>[];
  final due = <VocabularyWord>[];
  final doneToday = <VocabularyWord>[];
  for (final word in words) {
    final progress = getWordProgress(progressMap, word.id);
    if (!isDone(progress)) {
      fresh.add(word);
    } else if (!practicedToday(progress.lastPracticedAt, now)) {
      due.add(word);
    } else {
      doneToday.add(word);
    }
  }
  return [..._shuffled(fresh), ..._shuffled(due), ..._shuffled(doneToday)];
}

bool practicedToday(DateTime? practicedAt, [DateTime? now]) {
  if (practicedAt == null) return false;
  final local = practicedAt.toLocal();
  final clock = (now ?? DateTime.now()).toLocal();
  return local.year == clock.year &&
      local.month == clock.month &&
      local.day == clock.day;
}

void requeueMissedWord(
  List<VocabularyWord> session,
  int currentIndex,
  VocabularyWord word,
) {
  final alreadyQueued = session
      .skip(currentIndex + 1)
      .any((item) => item.id == word.id);
  if (alreadyQueued) return;

  final insertAt = min(currentIndex + 3, session.length);
  session.insert(insertAt, word);
}

List<VocabularyWord> _shuffled(List<VocabularyWord> words) {
  final copy = List<VocabularyWord>.from(words);
  copy.shuffle(Random());
  return copy;
}

List<VocabularyWord> buildQuizChoices({
  required VocabularyWord correct,
  required List<VocabularyWord> allWords,
  int maxChoices = 4,
  Random? random,
}) {
  final rng = random ?? Random();
  final others = allWords.where((word) => word.id != correct.id).toList();
  final sameDifficulty =
      others.where((word) => word.difficulty == correct.difficulty).toList()
        ..shuffle(rng);
  final otherDifficulty =
      others.where((word) => word.difficulty != correct.difficulty).toList()
        ..shuffle(rng);

  final choiceCount = min(maxChoices, allWords.length);
  if (choiceCount < 2) return [correct];

  final distractors = [
    ...sameDifficulty,
    ...otherDifficulty,
  ].take(choiceCount - 1);
  final choices = [correct, ...distractors];
  choices.shuffle(rng);
  return choices;
}
