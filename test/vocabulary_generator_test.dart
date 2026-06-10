import 'package:flutter_test/flutter_test.dart';

import '../tool/vocabulary_generator.dart';

void main() {
  group('parseDefaultCsv', () {
    test('parses multiple sets from default CSV format', () {
      final sets = parseDefaultCsv(_fixture('default.csv'));

      expect(sets, hasLength(2));
      expect(sets[0].id, 'vocab-set-01');
      expect(sets[0].words, hasLength(2));
      expect(sets[0].source, SetSource.defaultSet);
      expect(sets[1].id, 'vocab-set-02');
      expect(sets[1].words.single.word, 'Gamma');
    });
  });

  group('parseCommunityCsv', () {
    test('parses header metadata and words', () {
      final set = parseCommunityCsv(
        _fixture('community-sample.csv'),
        filename: 'test-teacher-week-1.csv',
        setIdFromFilename: 'test-teacher-week-1',
      );

      expect(set.id, 'test-teacher-week-1');
      expect(set.title, 'Test Teacher Week 1');
      expect(set.teacher, 'Ms. Test');
      expect(set.school, 'Sample Elementary');
      expect(set.theme, 'Science');
      expect(set.source, SetSource.community);
      expect(set.words.single.word, 'Delta');
    });

    test('rejects reserved vocab-set prefix', () {
      expect(
        () => parseCommunityCsv(
          _fixture('community-duplicate-id.csv'),
          filename: 'vocab-set-99.csv',
          setIdFromFilename: 'vocab-set-99',
        ),
        throwsA(isA<VocabularyGeneratorException>()),
      );
    });

    test('rejects filename and set_id mismatch', () {
      expect(
        () => parseCommunityCsv(
          _fixture('community-sample.csv'),
          filename: 'wrong-name.csv',
          setIdFromFilename: 'wrong-name',
        ),
        throwsA(isA<VocabularyGeneratorException>()),
      );
    });
  });

  group('validateSets', () {
    test('rejects duplicate set ids', () {
      final defaultSets = parseDefaultCsv(_fixture('default.csv'));
      final communitySet = parseCommunityCsv(
        _fixture('community-sample.csv'),
        filename: 'test-teacher-week-1.csv',
        setIdFromFilename: 'test-teacher-week-1',
      );
      final duplicate = ParsedSet(
        id: 'vocab-set-01',
        title: 'Duplicate',
        description: 'Duplicate set',
        gradeLabel: 'Level 3',
        theme: 'Test',
        minGradeLevel: 'g1',
        maxGradeLevel: 'g1',
        words: communitySet.words,
        source: SetSource.community,
      );

      expect(
        () => validateSets([...defaultSets, duplicate]),
        throwsA(
          isA<VocabularyGeneratorException>().having(
            (error) => error.message,
            'message',
            contains('Duplicate set_id'),
          ),
        ),
      );
    });
  });

  group('loadAllSets', () {
    test('loads default and community fixtures together', () {
      final sets = loadAllSets(
        defaultCsvPathOverride: 'test/fixtures/vocabulary/default.csv',
        communityDirOverride: 'test/fixtures/vocabulary/community',
      );

      expect(sets, hasLength(3));
      expect(
        sets.where((set) => set.source == SetSource.defaultSet),
        hasLength(2),
      );
      expect(
        sets.where((set) => set.source == SetSource.community),
        hasLength(1),
      );
    });
  });
}

String _fixture(String name) {
  // Test fixtures live beside this file under test/fixtures/vocabulary/.
  return switch (name) {
    'default.csv' => '''
Word,Category,Meaning,Related Words,Grade,Difficulty,Set
Alpha,Instructional Language,First test word,one,1,easy,1
Beta,Mathematics,Second test word,two,2,medium,1
Gamma,Scientific Thinking,Third test word,three,3,hard,2
''',
    'community-sample.csv' => '''
# set_id,test-teacher-week-1
# title,Test Teacher Week 1
# teacher,Ms. Test
# school,Sample Elementary
# description,Fixture community set
# theme,Science
Word,Category,Meaning,Related Words,Grade,Difficulty
Delta,Instructional Language,Fourth test word,four,1,easy
''',
    'community-duplicate-id.csv' => '''
# set_id,vocab-set-99
# title,Reserved ID Set
Word,Category,Meaning,Related Words,Grade,Difficulty
Echo,Instructional Language,Fifth test word,five,1,easy
''',
    _ => throw StateError('Unknown fixture: $name'),
  };
}
