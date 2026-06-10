import 'dart:math';

import '../models/vocabulary_word.dart';
import '../models/word_progress.dart';
import 'progress_helpers.dart';

List<VocabularyWord> buildLearnSession(
  List<VocabularyWord> words,
  Map<String, WordProgress> progressMap,
) {
  final incomplete = words
      .where((word) => !getWordProgress(progressMap, word.id).reviewed)
      .toList();
  final complete = words
      .where((word) => getWordProgress(progressMap, word.id).reviewed)
      .toList();
  return [..._shuffled(incomplete), ..._shuffled(complete)];
}

List<VocabularyWord> buildQuizSession(
  List<VocabularyWord> words,
  Map<String, WordProgress> progressMap,
) {
  final incomplete = words
      .where((word) => !getWordProgress(progressMap, word.id).quizCorrect)
      .toList();
  final complete = words
      .where((word) => getWordProgress(progressMap, word.id).quizCorrect)
      .toList();
  return [..._shuffled(incomplete), ..._shuffled(complete)];
}

List<VocabularyWord> buildSpellingSession(
  List<VocabularyWord> words,
  Map<String, WordProgress> progressMap,
) {
  final eligible = words.where((word) => !word.isMultiWord).toList();
  final incomplete = eligible
      .where(
        (word) => !getWordProgress(progressMap, word.id).spellingCompleted,
      )
      .toList();
  final complete = eligible
      .where(
        (word) => getWordProgress(progressMap, word.id).spellingCompleted,
      )
      .toList();
  return [..._shuffled(incomplete), ..._shuffled(complete)];
}

List<VocabularyWord> buildTypeSession(
  List<VocabularyWord> words,
  Map<String, WordProgress> progressMap,
) {
  final incomplete = words
      .where((word) => !getWordProgress(progressMap, word.id).typedCompleted)
      .toList();
  final complete = words
      .where((word) => getWordProgress(progressMap, word.id).typedCompleted)
      .toList();
  return [..._shuffled(incomplete), ..._shuffled(complete)];
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
}) {
  final distractors = allWords
      .where((word) => word.id != correct.id)
      .toList()
    ..shuffle(Random());

  final choiceCount = min(maxChoices, allWords.length);
  final choices = [correct, ...distractors.take(choiceCount - 1)];
  choices.shuffle(Random());
  return choices;
}
