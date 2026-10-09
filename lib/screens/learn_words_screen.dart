import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_entry.dart';
import '../models/vocabulary_word.dart';
import '../state/app_controller.dart';
import '../utils/session_order.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/speaker_button.dart';

class LearnWordsScreen extends StatefulWidget {
  const LearnWordsScreen({super.key, this.initialWordId});

  final String? initialWordId;

  @override
  State<LearnWordsScreen> createState() => _LearnWordsScreenState();
}

class _LearnWordsScreenState extends State<LearnWordsScreen> {
  late List<VocabularyWord> _session;
  late AppController _controller;
  int _index = 0;
  bool _markedCurrent = false;

  @override
  void initState() {
    super.initState();
    _controller = context.read<AppController>();
    _buildSession();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoRead());
  }

  void _buildSession() {
    final set = _controller.selectedSet!;
    final progress = _controller.getSelectedSetProgress();
    _session = buildLearnSession(set.words, progress);
    if (widget.initialWordId != null) {
      final startIndex = _session.indexWhere(
        (word) => word.id == widget.initialWordId,
      );
      if (startIndex >= 0) _index = startIndex;
    }
  }

  @override
  void dispose() {
    _controller.tts.stop();
    super.dispose();
  }

  Future<void> _markReviewed() async {
    if (_markedCurrent) return;
    final set = _controller.selectedSet;
    if (set == null || _session.isEmpty) return;
    final word = _session[_index];
    await _controller.markReviewed(set.id, word.id);
    _markedCurrent = true;
  }

  void _goTo(int newIndex) {
    setState(() {
      _index = newIndex;
      _markedCurrent = false;
    });
    _maybeAutoRead();
  }

  void _maybeAutoRead() {
    if (_session.isEmpty) return;
    final settings = context.read<AppController>().settings;
    if (!settings.autoReadLearnWord) return;
    final word = _session[_index];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppController>().tts.speakSequence([
        word.word,
        word.definition,
        word.exampleSentence,
      ]);
    });
  }

  Future<void> _next() async {
    await _markReviewed();
    if (_index < _session.length - 1) {
      _goTo(_index + 1);
    } else if (mounted) {
      final set = _controller.selectedSet;
      if (set != null) {
        await _controller.logActivity(
          type: ActivityType.learnWords,
          setId: set.id,
          setTitle: set.title,
          correctCount: _session.length,
          totalCount: _session.length,
        );
      }
      if (mounted) Navigator.pop(context);
    }
  }

  void _previous() {
    if (_index > 0) _goTo(_index - 1);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final word = _session[_index];
    final tts = controller.tts;
    return AppScaffold(
      title: 'Learn Words',
      subtitle: '${_index + 1} / ${_session.length}',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            word.word,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          const SizedBox(height: 12),
                          SpeakerButton(onSpeak: () => tts.speak(word.word)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            word.definition,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          SpeakerButton(
                            onSpeak: () => tts.speak(word.definition),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            word.exampleSentence,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          SpeakerButton(
                            onSpeak: () => tts.speak(word.exampleSentence),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _index > 0 ? _previous : null,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(_index < _session.length - 1 ? 'Next' : 'Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
