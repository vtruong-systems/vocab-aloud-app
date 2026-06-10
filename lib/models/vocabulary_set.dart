import 'grade_level.dart';
import 'vocabulary_word.dart';

enum VocabularySetSource {
  defaultSet,
  community,
}

class VocabularySet {
  const VocabularySet({
    required this.id,
    required this.title,
    required this.description,
    required this.gradeLabel,
    required this.theme,
    required this.minGradeLevel,
    required this.maxGradeLevel,
    required this.words,
    this.teacher,
    this.school,
    this.source = VocabularySetSource.defaultSet,
  });

  final String id;
  final String title;
  final String description;
  final String gradeLabel;
  final String theme;
  final GradeLevel minGradeLevel;
  final GradeLevel maxGradeLevel;
  final List<VocabularyWord> words;
  final String? teacher;
  final String? school;
  final VocabularySetSource source;

  int get wordCount => words.length;

  bool get isCommunity => source == VocabularySetSource.community;
}
