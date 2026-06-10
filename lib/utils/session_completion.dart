import 'package:flutter/material.dart';

import '../models/activity_entry.dart';
import '../models/vocabulary_word.dart';
import '../screens/session_completion_screen.dart';
import '../screens/set_completion_dialog.dart';
import '../state/app_controller.dart';
import 'progress_helpers.dart';

Future<void> showSessionCompletionAndExit({
  required BuildContext context,
  required String modeLabel,
  required List<VocabularyWord> missedWords,
  required AppController controller,
  required SetStats? statsBefore,
  ActivityType? activityType,
  int? sessionWordCount,
}) async {
  if (!context.mounted) return;

  final set = controller.selectedSet;
  if (activityType != null &&
      set != null &&
      sessionWordCount != null &&
      sessionWordCount > 0) {
    await controller.logActivity(
      type: activityType,
      setId: set.id,
      setTitle: set.title,
      correctCount: sessionWordCount - missedWords.length,
      totalCount: sessionWordCount,
    );
  }

  if (!context.mounted) return;

  await Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (context) => SessionCompletionScreen(
        modeLabel: modeLabel,
        missedWords: missedWords,
        onDone: () => Navigator.pop(context),
      ),
    ),
  );

  if (!context.mounted) return;

  final statsAfter = controller.getSelectedSetStats();
  if (statsAfter != null &&
      statsBefore != null &&
      statsAfter.masteredCount == statsAfter.totalWords &&
      statsBefore.masteredCount < statsAfter.totalWords) {
    await showSetCompletionDialog(context);
  }

  if (context.mounted) {
    Navigator.pop(context);
  }
}

List<VocabularyWord> missedWordsFromSession(
  List<VocabularyWord> session,
  Set<String> missedWordIds,
) {
  final seen = <String>{};
  final result = <VocabularyWord>[];

  for (final word in session) {
    if (missedWordIds.contains(word.id) && seen.add(word.id)) {
      result.add(word);
    }
  }

  return result;
}
