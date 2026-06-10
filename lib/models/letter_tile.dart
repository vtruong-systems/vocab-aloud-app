class LetterTile {
  const LetterTile({
    required this.id,
    required this.letter,
    this.placedInSlot,
  });

  final String id;
  final String letter;
  final int? placedInSlot;

  LetterTile copyWith({int? placedInSlot, bool clearSlot = false}) {
    return LetterTile(
      id: id,
      letter: letter,
      placedInSlot: clearSlot ? null : (placedInSlot ?? this.placedInSlot),
    );
  }
}
