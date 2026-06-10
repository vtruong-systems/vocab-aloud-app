import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vocabulary_word.dart';
import '../state/app_controller.dart';
import '../utils/session_completion.dart';
import '../utils/session_order.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/confetti_celebration.dart';
import '../widgets/speaker_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _confettiKey = GlobalKey<ConfettiCelebrationState>();
  final Set<String> _missedWordIds = {};

  late List<VocabularyWord> _session;
  int _index = 0;
  List<VocabularyWord> _choices = [];
  String? _selectedId;
  bool _answered = false;
  bool _wasCorrect = false;
  bool _advancing = false;

  @override
  void initState() {
    super.initState();
    _initSession();
  }

  void _initSession() {
    final controller = context.read<AppController>();
    final set = controller.selectedSet!;
    _session = buildQuizSession(set.words, controller.getSelectedSetProgress());
    _loadQuestion();
  }

  void _loadQuestion() {
    final controller = context.read<AppController>();
    final set = controller.selectedSet!;
    final word = _session[_index];
    _choices = buildQuizChoices(correct: word, allWords: set.words);
    _selectedId = null;
    _answered = false;
    _wasCorrect = false;
    _advancing = false;

    if (controller.settings.autoReadQuizDefinition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.tts.speak('What word means: ${word.definition}');
      });
    }
  }

  @override
  void dispose() {
    context.read<AppController>().tts.stop();
    super.dispose();
  }

  String get _prompt => 'What word means:\n"${_session[_index].definition}"';

  Future<void> _selectAnswer(VocabularyWord choice) async {
    if (_answered || _advancing) return;
    final controller = context.read<AppController>();
    final set = controller.selectedSet!;
    final current = _session[_index];
    final correct = choice.id == current.id;

    setState(() {
      _selectedId = choice.id;
      _answered = true;
      _wasCorrect = correct;
    });

    await controller.markQuizAttempt(set.id, current.id, correct: correct);
    if (!correct) {
      _missedWordIds.add(current.id);
      requeueMissedWord(_session, _index, current);
      return;
    }

    _confettiKey.currentState?.trigger();
    _advancing = true;
    await Future.delayed(kConfettiAutoAdvanceDelay);
    if (!mounted || !_wasCorrect) return;
    await _advance();
  }

  Future<void> _next() async {
    if (_advancing) return;
    await _advance();
  }

  Future<void> _advance() async {
    final controller = context.read<AppController>();
    final statsBefore = controller.getSelectedSetStats();

    if (_index < _session.length - 1) {
      setState(() {
        _index++;
        _loadQuestion();
      });
      return;
    }

    if (!mounted) return;
    await showSessionCompletionAndExit(
      context: context,
      modeLabel: 'the quiz',
      missedWords: missedWordsFromSession(_session, _missedWordIds),
      controller: controller,
      statsBefore: statsBefore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final tts = controller.tts;
    final current = _session[_index];

    return ConfettiCelebration(
      key: _confettiKey,
      child: AppScaffold(
        title: 'Quiz',
        subtitle: 'Question ${_index + 1} / ${_session.length}',
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
                    Text(_prompt, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    SpeakerButton(onSpeak: () => tts.speak(_prompt)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _choices.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final choice = _choices[index];
                  Color? bg;
                  if (_answered) {
                    if (choice.id == current.id) {
                      bg = Colors.green.shade100;
                    } else if (choice.id == _selectedId) {
                      bg = Colors.orange.shade100;
                    }
                  }

                  return Card(
                    color: bg,
                    child: ListTile(
                      title: Text(choice.word,
                          style: Theme.of(context).textTheme.titleMedium),
                      trailing: SpeakerButton(
                        size: 40,
                        onSpeak: () => tts.speak(choice.word),
                      ),
                      onTap: _answered || _advancing
                          ? null
                          : () => _selectAnswer(choice),
                    ),
                  );
                },
              ),
            ),
            if (_answered && !_wasCorrect)
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text('Good try!',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('The correct answer is: ${current.word}'),
                      SpeakerButton(onSpeak: () => tts.speak(current.word)),
                    ],
                  ),
                ),
              ),
            if (_answered && !_wasCorrect)
              ElevatedButton(onPressed: _next, child: const Text('Next')),
          ],
        ),
      ),
    );
  }
}
