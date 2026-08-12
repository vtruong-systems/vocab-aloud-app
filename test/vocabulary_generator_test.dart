import 'dart:io';

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
      expect(
        sets[0].words.first.exampleSentence,
        'Alpha has a curated sentence.',
      );
      expect(sets[1].id, 'vocab-set-02');
      expect(sets[1].words.single.word, 'Gamma');
    });

    test('parses weekly spelling CSV with quoted commas', () {
      final sets = parseDefaultCsv(_fixture('spelling-default.csv'));

      expect(sets, hasLength(2));
      expect(sets[0].id, 'grade-1-spelling-week-01');
      expect(sets[0].title, 'Grade 1 Spelling Week 1');
      expect(sets[0].words.first.meaning, 'A pet, often with soft fur');
      expect(sets[0].words.first.exampleSentence, 'The cat naps, then runs.');
      expect(sets[1].id, 'grade-2-spelling-week-01');
      expect(sets[1].words.single.difficulty, 'medium');
    });

    test('loads all five grades and 36 weeks from the default catalog', () {
      final sets = parseDefaultCsv(File(defaultCsvPath).readAsStringSync());

      expect(sets, hasLength(180));
      for (var grade = 1; grade <= 5; grade++) {
        expect(
          sets.where((set) => set.id.startsWith('grade-$grade-')),
          hasLength(36),
        );
      }
      expect(
        sets
            .where((set) => set.id.startsWith('grade-1-'))
            .expand((set) => set.words),
        hasLength(288),
      );
      expect(
        sets
            .where((set) => set.id.startsWith('grade-5-'))
            .expand((set) => set.words),
        hasLength(720),
      );
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
      expect(set.words.single.meaning, 'Fourth test word, with a comma');
      expect(set.words.single.exampleSentence, 'Delta is here, too.');
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

    test('loads reorganized default and Truong community catalogs', () {
      final sets = loadAllSets();

      expect(
        sets.where((set) => set.source == SetSource.defaultSet),
        hasLength(180),
      );
      final communitySets = sets
          .where((set) => set.source == SetSource.community)
          .toList();
      expect(communitySets, hasLength(46));
      expect(
        communitySets.every((set) => set.id.startsWith('truong-')),
        isTrue,
      );
    });
  });

  group('generateDartSource', () {
    test('uses curated default and community examples', () {
      final defaultSets = parseDefaultCsv(_fixture('default.csv'));
      final communitySet = parseCommunityCsv(
        _fixture('community-sample.csv'),
        filename: 'test-teacher-week-1.csv',
        setIdFromFilename: 'test-teacher-week-1',
      );

      final source = generateDartSource([...defaultSets, communitySet]);

      expect(
        source,
        contains("exampleSentence: 'Alpha has a curated sentence.'"),
      );
      expect(source, contains("exampleSentence: 'Delta is here, too.'"));
    });
  });
}

String _fixture(String name) {
  // Test fixtures live beside this file under test/fixtures/vocabulary/.
  return switch (name) {
    'default.csv' =>
      '''
Word,Category,Meaning,Related Words,Grade,Difficulty,Example Sentence,Set
Alpha,Instructional Language,First test word,one,1,easy,Alpha has a curated sentence.,1
Beta,Mathematics,Second test word,two,2,medium,Beta has a curated sentence.,1
Gamma,Scientific Thinking,Third test word,three,3,hard,Gamma has a curated sentence.,2
''',
    'spelling-default.csv' =>
      '''
word,grade,set (week),definition,sentence
cat,1,1,"A pet, often with soft fur","The cat naps, then runs."
bright,2,1,Full of light,The sun is bright.
''',
    'community-sample.csv' =>
      '''
# set_id,test-teacher-week-1
# title,Test Teacher Week 1
# teacher,Ms. Test
# school,Sample Elementary
# description,Fixture community set
# theme,Science
Word,Category,Meaning,Related Words,Grade,Difficulty,Example Sentence
Delta,Instructional Language,"Fourth test word, with a comma",four,1,easy,"Delta is here, too."
''',
    'community-duplicate-id.csv' =>
      '''
# set_id,vocab-set-99
# title,Reserved ID Set
Word,Category,Meaning,Related Words,Grade,Difficulty
Echo,Instructional Language,Fifth test word,five,1,easy
''',
    _ => throw StateError('Unknown fixture: $name'),
  };
}
