import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/models/grade_level.dart';
import 'package:vocab_aloud_app/models/vocabulary_set.dart';
import 'package:vocab_aloud_app/models/vocabulary_word.dart';
import 'package:vocab_aloud_app/models/word_difficulty.dart';
import 'package:vocab_aloud_app/utils/set_search.dart';

void main() {
  final defaultSet = VocabularySet(
    id: 'vocab-set-01',
    title: 'Vocabulary Set 1',
    description: 'Practice words from set 1.',
    gradeLabel: 'Mixed Levels',
    theme: 'Core Vocabulary',
    minGradeLevel: GradeLevel.g1,
    maxGradeLevel: GradeLevel.g4,
    words: const [
      VocabularyWord(
        id: 'vocab-set-01-alpha',
        word: 'Alpha',
        definition: 'First',
        exampleSentence: 'Alpha sentence.',
        partOfSpeech: 'noun',
        difficulty: WordDifficulty.easy,
        gradeLevel: GradeLevel.g1,
      ),
    ],
  );

  final communitySet = VocabularySet(
    id: 'ms-frizzle-1st-grade-week-1',
    title: 'Ms. Frizzle — 1st Grade Week 1',
    description: 'Weekly vocabulary for room 12',
    gradeLabel: 'Level 3',
    theme: 'Science & Nature',
    minGradeLevel: GradeLevel.g1,
    maxGradeLevel: GradeLevel.g1,
    teacher: 'Ms. Frizzle',
    school: 'Lincoln Elementary',
    source: VocabularySetSource.community,
    words: const [
      VocabularyWord(
        id: 'ms-frizzle-1st-grade-week-1-gather',
        word: 'Gather',
        definition: 'To bring things together',
        exampleSentence: 'Gather sentence.',
        partOfSpeech: 'verb',
        difficulty: WordDifficulty.easy,
        gradeLevel: GradeLevel.g1,
      ),
    ],
  );

  test('matches teacher name', () {
    expect(setMatchesQuery(communitySet, 'frizzle'), isTrue);
    expect(setMatchesQuery(defaultSet, 'frizzle'), isFalse);
  });

  test('matches school name', () {
    expect(setMatchesQuery(communitySet, 'lincoln'), isTrue);
  });

  test('matches set id', () {
    expect(setMatchesQuery(communitySet, 'week-1'), isTrue);
  });

  test('empty query matches all sets', () {
    expect(setMatchesQuery(communitySet, ''), isTrue);
    expect(setMatchesQuery(communitySet, '   '), isTrue);
  });

  test('filterSetsByQuery returns matching sets only', () {
    final results = filterSetsByQuery(
      [defaultSet, communitySet],
      'frizzle',
    );

    expect(results, [communitySet]);
  });

  test('splits default and community sets', () {
    final sets = [defaultSet, communitySet];

    expect(defaultSets(sets), [defaultSet]);
    expect(communitySets(sets), [communitySet]);
    expect(hasCommunitySets(sets), isTrue);
    expect(hasCommunitySets([defaultSet]), isFalse);
  });
}
