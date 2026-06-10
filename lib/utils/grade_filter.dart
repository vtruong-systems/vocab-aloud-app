import '../models/grade_level.dart';
import '../models/vocabulary_set.dart';

enum SetLevelSort {
  setNumber,
  levelAsc,
  levelDesc,
}

bool isSetVisibleForLevel(VocabularySet set, GradeLevel? selectedLevel) {
  if (selectedLevel == null) return true;
  return selectedLevel.order >= set.minGradeLevel.order &&
      selectedLevel.order <= set.maxGradeLevel.order;
}

List<VocabularySet> filterSetsByLevel(
  List<VocabularySet> all,
  GradeLevel? selectedLevel,
) {
  return all.where((set) => isSetVisibleForLevel(set, selectedLevel)).toList();
}

List<VocabularySet> sortSetsByLevel(
  List<VocabularySet> sets,
  SetLevelSort sort,
) {
  final sorted = List<VocabularySet>.from(sets);
  switch (sort) {
    case SetLevelSort.setNumber:
      sorted.sort((a, b) => a.id.compareTo(b.id));
    case SetLevelSort.levelAsc:
      sorted.sort((a, b) {
        final levelCompare =
            a.maxGradeLevel.order.compareTo(b.maxGradeLevel.order);
        if (levelCompare != 0) return levelCompare;
        return a.id.compareTo(b.id);
      });
    case SetLevelSort.levelDesc:
      sorted.sort((a, b) {
        final levelCompare =
            b.maxGradeLevel.order.compareTo(a.maxGradeLevel.order);
        if (levelCompare != 0) return levelCompare;
        return a.id.compareTo(b.id);
      });
  }
  return sorted;
}

List<VocabularySet> filterAndSortSets(
  List<VocabularySet> all, {
  GradeLevel? selectedLevel,
  SetLevelSort sort = SetLevelSort.setNumber,
}) {
  return sortSetsByLevel(filterSetsByLevel(all, selectedLevel), sort);
}

String formatSetLevelLabel(VocabularySet set) {
  if (set.minGradeLevel == set.maxGradeLevel) {
    return set.minGradeLevel.label;
  }
  return 'Levels ${set.minGradeLevel.displayLevel}–${set.maxGradeLevel.displayLevel}';
}
