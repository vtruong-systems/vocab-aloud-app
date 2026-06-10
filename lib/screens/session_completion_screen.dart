import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/vocabulary_word.dart';
import '../state/app_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/speaker_button.dart';

class SessionCompletionScreen extends StatelessWidget {
  const SessionCompletionScreen({
    super.key,
    required this.modeLabel,
    required this.missedWords,
    required this.onDone,
  });

  final String modeLabel;
  final List<VocabularyWord> missedWords;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final tts = context.read<AppController>().tts;
    final missedCount = missedWords.length;

    return AppScaffold(
      title: 'Great job!',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.celebration, size: 72, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'Great job!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'You finished $modeLabel!',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: missedCount == 0
                    ? Center(
                        child: Text(
                          'You got every word right!',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '$missedCount word${missedCount == 1 ? '' : 's'} to practice:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.separated(
                              itemCount: missedWords.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final word = missedWords[index];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        word.word,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    SpeakerButton(
                                      onSpeak: () => tts.speak(word.word),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onDone, child: const Text('Done')),
        ],
      ),
    );
  }
}
