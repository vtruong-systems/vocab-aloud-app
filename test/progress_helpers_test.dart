import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/data/vocabulary_sets.dart';
import 'package:vocab_aloud_app/models/grade_level.dart';
import 'package:vocab_aloud_app/models/local_profile.dart';
import 'package:vocab_aloud_app/models/vocabulary_set.dart';
import 'package:vocab_aloud_app/models/vocabulary_word.dart';
import 'package:vocab_aloud_app/models/word_difficulty.dart';
import 'package:vocab_aloud_app/models/word_progress.dart';
import 'package:vocab_aloud_app/utils/grade_filter.dart';
import 'package:vocab_aloud_app/utils/progress_helpers.dart';

void main() {
  group('computeSetStats step-based progress', () {
    test('vocabulary set 1 total steps matches word count', () {
      final expectedSteps = vocabularySet1.words.fold<int>(
        0,
        (sum, word) => sum + (word.isMultiWord ? 3 : 4),
      );
      final stats = computeSetStats(vocabularySet1, {}, requireTyped: false);

      expect(stats.totalSteps, expectedSteps);
      expect(stats.completedSteps, 0);
      expect(stats.statusLabel, 'Not Started');
    });

    test('partial review progress shows in progress', () {
      final totalSteps = vocabularySet1.words.fold<int>(
        0,
        (sum, word) => sum + (word.isMultiWord ? 3 : 4),
      );
      final progress = {
        for (var i = 0; i < 6; i++)
          vocabularySet1.words[i].id: WordProgress(
            wordId: vocabularySet1.words[i].id,
            reviewed: true,
          ),
      };

      final stats = computeSetStats(
        vocabularySet1,
        progress,
        requireTyped: false,
      );

      expect(stats.completedSteps, 6);
      expect(stats.totalSteps, totalSteps);
      expect(stats.statusLabel, 'In Progress');
      expect(stats.completionPercent, closeTo(6 / totalSteps, 0.001));
    });

    test('all modes complete on all words marks set complete', () {
      final totalSteps = vocabularySet1.words.fold<int>(
        0,
        (sum, word) => sum + (word.isMultiWord ? 3 : 4),
      );
      final progress = {
        for (final word in vocabularySet1.words)
          word.id: WordProgress(
            wordId: word.id,
            reviewed: true,
            quizCorrect: true,
            spellingCompleted: true,
            typedCompleted: true,
          ),
      };

      final stats = computeSetStats(
        vocabularySet1,
        progress,
        requireTyped: false,
      );

      expect(stats.completedSteps, totalSteps);
      expect(stats.totalSteps, totalSteps);
      expect(stats.statusLabel, 'Complete');
      expect(stats.completionPercent, 1);
    });

    test('multi-word entries exclude spell step from total', () {
      const multiWordSet = VocabularySet(
        id: 'test-set',
        title: 'Test Set',
        description: 'Test',
        gradeLabel: 'Test',
        theme: 'Test',
        minGradeLevel: GradeLevel.g1,
        maxGradeLevel: GradeLevel.g2,
        words: [
          VocabularyWord(
            id: 'single-word',
            word: 'hello',
            definition: 'greeting',
            exampleSentence: 'Say hello.',
            partOfSpeech: 'noun',
            difficulty: WordDifficulty.easy,
            gradeLevel: GradeLevel.g1,
          ),
          VocabularyWord(
            id: 'multi-word',
            word: 'ice cream',
            definition: 'frozen dessert',
            exampleSentence: 'I like ice cream.',
            partOfSpeech: 'noun',
            difficulty: WordDifficulty.easy,
            gradeLevel: GradeLevel.g2,
          ),
        ],
      );

      final stats = computeSetStats(multiWordSet, {}, requireTyped: false);

      expect(stats.totalSteps, 7);
      expect(totalStepsForWord(multiWordSet.words.first), 4);
      expect(totalStepsForWord(multiWordSet.words.last), 3);
    });

    test('completedStepsForWord counts applicable modes only', () {
      const multiWord = VocabularyWord(
        id: 'multi-word',
        word: 'ice cream',
        definition: 'frozen dessert',
        exampleSentence: 'I like ice cream.',
        partOfSpeech: 'noun',
        difficulty: WordDifficulty.easy,
        gradeLevel: GradeLevel.g2,
      );

      const progress = WordProgress(
        wordId: 'multi-word',
        reviewed: true,
        quizCorrect: true,
        typedCompleted: true,
        spellingCompleted: true,
      );

      expect(completedStepsForWord(progress, multiWord), 3);
    });
  });

  group('countSetsInProgress', () {
    test('uses step-based progress instead of mastered count', () {
      final progress = {
        vocabularySet1.id: {
          vocabularySet1.words.first.id: WordProgress(
            wordId: vocabularySet1.words.first.id,
            reviewed: true,
          ),
        },
      };

      final count = countSetsInProgress(
        [vocabularySet1],
        progress,
        requireTyped: false,
      );

      expect(count, 1);
    });

    test('respects filtered set list', () {
      final progress = {
        vocabularySet1.id: {
          vocabularySet1.words.first.id: WordProgress(
            wordId: vocabularySet1.words.first.id,
            reviewed: true,
          ),
        },
      };

      final visible = filterSetsByLevel(vocabularySets, GradeLevel.preK);
      final count = countSetsInProgress(
        visible,
        progress,
        requireTyped: false,
      );

      expect(count, 0);
    });
  });

  group('LocalProfile grade', () {
    test('JSON round-trip preserves maxGradeLevel', () {
      final profile = LocalProfile(
        id: 'profile-1',
        displayName: 'Alex',
        createdAt: DateTime.utc(2026, 1, 1),
        maxGradeLevel: GradeLevel.g3,
      );

      final restored = LocalProfile.fromJson(profile.toJson());

      expect(restored.maxGradeLevel, GradeLevel.g3);
      expect(restored.effectiveMaxGradeLevel, GradeLevel.g3);
    });

    test('null maxGradeLevel defaults to Level 5', () {
      final profile = LocalProfile(
        id: 'profile-1',
        displayName: 'Alex',
        createdAt: DateTime.utc(2026, 1, 1),
      );

      expect(profile.effectiveMaxGradeLevel, GradeLevel.g5);
      expect(profile.effectiveMaxGradeLevel.label, 'Level 7');
    });
  });
}
