import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/word_progress.dart';
import '../state/app_controller.dart';
import '../utils/progress_helpers.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/speaker_button.dart';
import 'learn_words_screen.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  IconData _statusIcon(WordProgress progress, bool requireTyped) {
    if (isWordComplete(progress, requireTyped: requireTyped)) {
      return Icons.check_circle;
    }
    if (isWordPartiallyComplete(progress)) {
      return Icons.timelapse;
    }
    return Icons.circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final set = controller.selectedSet!;
    final progressMap = controller.getSelectedSetProgress();
    final requireTyped = controller.settings.requireTypeItForCompletion;
    final tts = controller.tts;

    return AppScaffold(
      title: 'Word List',
      subtitle: set.title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: ListView.separated(
        itemCount: set.words.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final word = set.words[index];
          final progress = getWordProgress(progressMap, word.id);
          return Card(
            child: ListTile(
              leading: Icon(_statusIcon(progress, requireTyped)),
              title: Text(word.word),
              subtitle: Text(
                word.definition,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: SpeakerButton(
                size: 40,
                onSpeak: () => tts.speak(word.word),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LearnWordsScreen(initialWordId: word.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
