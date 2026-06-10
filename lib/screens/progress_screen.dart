import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../utils/progress_helpers.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/progress_bar_widget.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  Future<void> _resetSet(BuildContext context) async {
    final controller = context.read<AppController>();
    final profile = controller.activeProfile;
    final set = controller.selectedSet;
    if (profile == null || set == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset progress for this set?'),
        content: Text(
          "This will erase ${profile.displayName}'s progress for this word set on this device.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.resetSet(set.id);
    }
  }

  Future<void> _resetAll(BuildContext context) async {
    final controller = context.read<AppController>();
    final profile = controller.activeProfile;
    if (profile == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset all progress for ${profile.displayName}?'),
        content: Text(
          "This will erase all of ${profile.displayName}'s local progress on this device.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.resetAllForActiveProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final profile = controller.activeProfile;
    final set = controller.selectedSet;
    final stats = controller.getSelectedSetStats();
    final progressMap = controller.getSelectedSetProgress();
    final requireTyped = controller.settings.requireTypeItForCompletion;

    if (profile == null || set == null || stats == null) {
      return AppScaffold(
        title: 'Your Progress',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        body: const Center(child: Text('No progress to show.')),
      );
    }

    return AppScaffold(
      title: 'Your Progress',
      subtitle: '${profile.displayName} · ${set.title}',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Words Mastered: ${stats.masteredCount} / ${stats.totalWords}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ProgressBarWidget(value: stats.completionPercent),
                  const SizedBox(height: 16),
                  Text('Reviewed: ${stats.reviewedCount} / ${stats.totalWords}'),
                  Text('Quiz passed: ${stats.quizCount} / ${stats.totalWords}'),
                  Text('Spelling done: ${stats.spellingCount} / ${stats.totalWords}'),
                  Text('Typed: ${stats.typedCount} / ${stats.totalWords}'),
                  if (stats.quizAccuracyPercent != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Quiz accuracy: ${stats.quizAccuracyPercent}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...set.words.map((word) {
            final progress = getWordProgress(progressMap, word.id);
            final complete =
                isWordComplete(progress, requireTyped: requireTyped);
            final partial = isWordPartiallyComplete(progress);
            final icon = complete
                ? Icons.check_circle
                : partial
                    ? Icons.timelapse
                    : Icons.circle_outlined;
            return Card(
              child: ListTile(
                leading: Icon(icon),
                title: Text(word.word),
                subtitle: Text(
                  [
                    if (progress.reviewed) 'Reviewed',
                    if (progress.quizCorrect) 'Quiz',
                    if (progress.spellingCompleted) 'Spelling',
                    if (progress.typedCompleted) 'Typed',
                  ].join(' · '),
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _resetSet(context),
            child: const Text('Reset this set'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => _resetAll(context),
            child: const Text('Reset all progress'),
          ),
        ],
      ),
    );
  }
}
