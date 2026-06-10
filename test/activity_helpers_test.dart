import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/models/activity_entry.dart';
import 'package:vocab_aloud_app/models/profile_progress.dart';
import 'package:vocab_aloud_app/utils/activity_helpers.dart';

void main() {
  group('shortSetLabel', () {
    test('parses default vocabulary set titles', () {
      expect(shortSetLabel('Vocabulary Set 5'), 'Set 5');
      expect(shortSetLabel('Vocabulary Set 12'), 'Set 12');
    });

    test('returns full title for community sets', () {
      const title = 'Ms Frizzle 1st Grade Week 1';
      expect(shortSetLabel(title), title);
    });
  });

  group('formatActivitySummary', () {
    test('formats quiz completion with score', () {
      final entry = ActivityEntry(
        id: 'activity-1',
        completedAt: DateTime.utc(2026, 6, 10, 12),
        type: ActivityType.quiz,
        setId: 'vocab-set-05',
        setTitle: 'Vocabulary Set 5',
        correctCount: 9,
        totalCount: 10,
      );

      expect(
        formatActivitySummary(entry),
        'Set 5 Quiz Completed: 9/10 correct',
      );
    });

    test('formats learn words completion with word count', () {
      final entry = ActivityEntry(
        id: 'activity-2',
        completedAt: DateTime.utc(2026, 6, 10, 12),
        type: ActivityType.learnWords,
        setId: 'vocab-set-05',
        setTitle: 'Vocabulary Set 5',
        correctCount: 10,
        totalCount: 10,
      );

      expect(
        formatActivitySummary(entry),
        'Set 5 Learn Words Completed: 10/10 words',
      );
    });
  });

  group('formatLocalDateTime', () {
    test('formats UTC timestamp in local time', () {
      final utc = DateTime.utc(2026, 6, 10, 21, 45);
      final local = utc.toLocal();
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      final amPm = local.hour >= 12 ? 'PM' : 'AM';
      final expected =
          '${local.month}/${local.day}/${local.year}, $hour:$minute $amPm';

      expect(formatLocalDateTime(utc), expected);
    });
  });

  group('ProfileProgress activityLog JSON', () {
    test('round-trips activity entries', () {
      final entry = ActivityEntry(
        id: 'activity-1',
        completedAt: DateTime.utc(2026, 6, 10, 12),
        type: ActivityType.quiz,
        setId: 'vocab-set-05',
        setTitle: 'Vocabulary Set 5',
        correctCount: 9,
        totalCount: 10,
      );
      final progress = ProfileProgress(activityLog: [entry]);

      final restored = ProfileProgress.fromJson(progress.toJson());

      expect(restored.activityLog, hasLength(1));
      expect(restored.activityLog.first.id, entry.id);
      expect(restored.activityLog.first.type, ActivityType.quiz);
      expect(restored.activityLog.first.correctCount, 9);
      expect(restored.activityLog.first.totalCount, 10);
    });

    test('defaults to empty list when activityLog is missing', () {
      final progress = ProfileProgress.fromJson(<String, dynamic>{
        'selectedSetId': 'vocab-set-01',
        'lastModeBySet': <String, dynamic>{},
        'sets': <String, dynamic>{},
      });

      expect(progress.activityLog, isEmpty);
    });
  });
}
