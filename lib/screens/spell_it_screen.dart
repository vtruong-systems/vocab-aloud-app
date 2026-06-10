import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_entry.dart';
import '../models/letter_tile.dart';
import '../models/vocabulary_word.dart';
import '../state/app_controller.dart';
import '../utils/session_completion.dart';
import '../utils/session_order.dart';
import '../utils/spelling_helpers.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/confetti_celebration.dart';
import '../widgets/speaker_button.dart';

class SpellItScreen extends StatefulWidget {
  const SpellItScreen({super.key});

  @override
  State<SpellItScreen> createState() => _SpellItScreenState();
}

class _SpellItScreenState extends State<SpellItScreen> {
  final _confettiKey = GlobalKey<ConfettiCelebrationState>();
  final Set<String> _missedWordIds = {};

  late List<VocabularyWord> _session;
  late final int _sessionWordCount;
  int _index = 0;
  List<LetterTile> _tiles = [];
  List<String?> _slots = [];
  String? _feedback;
  bool? _wasCorrect;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    final controller = context.read<AppController>();
    final set = controller.selectedSet!;
    _session = buildSpellingSession(set.words, controller.getSelectedSetProgress());
    _sessionWordCount = _session.length;
    _setupWord();
  }

  void _setupWord() {
    final word = _session[_index];
    _tiles = buildLetterTiles(word.word);
    _slots = List<String?>.filled(
      word.word.toLowerCase().replaceAll(' ', '').length,
      null,
    );
    _feedback = null;
    _wasCorrect = null;
    _advancing = false;
  }

  @override
  void dispose() {
    context.read<AppController>().tts.stop();
    super.dispose();
  }

  LetterTile? _tileForSlot(int slotIndex) {
    for (final tile in _tiles) {
      if (tile.placedInSlot == slotIndex) return tile;
    }
    return null;
  }

  List<LetterTile> get _availableTiles =>
      _tiles.where((tile) => tile.placedInSlot == null).toList();

  static const _maxSlotWidth = 44.0;
  static const _maxSlotHeight = 52.0;
  static const _maxSlotFontSize = 22.0;
  static const _minSlotWidth = 30.0;

  ({double width, double height, double fontSize, double spacing}) _slotLayout(
    double maxWidth,
    int slotCount,
  ) {
    if (slotCount <= 0) {
      return (
        width: _maxSlotWidth,
        height: _maxSlotHeight,
        fontSize: _maxSlotFontSize,
        spacing: 8.0,
      );
    }

    var spacing = 8.0;
    var width = (maxWidth - (slotCount - 1) * spacing) / slotCount;
    if (width < _minSlotWidth) {
      spacing = 4.0;
      width = (maxWidth - (slotCount - 1) * spacing) / slotCount;
    }
    width = width.clamp(_minSlotWidth, _maxSlotWidth);
    final scale = width / _maxSlotWidth;
    return (
      width: width,
      height: _maxSlotHeight * scale,
      fontSize: _maxSlotFontSize * scale,
      spacing: spacing,
    );
  }

  void _placeTile(LetterTile tile, int slotIndex) {
    if (_slots[slotIndex] != null || _advancing) return;
    setState(() {
      final tileIndex = _tiles.indexWhere((item) => item.id == tile.id);
      _tiles[tileIndex] = tile.copyWith(placedInSlot: slotIndex);
      _slots[slotIndex] = tile.letter;
    });
  }

  void _removeFromSlot(int slotIndex) {
    if (_advancing) return;
    final tile = _tileForSlot(slotIndex);
    if (tile == null) return;
    setState(() {
      final tileIndex = _tiles.indexWhere((item) => item.id == tile.id);
      _tiles[tileIndex] = tile.copyWith(clearSlot: true);
      _slots[slotIndex] = null;
    });
  }

  void _clear() {
    if (_advancing) return;
    setState(_setupWord);
  }

  Future<void> _check() async {
    if (_advancing || _wasCorrect == true) return;
    final controller = context.read<AppController>();
    final set = controller.selectedSet!;
    final word = _session[_index];
    final correct = isSpellingCorrect(_slots, word.word);
    await controller.markSpellingAttempt(set.id, word.id, correct: correct);

    if (!correct) {
      _missedWordIds.add(word.id);
      setState(() {
        _wasCorrect = false;
        _feedback = 'Good try! The correct answer is: ${word.word}';
      });
      return;
    }

    setState(() => _wasCorrect = true);
    _confettiKey.currentState?.trigger();
    _advancing = true;
    await Future.delayed(kConfettiAutoAdvanceDelay);
    if (!mounted || _wasCorrect != true) return;
    await _advance();
  }

  Future<void> _advance() async {
    final controller = context.read<AppController>();
    final statsBefore = controller.getSelectedSetStats();

    if (_index < _session.length - 1) {
      setState(() {
        _index++;
        _setupWord();
      });
      return;
    }

    if (!mounted) return;
    await showSessionCompletionAndExit(
      context: context,
      modeLabel: 'Spell It',
      missedWords: missedWordsFromSession(_session, _missedWordIds),
      controller: controller,
      statsBefore: statsBefore,
      activityType: ActivityType.spellIt,
      sessionWordCount: _sessionWordCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isEmpty) {
      return AppScaffold(
        title: 'Spell It',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        body: const Center(
          child: Text('No single-word spelling items in this set.'),
        ),
      );
    }

    final controller = context.watch<AppController>();
    final tts = controller.tts;
    final word = _session[_index];
    final prompt =
        'Spell the word that means:\n"${word.definition}"';
    final inputsLocked = _advancing || _wasCorrect == true;

    return ConfettiCelebration(
      key: _confettiKey,
      child: AppScaffold(
        title: 'Spell It',
        subtitle: '${_index + 1} / ${_session.length}',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(prompt, style: Theme.of(context).textTheme.bodyLarge),
                    SpeakerButton(onSpeak: () => tts.speak(prompt)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final layout = _slotLayout(constraints.maxWidth, _slots.length);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slots.length, (slotIndex) {
                    final letter = _slots[slotIndex];
                    final isLast = slotIndex == _slots.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: isLast ? 0 : layout.spacing,
                      ),
                      child: InkWell(
                        onTap: inputsLocked
                            ? null
                            : () => _removeFromSlot(slotIndex),
                        child: Container(
                          width: layout.width,
                          height: layout.height,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade400,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            letter ?? '_',
                            style: TextStyle(fontSize: layout.fontSize),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _availableTiles.map((tile) {
                  final nextSlot = _slots.indexWhere((slot) => slot == null);
                  return InkWell(
                    onTap: inputsLocked || nextSlot == -1
                        ? null
                        : () => _placeTile(tile, nextSlot),
                    child: Draggable<LetterTile>(
                      data: tile,
                      feedback: _letterChip(tile.letter, dragging: true),
                      childWhenDragging: Opacity(
                        opacity: 0.4,
                        child: _letterChip(tile.letter),
                      ),
                      onDragEnd: (_) {},
                      child: DragTarget<LetterTile>(
                        onAcceptWithDetails: inputsLocked
                            ? null
                            : (details) {
                                final slot =
                                    _slots.indexWhere((s) => s == null);
                                if (slot != -1) _placeTile(details.data, slot);
                              },
                        builder: (context, candidate, rejected) =>
                            _letterChip(tile.letter),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_feedback != null && _wasCorrect == false)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(_feedback!),
                      SpeakerButton(onSpeak: () => tts.speak(word.word)),
                    ],
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: inputsLocked ? null : _clear,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: inputsLocked ? null : _check,
                    child: const Text('Check'),
                  ),
                ),
              ],
            ),
            if (_wasCorrect == false)
              TextButton(onPressed: _advance, child: const Text('Next word')),
          ],
        ),
      ),
    );
  }

  Widget _letterChip(String letter, {bool dragging = false}) {
    return Material(
      elevation: dragging ? 6 : 1,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.purple.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(letter, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
