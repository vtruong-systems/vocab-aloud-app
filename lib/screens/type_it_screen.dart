import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_entry.dart';
import '../models/vocabulary_word.dart';
import '../state/app_controller.dart';
import '../utils/answer_normalize.dart';
import '../utils/session_completion.dart';
import '../utils/session_order.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/confetti_celebration.dart';
import '../widgets/speaker_button.dart';

class TypeItScreen extends StatefulWidget {
  const TypeItScreen({super.key});

  @override
  State<TypeItScreen> createState() => _TypeItScreenState();
}

class _TypeItScreenState extends State<TypeItScreen> {
  final _confettiKey = GlobalKey<ConfettiCelebrationState>();
  final Set<String> _missedWordIds = {};

  late List<VocabularyWord> _session;
  late final int _sessionWordCount;
  int _index = 0;
  final _controller = TextEditingController();
  int _wrongAttempts = 0;
  bool _showAnswer = false;
  String? _feedback;
  bool _wasCorrect = false;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();
    final set = app.selectedSet!;
    _session = buildTypeSession(set.words, app.getSelectedSetProgress());
    _sessionWordCount = _session.length;
  }

  @override
  void dispose() {
    _controller.dispose();
    context.read<AppController>().tts.stop();
    super.dispose();
  }

  VocabularyWord get _current => _session[_index];

  String? get _hint {
    if (_wrongAttempts < 2) return null;
    final word = _current.word;
    return 'Hint: starts with "${word[0].toUpperCase()}" and has ${word.length} letters.';
  }

  Future<void> _check() async {
    if (_advancing || _wasCorrect) return;
    final app = context.read<AppController>();
    final set = app.selectedSet!;
    final correct = answersMatch(_controller.text, _current.word);
    await app.markTypedAttempt(set.id, _current.id, correct: correct);

    if (correct) {
      setState(() => _wasCorrect = true);
      _confettiKey.currentState?.trigger();
      _advancing = true;
      await Future.delayed(kConfettiAutoAdvanceDelay);
      if (!mounted || !_wasCorrect) return;
      await _advance();
      return;
    }

    _missedWordIds.add(_current.id);
    setState(() {
      _wrongAttempts++;
      if (_wrongAttempts >= 3) _showAnswer = true;
      _feedback = 'Good try! The correct answer is: ${_current.word}';
    });
  }

  Future<void> _advance() async {
    final app = context.read<AppController>();
    final statsBefore = app.getSelectedSetStats();

    if (_index < _session.length - 1) {
      setState(() {
        _index++;
        _controller.clear();
        _wrongAttempts = 0;
        _showAnswer = false;
        _feedback = null;
        _wasCorrect = false;
        _advancing = false;
      });
      return;
    }

    if (!mounted) return;
    await showSessionCompletionAndExit(
      context: context,
      modeLabel: 'Type It',
      missedWords: missedWordsFromSession(_session, _missedWordIds),
      controller: app,
      statsBefore: statsBefore,
      activityType: ActivityType.typeIt,
      sessionWordCount: _sessionWordCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final tts = app.tts;
    final prompt = 'Type the word that means:\n"${_current.definition}"';
    final inputsLocked = _advancing || _wasCorrect;

    return ConfettiCelebration(
      key: _confettiKey,
      child: AppScaffold(
        title: 'Type It',
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
            TextField(
              controller: _controller,
              enabled: !inputsLocked,
              decoration: const InputDecoration(
                hintText: 'Type your answer here...',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: inputsLocked ? null : (_) => _check(),
            ),
            if (_hint != null) ...[
              const SizedBox(height: 8),
              Text(_hint!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (_showAnswer) ...[
              const SizedBox(height: 8),
              Text('Answer: ${_current.word}',
                  style: Theme.of(context).textTheme.titleMedium),
            ],
            if (_feedback != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(_feedback!),
                      SpeakerButton(onSpeak: () => tts.speak(_current.word)),
                    ],
                  ),
                ),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: inputsLocked ? null : _check,
              child: const Text('Check'),
            ),
            if (_feedback != null)
              TextButton(onPressed: _advance, child: const Text('Next word')),
          ],
        ),
      ),
    );
  }
}
