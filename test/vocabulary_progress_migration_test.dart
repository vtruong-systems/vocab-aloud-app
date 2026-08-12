import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/models/activity_entry.dart';
import 'package:vocab_aloud_app/models/app_state.dart';
import 'package:vocab_aloud_app/models/profile_progress.dart';
import 'package:vocab_aloud_app/models/word_progress.dart';
import 'package:vocab_aloud_app/utils/vocabulary_progress_migration.dart';

void main() {
  test('migrates Truong set and word progress IDs', () {
    final practicedAt = DateTime.utc(2026, 8, 12);
    final state = AppState(
      activeProfileId: 'profile-1',
      profileProgress: {
        'profile-1': ProfileProgress(
          selectedSetId: 'vocab-set-01',
          lastModeBySet: const {'vocab-set-01': 'quiz'},
          sets: {
            'vocab-set-01': SetProgress(
              wordProgress: {
                'vocab-set-01-gather': WordProgress(
                  wordId: 'vocab-set-01-gather',
                  reviewed: true,
                  quizCorrect: true,
                  quizAttempts: 2,
                  quizCorrectCount: 1,
                  lastPracticedAt: practicedAt,
                ),
              },
            ),
          },
          activityLog: [
            ActivityEntry(
              id: 'activity-1',
              completedAt: practicedAt,
              type: ActivityType.quiz,
              setId: 'vocab-set-01',
              setTitle: 'Vocabulary Set 1',
              correctCount: 7,
              totalCount: 8,
            ),
          ],
        ),
      },
    );

    final result = migrateVocabularyProgress(state);
    final progress = result.state.profileProgress['profile-1']!;
    final word = progress
        .sets['truong-vocab-set-01']!
        .wordProgress['truong-vocab-set-01-gather']!;

    expect(result.changed, isTrue);
    expect(progress.selectedSetId, 'truong-vocab-set-01');
    expect(progress.lastModeBySet, {'truong-vocab-set-01': 'quiz'});
    expect(word.wordId, 'truong-vocab-set-01-gather');
    expect(word.reviewed, isTrue);
    expect(word.quizCorrect, isTrue);
    expect(word.quizAttempts, 2);
    expect(word.quizCorrectCount, 1);
    expect(word.lastPracticedAt, practicedAt);
    expect(progress.activityLog.single.setId, 'truong-vocab-set-01');
    expect(progress.activityLog.single.setTitle, 'Truong Vocabulary Set 1');
  });

  test('migrates current personal sets and is idempotent', () {
    const state = AppState(
      profileProgress: {
        'profile-1': ProfileProgress(
          selectedSetId: 'science-lab-basics',
          lastModeBySet: {'school-words': 'learn'},
        ),
      },
    );

    final first = migrateVocabularyProgress(state);
    final second = migrateVocabularyProgress(first.state);
    final progress = first.state.profileProgress['profile-1']!;

    expect(first.changed, isTrue);
    expect(progress.selectedSetId, 'truong-science-lab-basics');
    expect(progress.lastModeBySet, {'truong-school-words': 'learn'});
    expect(second.changed, isFalse);
    expect(identical(second.state, first.state), isTrue);
  });

  test('keeps Grade 1 spelling IDs unchanged', () {
    const state = AppState(
      profileProgress: {
        'profile-1': ProfileProgress(selectedSetId: 'grade-1-spelling-week-01'),
      },
    );

    final result = migrateVocabularyProgress(state);

    expect(result.changed, isFalse);
    expect(identical(result.state, state), isTrue);
  });
}
