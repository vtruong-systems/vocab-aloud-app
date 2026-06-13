import 'dart:io';

const defaultCsvPath = 'data/vocabulary/default/vocab.csv';
const communityDirPath = 'data/vocabulary/community';
const outputPath = 'lib/data/vocabulary_sets.dart';

const setIdPattern = r'^[a-z0-9]+(-[a-z0-9]+)*$';
const reservedSetIdPrefix = 'vocab-set-';

class WordRow {
  WordRow({
    required this.word,
    required this.category,
    required this.meaning,
    required this.grade,
    required this.difficulty,
    this.exampleSentence,
  });

  final String word;
  final String category;
  final String meaning;
  final String grade;
  final String difficulty;
  final String? exampleSentence;
}

class ParsedSet {
  ParsedSet({
    required this.id,
    required this.title,
    required this.description,
    required this.gradeLabel,
    required this.theme,
    required this.minGradeLevel,
    required this.maxGradeLevel,
    required this.words,
    required this.source,
    this.teacher,
    this.school,
    this.setNumber,
  });

  final String id;
  final String title;
  final String description;
  final String gradeLabel;
  final String theme;
  final String minGradeLevel;
  final String maxGradeLevel;
  final List<WordRow> words;
  final String? teacher;
  final String? school;
  final SetSource source;
  final int? setNumber;
}

enum SetSource { defaultSet, community }

class VocabularyGeneratorException implements Exception {
  VocabularyGeneratorException(this.message);

  final String message;

  @override
  String toString() => message;
}

List<ParsedSet> loadAllSets({
  String? defaultCsvPathOverride,
  String? communityDirOverride,
}) {
  final defaultPath = defaultCsvPathOverride ?? defaultCsvPath;
  final communityPath = communityDirOverride ?? communityDirPath;

  final defaultFile = File(defaultPath);
  if (!defaultFile.existsSync()) {
    throw VocabularyGeneratorException('Missing $defaultPath');
  }

  final defaultSets = parseDefaultCsv(defaultFile.readAsStringSync());
  final communitySets = <ParsedSet>[];

  final communityDir = Directory(communityPath);
  if (communityDir.existsSync()) {
    final files = communityDir.listSync().whereType<File>().where((file) {
      final name = file.uri.pathSegments.last;
      return name.endsWith('.csv') && !name.startsWith('_');
    }).toList()..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final filename = file.uri.pathSegments.last;
      final setIdFromFilename = filename.replaceAll(RegExp(r'\.csv$'), '');
      communitySets.add(
        parseCommunityCsv(
          file.readAsStringSync(),
          filename: filename,
          setIdFromFilename: setIdFromFilename,
        ),
      );
    }
  }

  validateSets([...defaultSets, ...communitySets]);
  return [...defaultSets, ...communitySets];
}

List<ParsedSet> parseDefaultCsv(String content) {
  final lines = content
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  if (lines.isEmpty) {
    throw VocabularyGeneratorException('Default CSV is empty');
  }
  if (lines.first !=
      'Word,Category,Meaning,Related Words,Grade,Difficulty,Example Sentence,Set') {
    throw VocabularyGeneratorException(
      'Default CSV header must include Example Sentence before Set',
    );
  }

  final sets = <int, List<WordRow>>{};
  for (var i = 1; i < lines.length; i++) {
    final row = _parseDefaultRow(lines[i]);
    sets.putIfAbsent(row.setNumber, () => []).add(row.wordRow);
  }

  final sortedSetNumbers = sets.keys.toList()..sort();
  return [
    for (final setNumber in sortedSetNumbers)
      _buildDefaultSet(setNumber, sets[setNumber]!),
  ];
}

ParsedSet parseCommunityCsv(
  String content, {
  required String filename,
  required String setIdFromFilename,
}) {
  final lines = content.split('\n');
  final metadata = <String, String>{};
  final wordRows = <WordRow>[];
  var foundWordHeader = false;

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;

    if (line.startsWith('# ')) {
      final body = line.substring(2);
      final commaIndex = body.indexOf(',');
      if (commaIndex == -1) {
        throw VocabularyGeneratorException(
          '$filename: invalid metadata line "$line" (expected # key,value)',
        );
      }
      final key = body.substring(0, commaIndex).trim();
      final value = body.substring(commaIndex + 1).trim();
      metadata[key] = value;
      continue;
    }

    if (line == 'Word,Category,Meaning,Related Words,Grade,Difficulty') {
      foundWordHeader = true;
      continue;
    }

    if (!foundWordHeader) {
      throw VocabularyGeneratorException(
        '$filename: expected word header before data rows',
      );
    }

    wordRows.add(_parseCommunityWordRow(line, filename));
  }

  final setId = metadata['set_id'];
  if (setId == null || setId.isEmpty) {
    throw VocabularyGeneratorException('$filename: missing required # set_id');
  }
  final title = metadata['title'];
  if (title == null || title.isEmpty) {
    throw VocabularyGeneratorException('$filename: missing required # title');
  }

  if (setId != setIdFromFilename) {
    throw VocabularyGeneratorException(
      '$filename: set_id "$setId" must match filename "$setIdFromFilename.csv"',
    );
  }

  _validateSetId(setId, filename);

  final description = metadata['description'] ?? 'Practice words from $title.';
  final theme = metadata['theme'] ?? _themeForRows(wordRows);
  final gradeLabel = _gradeLabelForRows(wordRows);

  return ParsedSet(
    id: setId,
    title: title,
    description: description,
    gradeLabel: gradeLabel,
    theme: theme,
    minGradeLevel: _minGradeLevelForRows(wordRows),
    maxGradeLevel: _maxGradeLevelForRows(wordRows),
    words: wordRows,
    teacher: metadata['teacher'],
    school: metadata['school'],
    source: SetSource.community,
  );
}

void validateSets(List<ParsedSet> sets) {
  final seenSetIds = <String>{};

  for (final set in sets) {
    if (set.words.isEmpty) {
      throw VocabularyGeneratorException('Set "${set.id}" has no words');
    }

    if (!seenSetIds.add(set.id)) {
      throw VocabularyGeneratorException('Duplicate set_id: ${set.id}');
    }

    if (set.source == SetSource.community) {
      _validateSetId(set.id, set.id);
    }

    final seenWordIds = <String>{};
    for (final row in set.words) {
      final wordId = '${set.id}-${_slug(row.word)}';
      if (!seenWordIds.add(wordId)) {
        throw VocabularyGeneratorException(
          'Duplicate word id "$wordId" in set "${set.id}"',
        );
      }
    }
  }
}

ParsedSet _buildDefaultSet(int setNumber, List<WordRow> rows) {
  final setId = 'vocab-set-${setNumber.toString().padLeft(2, '0')}';
  return ParsedSet(
    id: setId,
    title: 'Vocabulary Set $setNumber',
    description: 'Practice words from set $setNumber.',
    gradeLabel: _gradeLabelForRows(rows),
    theme: _themeForRows(rows),
    minGradeLevel: _minGradeLevelForRows(rows),
    maxGradeLevel: _maxGradeLevelForRows(rows),
    words: rows,
    source: SetSource.defaultSet,
    setNumber: setNumber,
  );
}

class _DefaultRowParseResult {
  _DefaultRowParseResult({required this.wordRow, required this.setNumber});

  final WordRow wordRow;
  final int setNumber;
}

_DefaultRowParseResult _parseDefaultRow(String line) {
  final parts = line.split(',');
  if (parts.length < 8) {
    throw FormatException('Invalid CSV row: $line');
  }
  final setStr = parts.last.trim();
  final exampleSentence = parts[parts.length - 2].trim();
  final difficulty = parts[parts.length - 3].trim();
  final grade = parts[parts.length - 4].trim();
  final meaning = parts.sublist(2, parts.length - 5).join(',').trim();
  final category = parts[1].trim();
  final word = parts[0].trim();
  if (exampleSentence.isEmpty) {
    throw FormatException('Missing example sentence for "$word"');
  }
  return _DefaultRowParseResult(
    setNumber: int.parse(setStr),
    wordRow: WordRow(
      word: word,
      category: category,
      meaning: meaning,
      grade: grade,
      difficulty: difficulty,
      exampleSentence: exampleSentence,
    ),
  );
}

WordRow _parseCommunityWordRow(String line, String filename) {
  final parts = line.split(',');
  if (parts.length < 6) {
    throw VocabularyGeneratorException(
      '$filename: invalid word row (expected 6 columns): $line',
    );
  }
  final difficulty = parts[parts.length - 1].trim();
  final grade = parts[parts.length - 2].trim();
  final meaning = parts.sublist(2, parts.length - 2).join(',').trim();
  final category = parts[1].trim();
  final word = parts[0].trim();
  return WordRow(
    word: word,
    category: category,
    meaning: meaning,
    grade: grade,
    difficulty: difficulty,
  );
}

void _validateSetId(String setId, String context) {
  if (!RegExp(setIdPattern).hasMatch(setId)) {
    throw VocabularyGeneratorException(
      '$context: invalid set_id "$setId" (use lowercase letters, numbers, hyphens)',
    );
  }
  if (setId.startsWith(reservedSetIdPrefix)) {
    throw VocabularyGeneratorException(
      '$context: set_id "$setId" uses reserved prefix "$reservedSetIdPrefix"',
    );
  }
}

String generateDartSource(List<ParsedSet> sets) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE — run: dart run tool/generate_vocabulary.dart')
    ..writeln("import '../models/grade_level.dart';")
    ..writeln("import '../models/vocabulary_set.dart';")
    ..writeln("import '../models/vocabulary_word.dart';")
    ..writeln("import '../models/word_difficulty.dart';")
    ..writeln();

  final constNames = <String>[];
  for (final set in sets) {
    final constName = _dartConstName(set);
    constNames.add(constName);
    _writeSetConst(buffer, set, constName);
    buffer.writeln();
  }

  buffer.writeln('const List<VocabularySet> vocabularySets = [');
  for (final constName in constNames) {
    buffer.writeln('  $constName,');
  }
  buffer.writeln('];');

  return buffer.toString();
}

String _dartConstName(ParsedSet set) {
  if (set.source == SetSource.defaultSet && set.setNumber != null) {
    return 'vocabularySet${set.setNumber}';
  }
  return 'communitySet_${set.id.replaceAll('-', '_')}';
}

void _writeSetConst(StringBuffer buffer, ParsedSet set, String constName) {
  buffer.writeln('const $constName = VocabularySet(');
  buffer.writeln("  id: '${_escapeDart(set.id)}',");
  buffer.writeln("  title: '${_escapeDart(set.title)}',");
  buffer.writeln("  description: '${_escapeDart(set.description)}',");
  buffer.writeln("  gradeLabel: '${_escapeDart(set.gradeLabel)}',");
  buffer.writeln("  theme: '${_escapeDart(set.theme)}',");
  buffer.writeln('  minGradeLevel: GradeLevel.${set.minGradeLevel},');
  buffer.writeln('  maxGradeLevel: GradeLevel.${set.maxGradeLevel},');
  if (set.teacher != null) {
    buffer.writeln("  teacher: '${_escapeDart(set.teacher!)}',");
  }
  if (set.school != null) {
    buffer.writeln("  school: '${_escapeDart(set.school!)}',");
  }
  if (set.source == SetSource.community) {
    buffer.writeln('  source: VocabularySetSource.community,');
  }
  buffer.writeln('  words: [');
  for (final row in set.words) {
    final wordId = '${set.id}-${_slug(row.word)}';
    final difficulty = _difficultyFromCsv(row.difficulty);
    final gradeLevel = _gradeLevelForCsv(row.grade);
    final partOfSpeech = _partOfSpeechForCategory(row.category);
    final example =
        row.exampleSentence ??
        _exampleSentence(row.word, row.category, row.meaning);
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
}

String _slug(String word) => word
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

String _escapeDart(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

const _gradeOrder = ['Pre-K', 'K', '1', '2', '3', '4', '5'];

String _gradeLabelForRows(List<WordRow> rows) {
  final grades = rows.map((r) => r.grade).toSet().toList()..sort();
  if (grades.length == 1) {
    return 'Level ${_displayLevelForCsvGrade(grades.first)}';
  }
  return 'Mixed Levels';
}

String _themeForRows(List<WordRow> rows) {
  final categories = rows.map((r) => r.category).toSet().toList()..sort();
  if (categories.length <= 2) {
    return categories.join(' & ');
  }
  return 'Core Vocabulary';
}

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
      throw VocabularyGeneratorException('Unknown grade: $grade');
  }
}

String _maxGradeLevelForRows(List<WordRow> rows) {
  var maxIndex = 0;
  for (final row in rows) {
    final index = _gradeOrder.indexOf(row.grade);
    if (index == -1) {
      throw VocabularyGeneratorException('Unknown grade: ${row.grade}');
    }
    if (index > maxIndex) maxIndex = index;
  }
  return _gradeLevelForCsv(_gradeOrder[maxIndex]);
}

String _minGradeLevelForRows(List<WordRow> rows) {
  var minIndex = _gradeOrder.length - 1;
  for (final row in rows) {
    final index = _gradeOrder.indexOf(row.grade);
    if (index == -1) {
      throw VocabularyGeneratorException('Unknown grade: ${row.grade}');
    }
    if (index < minIndex) minIndex = index;
  }
  return _gradeLevelForCsv(_gradeOrder[minIndex]);
}

int _displayLevelForCsvGrade(String grade) {
  final index = _gradeOrder.indexOf(grade);
  if (index == -1) {
    throw VocabularyGeneratorException('Unknown grade: $grade');
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

void writeGeneratedCatalog({String? outputPathOverride}) {
  final sets = loadAllSets();
  final target = outputPathOverride ?? outputPath;
  File(target).writeAsStringSync(generateDartSource(sets));
}
