// ignore_for_file: avoid_print

import 'dart:io';

import 'vocabulary_generator.dart';

void main() {
  try {
    writeGeneratedCatalog();
    final sets = loadAllSets();
    final defaultCount =
        sets.where((set) => set.source == SetSource.defaultSet).length;
    final communityCount =
        sets.where((set) => set.source == SetSource.community).length;
    print(
      'Wrote ${sets.length} sets ($defaultCount default, $communityCount community) to $outputPath',
    );
  } on VocabularyGeneratorException catch (error) {
    stderr.writeln(error.message);
    exit(1);
  } catch (error) {
    stderr.writeln(error);
    exit(1);
  }
}
