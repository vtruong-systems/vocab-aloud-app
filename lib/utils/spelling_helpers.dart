import 'dart:math';

import '../models/letter_tile.dart';

const _distractorLetters = 'abcdefghijklmnopqrstuvwxyz';

List<LetterTile> buildLetterTiles(String word) {
  final normalized = word.toLowerCase().replaceAll(' ', '');
  final tiles = <LetterTile>[];
  for (var i = 0; i < normalized.length; i++) {
    tiles.add(LetterTile(id: 'target-$i-${normalized[i]}', letter: normalized[i]));
  }

  final distractorCount = _distractorCount(normalized.length);
  final used = normalized.split('').toSet();
  final random = Random();
  var added = 0;
  while (added < distractorCount) {
    final letter = _distractorLetters[random.nextInt(_distractorLetters.length)];
    tiles.add(LetterTile(id: 'extra-$added-$letter', letter: letter));
    used.add(letter);
    added++;
  }

  tiles.shuffle(random);
  return tiles;
}

int _distractorCount(int length) {
  if (length <= 4) return 3;
  if (length <= 7) return 2;
  return 1;
}

String slotsToWord(List<String?> slots) => slots.join();

bool isSpellingCorrect(List<String?> slots, String targetWord) {
  return slotsToWord(slots) == targetWord.toLowerCase().replaceAll(' ', '');
}
