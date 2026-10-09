import 'grade_level.dart';
import 'vocabulary_word.dart';

enum VocabularySetSource { defaultSet, community, device }

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

  bool get isDevice => source == VocabularySetSource.device;

  VocabularySet copyWith({
    String? title,
    String? description,
    List<VocabularyWord>? words,
  }) {
    return VocabularySet(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      gradeLabel: gradeLabel,
      theme: theme,
      minGradeLevel: minGradeLevel,
      maxGradeLevel: maxGradeLevel,
      words: words ?? this.words,
      teacher: teacher,
      school: school,
      source: source,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'gradeLabel': gradeLabel,
    'theme': theme,
    'minGradeLevel': minGradeLevel.toJson(),
    'maxGradeLevel': maxGradeLevel.toJson(),
    'teacher': teacher,
    'school': school,
    'source': source.name,
    'words': words.map((word) => word.toJson()).toList(),
  };

  factory VocabularySet.fromJson(Map<String, dynamic> json) {
    final minGrade =
        GradeLevel.fromJson(json['minGradeLevel'] as String?) ?? GradeLevel.g1;
    final maxGrade =
        GradeLevel.fromJson(json['maxGradeLevel'] as String?) ?? minGrade;
    return VocabularySet(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'My list',
      description: json['description'] as String? ?? '',
      gradeLabel: json['gradeLabel'] as String? ?? minGrade.label,
      theme: json['theme'] as String? ?? 'On this device',
      minGradeLevel: minGrade,
      maxGradeLevel: maxGrade,
      teacher: json['teacher'] as String?,
      school: json['school'] as String?,
      source: VocabularySetSource.values.firstWhere(
        (value) => value.name == json['source'],
        orElse: () => VocabularySetSource.device,
      ),
      words: (json['words'] as List<dynamic>? ?? [])
          .map((item) => VocabularyWord.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
