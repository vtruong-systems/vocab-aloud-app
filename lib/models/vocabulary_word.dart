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

  Map<String, dynamic> toJson() => {
    'id': id,
    'word': word,
    'definition': definition,
    'exampleSentence': exampleSentence,
    'partOfSpeech': partOfSpeech,
    'difficulty': difficulty.name,
    'gradeLevel': gradeLevel.toJson(),
  };

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] as String? ?? '',
      word: json['word'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      exampleSentence: json['exampleSentence'] as String? ?? '',
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      difficulty: WordDifficulty.values.firstWhere(
        (value) => value.name == json['difficulty'],
        orElse: () => WordDifficulty.medium,
      ),
      gradeLevel:
          GradeLevel.fromJson(json['gradeLevel'] as String?) ?? GradeLevel.g1,
    );
  }
}
