// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  final csvPath = 'vocab.csv';
  final outputPath = 'lib/data/vocabulary_sets.dart';
  final csvFile = File(csvPath);
  if (!csvFile.existsSync()) {
    stderr.writeln('Missing $csvPath');
    exit(1);
  }

  final lines = csvFile
      .readAsStringSync()
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .toList();

  if (lines.isEmpty) {
    stderr.writeln('CSV is empty');
    exit(1);
  }

  final sets = <int, List<_CsvRow>>{};
  for (var i = 1; i < lines.length; i++) {
    final row = _parseRow(lines[i]);
    sets.putIfAbsent(row.setNumber, () => []).add(row);
  }

  final sortedSetNumbers = sets.keys.toList()..sort();
  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE — run: dart run tool/generate_vocabulary.dart')
    ..writeln("import '../models/grade_level.dart';")
    ..writeln("import '../models/vocabulary_set.dart';")
    ..writeln("import '../models/vocabulary_word.dart';")
    ..writeln("import '../models/word_difficulty.dart';")
    ..writeln();

  for (final setNumber in sortedSetNumbers) {
    final rows = sets[setNumber]!;
    final setId = 'vocab-set-${setNumber.toString().padLeft(2, '0')}';
    final grades = rows.map((r) => r.grade).toSet().toList()..sort();
    final categories = rows.map((r) => r.category).toSet().toList()..sort();
    final gradeLabel = grades.length == 1
        ? 'Level ${_displayLevelForCsvGrade(grades.first)}'
        : 'Mixed Levels';
    final theme = categories.length <= 2
        ? categories.join(' & ')
        : 'Core Vocabulary';
    final maxGradeLevel = _maxGradeLevelForRows(rows);
    final minGradeLevel = _minGradeLevelForRows(rows);

    buffer.writeln('const vocabularySet$setNumber = VocabularySet(');
    buffer.writeln("  id: '$setId',");
    buffer.writeln("  title: 'Vocabulary Set $setNumber',");
    buffer.writeln(
      "  description: 'Practice words from set $setNumber.',",
    );
    buffer.writeln("  gradeLabel: '$gradeLabel',");
    buffer.writeln("  theme: '${_escapeDart(theme)}',");
    buffer.writeln('  minGradeLevel: GradeLevel.$minGradeLevel,');
    buffer.writeln('  maxGradeLevel: GradeLevel.$maxGradeLevel,');
    buffer.writeln('  words: [');
    for (final row in rows) {
      final wordId = '$setId-${_slug(row.word)}';
      final difficulty = _difficultyFromCsv(row.difficulty);
      final gradeLevel = _gradeLevelForCsv(row.grade);
      final partOfSpeech = _partOfSpeechForCategory(row.category);
      final example = _exampleSentence(row.word, row.category, row.meaning);
      buffer.writeln('    VocabularyWord(');
      buffer.writeln("      id: '$wordId',");
      buffer.writeln("      word: '${_escapeDart(row.word)}',");
      buffer.writeln("      definition: '${_escapeDart(row.meaning)}',");
      buffer.writeln("      exampleSentence: '${_escapeDart(example)}',");
      buffer.writeln("      partOfSpeech: '$partOfSpeech',");
      buffer.writeln('      difficulty: WordDifficulty.$difficulty,');
      buffer.writeln('      gradeLevel: GradeLevel.$gradeLevel,');
      buffer.writeln('    ),');
    }
    buffer.writeln('  ],');
    buffer.writeln(');');
    buffer.writeln();
  }

  buffer.writeln('const List<VocabularySet> vocabularySets = [');
  for (final setNumber in sortedSetNumbers) {
    buffer.writeln('  vocabularySet$setNumber,');
  }
  buffer.writeln('];');

  File(outputPath).writeAsStringSync(buffer.toString());
  print('Wrote ${sortedSetNumbers.length} sets to $outputPath');
}

class _CsvRow {
  _CsvRow({
    required this.word,
    required this.category,
    required this.meaning,
    required this.grade,
    required this.difficulty,
    required this.setNumber,
  });

  final String word;
  final String category;
  final String meaning;
  final String grade;
  final String difficulty;
  final int setNumber;
}

_CsvRow _parseRow(String line) {
  final parts = line.split(',');
  if (parts.length < 7) {
    throw FormatException('Invalid CSV row: $line');
  }
  final setStr = parts.last.trim();
  final grade = parts[parts.length - 3].trim();
  final difficulty = parts[parts.length - 2].trim();
  final meaning = parts.sublist(2, parts.length - 4).join(',').trim();
  final category = parts[1].trim();
  final word = parts[0].trim();
  return _CsvRow(
    word: word,
    category: category,
    meaning: meaning,
    grade: grade,
    difficulty: difficulty,
    setNumber: int.parse(setStr),
  );
}

String _slug(String word) =>
    word.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

String _escapeDart(String value) => value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

const _gradeOrder = ['Pre-K', 'K', '1', '2', '3', '4', '5'];

String _gradeLevelForCsv(String grade) {
  switch (grade) {
    case 'Pre-K':
      return 'preK';
    case 'K':
      return 'k';
    case '1':
      return 'g1';
    case '2':
      return 'g2';
    case '3':
      return 'g3';
    case '4':
      return 'g4';
    case '5':
      return 'g5';
    default:
      throw FormatException('Unknown grade: $grade');
  }
}

String _maxGradeLevelForRows(List<_CsvRow> rows) {
  var maxIndex = 0;
  for (final row in rows) {
    final index = _gradeOrder.indexOf(row.grade);
    if (index == -1) {
      throw FormatException('Unknown grade: ${row.grade}');
    }
    if (index > maxIndex) maxIndex = index;
  }
  return _gradeLevelForCsv(_gradeOrder[maxIndex]);
}

String _minGradeLevelForRows(List<_CsvRow> rows) {
  var minIndex = _gradeOrder.length - 1;
  for (final row in rows) {
    final index = _gradeOrder.indexOf(row.grade);
    if (index == -1) {
      throw FormatException('Unknown grade: ${row.grade}');
    }
    if (index < minIndex) minIndex = index;
  }
  return _gradeLevelForCsv(_gradeOrder[minIndex]);
}

int _displayLevelForCsvGrade(String grade) {
  final index = _gradeOrder.indexOf(grade);
  if (index == -1) {
    throw FormatException('Unknown grade: $grade');
  }
  return index + 1;
}

String _difficultyFromCsv(String difficulty) {
  switch (difficulty.toLowerCase()) {
    case 'easy':
      return 'easy';
    case 'hard':
      return 'hard';
    case 'medium':
    default:
      return 'medium';
  }
}

String _partOfSpeechForCategory(String category) {
  switch (category) {
    case 'Mathematics':
    case 'Scientific Thinking':
    case 'Punctuation':
    case 'Sequence Words':
    case 'Directional Language':
      return 'noun';
    case 'Feelings & Emotions':
      return 'adjective';
    case 'Instructional Language':
    case 'Progress & Learning':
    case 'Learning & Research':
    case 'Reading & Writing':
    case 'Communication & Discussion':
    case 'Thinking & Reasoning':
      return 'verb';
    default:
      return 'noun';
  }
}

String _exampleSentence(String word, String category, String meaning) {
  final lowerWord = word.toLowerCase();
  switch (category) {
    case 'Instructional Language':
    case 'Progress & Learning':
    case 'Learning & Research':
    case 'Communication & Discussion':
      return 'During class, we learned to $lowerWord together.';
    case 'Feelings & Emotions':
      return 'She felt $lowerWord after sharing her story.';
    case 'Mathematics':
    case 'Scientific Thinking':
      return 'Our lesson today was about $lowerWord.';
    case 'Reading & Writing':
      return 'In our book, the author used the word $lowerWord.';
    case 'Thinking & Reasoning':
      return 'We used the word $lowerWord when we solved the problem.';
    case 'Directional Language':
      return 'The teacher said to move $lowerWord the table.';
    default:
      return 'Can you use the word "$word" in a sentence? It means $meaning.';
  }
}
