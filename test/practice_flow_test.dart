import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/models/grade_level.dart';
import 'package:vocab_aloud_app/models/vocabulary_set.dart';
import 'package:vocab_aloud_app/models/vocabulary_word.dart';
import 'package:vocab_aloud_app/models/word_difficulty.dart';
import 'package:vocab_aloud_app/models/word_progress.dart';
import 'package:vocab_aloud_app/utils/learner_words.dart';
import 'package:vocab_aloud_app/utils/session_order.dart';

VocabularyWord _word({
  required String id,
  required String text,
  required GradeLevel grade,
  WordDifficulty difficulty = WordDifficulty.easy,
}) {
  return VocabularyWord(
    id: id,
    word: text,
    definition: 'meaning of $text',
    exampleSentence: 'We use $text.',
    partOfSpeech: '',
    difficulty: difficulty,
    gradeLevel: grade,
  );
}

void main() {
  test('mixed lists keep only words at or below the child grade', () {
    final set = VocabularySet(
      id: 'house',
      title: 'House',
      description: 'House',
      gradeLabel: 'K–Grade 3',
      theme: 'House',
      minGradeLevel: GradeLevel.k,
      maxGradeLevel: GradeLevel.g3,
      words: [
        _word(id: 'gather', text: 'Gather', grade: GradeLevel.k),
        _word(id: 'calculate', text: 'Calculate', grade: GradeLevel.g3),
      ],
    );

    final forFirstGrade = wordsForLearner(set, GradeLevel.g1);

    expect(forFirstGrade.map((word) => word.id), ['gather']);
  });

  test('a harder single-grade list stays intact when opened', () {
    final set = VocabularySet(
      id: 'grade-5',
      title: 'Grade 5',
      description: 'Grade 5',
      gradeLabel: 'Grade 5',
      theme: 'Spelling',
      minGradeLevel: GradeLevel.g5,
      maxGradeLevel: GradeLevel.g5,
      words: [_word(id: 'route', text: 'route', grade: GradeLevel.g5)],
    );

    expect(wordsForLearner(set, GradeLevel.g1).single.id, 'route');
  });

  test('quiz distractors prefer the same difficulty', () {
    final correct = _word(id: 'cat', text: 'cat', grade: GradeLevel.g1);
    final choices = buildQuizChoices(
      correct: correct,
      allWords: [
        correct,
        _word(id: 'hat', text: 'hat', grade: GradeLevel.g1),
        _word(id: 'mat', text: 'mat', grade: GradeLevel.g1),
        _word(id: 'sat', text: 'sat', grade: GradeLevel.g1),
        _word(
          id: 'calculate',
          text: 'calculate',
          grade: GradeLevel.g3,
          difficulty: WordDifficulty.hard,
        ),
      ],
      random: Random(1),
    );

    expect(choices, hasLength(4));
    expect(
      choices.where((word) => word.id != 'cat').map((word) => word.difficulty),
      everyElement(WordDifficulty.easy),
    );
  });

  test('one-word quiz has no fake choices', () {
    final only = _word(id: 'period', text: 'period', grade: GradeLevel.k);
    expect(
      buildQuizChoices(correct: only, allWords: [only]).single.id,
      'period',
    );
  });

  test('older correct words come back before words practiced today', () {
    final fresh = _word(id: 'fresh', text: 'fresh', grade: GradeLevel.g1);
    final due = _word(id: 'due', text: 'due', grade: GradeLevel.g1);
    final done = _word(id: 'done', text: 'done', grade: GradeLevel.g1);
    final session = buildQuizSession(
      [done, due, fresh],
      {
        due.id: WordProgress(
          wordId: due.id,
          quizCorrect: true,
          lastPracticedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        done.id: WordProgress(
          wordId: done.id,
          quizCorrect: true,
          lastPracticedAt: DateTime.now(),
        ),
      },
    );

    expect(session.indexOf(fresh), lessThan(session.indexOf(due)));
    expect(session.indexOf(due), lessThan(session.indexOf(done)));
  });
}
