import 'grade_level.dart';
import 'word_difficulty.dart';

class VocabularyWord {
  const VocabularyWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.exampleSentence,
    required this.partOfSpeech,
    required this.difficulty,
    required this.gradeLevel,
  });

  final String id;
  final String word;
  final String definition;
  final String exampleSentence;
  final String partOfSpeech;
  final WordDifficulty difficulty;
  final GradeLevel gradeLevel;

  bool get isMultiWord => word.contains(' ');
}
