import '../models/activity_entry.dart';

final _vocabularySetTitlePattern = RegExp(
  r'^Vocabulary Set (\d+)$',
  caseSensitive: false,
);

String shortSetLabel(String setTitle) {
  final match = _vocabularySetTitlePattern.firstMatch(setTitle.trim());
  if (match != null) {
    return 'Set ${match.group(1)}';
  }
  return setTitle;
}

String _modeLabel(ActivityType type) {
  switch (type) {
    case ActivityType.learnWords:
      return 'Learn Words';
    case ActivityType.quiz:
      return 'Quiz';
    case ActivityType.spellIt:
      return 'Spell It';
    case ActivityType.typeIt:
      return 'Type It';
  }
}

String formatActivitySummary(ActivityEntry entry) {
  final setLabel = shortSetLabel(entry.setTitle);
  final modeLabel = _modeLabel(entry.type);
  final base = '$setLabel $modeLabel Completed';

  final correct = entry.correctCount;
  final total = entry.totalCount;
  if (correct == null || total == null) {
    return base;
  }

  if (entry.type == ActivityType.learnWords) {
    return '$base: $correct/$total words';
  }

  return '$base: $correct/$total correct';
}

String formatLocalDateTime(DateTime completedAt) {
  final local = completedAt.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final amPm = local.hour >= 12 ? 'PM' : 'AM';
  return '${local.month}/${local.day}/${local.year}, $hour:$minute $amPm';
}
