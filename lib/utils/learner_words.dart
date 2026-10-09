import '../models/grade_level.dart';
import '../models/vocabulary_set.dart';
import '../models/vocabulary_word.dart';

/// Words at or below the child's grade. A single-grade list the child opened
/// on purpose is left intact when none of its words match.
List<VocabularyWord> wordsForLearner(VocabularySet set, GradeLevel? maxGrade) {
  if (maxGrade == null) return set.words;
  final matched = set.words
      .where((word) => word.gradeLevel.order <= maxGrade.order)
      .toList();
  if (matched.isEmpty) return set.words;
  return matched;
}

VocabularySet setForLearner(VocabularySet set, GradeLevel? maxGrade) {
  final words = wordsForLearner(set, maxGrade);
  if (words.length == set.words.length) return set;
  return set.copyWith(words: words);
}
