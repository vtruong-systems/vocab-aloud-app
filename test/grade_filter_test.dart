import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/data/vocabulary_sets.dart';
import 'package:vocab_aloud_app/models/grade_level.dart';
import 'package:vocab_aloud_app/models/vocabulary_set.dart';
import 'package:vocab_aloud_app/models/vocabulary_word.dart';
import 'package:vocab_aloud_app/models/word_difficulty.dart';
import 'package:vocab_aloud_app/utils/grade_filter.dart';

VocabularySet _testSet({
  required String id,
  required GradeLevel minGradeLevel,
  required GradeLevel maxGradeLevel,
}) {
  return VocabularySet(
    id: id,
    title: 'Test Set',
    description: 'Test',
    gradeLabel: 'Mixed Levels',
    theme: 'Test',
    minGradeLevel: minGradeLevel,
    maxGradeLevel: maxGradeLevel,
    words: [
      VocabularyWord(
        id: '$id-word',
        word: 'hello',
        definition: 'greeting',
        exampleSentence: 'Say hello.',
        partOfSpeech: 'noun',
        difficulty: WordDifficulty.easy,
        gradeLevel: minGradeLevel,
      ),
    ],
  );
}

void main() {
  group('isSetVisibleForLevel', () {
    test('shows set when selected level is within set range', () {
      final set = _testSet(
        id: 'test-set',
        minGradeLevel: GradeLevel.preK,
        maxGradeLevel: GradeLevel.k,
      );

      expect(isSetVisibleForLevel(set, GradeLevel.preK), isTrue);
      expect(isSetVisibleForLevel(set, GradeLevel.k), isTrue);
      expect(isSetVisibleForLevel(set, GradeLevel.g1), isFalse);
    });

    test('Level 2 and Level 3 can return different sets', () {
      final earlySet = _testSet(
        id: 'early-set',
        minGradeLevel: GradeLevel.preK,
        maxGradeLevel: GradeLevel.k,
      );
      final laterSet = _testSet(
        id: 'later-set',
        minGradeLevel: GradeLevel.g1,
        maxGradeLevel: GradeLevel.g3,
      );

      expect(isSetVisibleForLevel(earlySet, GradeLevel.k), isTrue);
      expect(isSetVisibleForLevel(laterSet, GradeLevel.k), isFalse);
      expect(isSetVisibleForLevel(laterSet, GradeLevel.g1), isTrue);
    });

    test('null filter shows all sets', () {
      final set = _testSet(
        id: 'test-set',
        minGradeLevel: GradeLevel.g4,
        maxGradeLevel: GradeLevel.g5,
      );

      expect(isSetVisibleForLevel(set, null), isTrue);
    });
  });

  group('filterSetsByLevel', () {
    test('Level 1 filter sees 14 pure Pre-K sets', () {
      final visible = filterSetsByLevel(vocabularySets, GradeLevel.preK);

      expect(visible.length, 14);
      expect(
        visible.every(
          (set) =>
              set.minGradeLevel == GradeLevel.preK &&
              set.maxGradeLevel == GradeLevel.preK,
        ),
        isTrue,
      );
    });

    test('Level 2 filter sees K sets and not pure Level 1 sets', () {
      final level1 = filterSetsByLevel(vocabularySets, GradeLevel.preK);
      final level2 = filterSetsByLevel(vocabularySets, GradeLevel.k);
      final level1Ids = level1.map((set) => set.id).toSet();
      final level2Ids = level2.map((set) => set.id).toSet();

      expect(level2.length, 13);
      expect(level1Ids.intersection(level2Ids), isEmpty);
      expect(
        level2.every((set) => isSetVisibleForLevel(set, GradeLevel.k)),
        isTrue,
      );
    });

    test('All filter shows every set', () {
      final visible = filterSetsByLevel(vocabularySets, null);

      expect(visible.length, vocabularySets.length);
      expect(visible.length, 44);
    });
  });

  group('sortSetsByLevel', () {
    test('sorts by level ascending then set id', () {
      final sets = [
        _testSet(
          id: 'vocab-set-02',
          minGradeLevel: GradeLevel.g1,
          maxGradeLevel: GradeLevel.g4,
        ),
        _testSet(
          id: 'vocab-set-01',
          minGradeLevel: GradeLevel.preK,
          maxGradeLevel: GradeLevel.k,
        ),
        _testSet(
          id: 'vocab-set-03',
          minGradeLevel: GradeLevel.g1,
          maxGradeLevel: GradeLevel.g4,
        ),
      ];

      final sorted = sortSetsByLevel(sets, SetLevelSort.levelAsc);

      expect(sorted.map((set) => set.id).toList(), [
        'vocab-set-01',
        'vocab-set-02',
        'vocab-set-03',
      ]);
    });
  });

  group('formatSetLevelLabel', () {
    test('shows single level label', () {
      final set = VocabularySet(
        id: 'single-level-set',
        title: 'Single',
        description: 'Single',
        gradeLabel: 'Level 1',
        theme: 'Test',
        minGradeLevel: GradeLevel.preK,
        maxGradeLevel: GradeLevel.preK,
        words: const [],
      );

      expect(formatSetLevelLabel(set), 'Level 1');
    });

    test('shows level range for mixed sets', () {
      final set = VocabularySet(
        id: 'mixed-set',
        title: 'Mixed',
        description: 'Mixed',
        gradeLabel: 'Mixed Levels',
        theme: 'Test',
        minGradeLevel: GradeLevel.preK,
        maxGradeLevel: GradeLevel.k,
        words: const [],
      );

      expect(formatSetLevelLabel(set), 'Levels 1–2');
    });
  });

  group('GradeLevel', () {
    test('fromCsv parses CSV values', () {
      expect(GradeLevel.fromCsv('Pre-K'), GradeLevel.preK);
      expect(GradeLevel.fromCsv('K'), GradeLevel.k);
      expect(GradeLevel.fromCsv('4'), GradeLevel.g4);
    });

    test('labels use Level wording', () {
      expect(GradeLevel.preK.label, 'Level 1');
      expect(GradeLevel.k.label, 'Level 2');
      expect(GradeLevel.g1.label, 'Level 3');
      expect(GradeLevel.g3.label, 'Level 5');
      expect(GradeLevel.g5.label, 'Level 7');
    });

    test('JSON round-trip', () {
      expect(GradeLevel.fromJson(GradeLevel.g3.toJson()), GradeLevel.g3);
      expect(GradeLevel.fromJson(null), isNull);
    });
  });
}
