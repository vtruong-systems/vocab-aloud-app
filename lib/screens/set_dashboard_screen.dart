import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_branding.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../theme/app_theme.dart';
import '../utils/progress_helpers.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/practice_mode_button.dart';
import '../widgets/profile_app_bar_actions.dart';
import '../widgets/progress_bar_widget.dart';

class SetDashboardScreen extends StatelessWidget {
  const SetDashboardScreen({super.key});

  String? _hintFor(AppController controller, String mode) {
    final set = controller.selectedSet;
    if (set == null) return null;
    final progress = controller.getSelectedSetProgress();
    final hasUnreviewed = set.words.any(
      (word) => !getWordProgress(progress, word.id).reviewed,
    );
    if (hasUnreviewed) return mode == 'learn' ? 'Try this next' : null;
    final hasQuiz = set.words.any(
      (word) => !getWordProgress(progress, word.id).quizCorrect,
    );
    if (hasQuiz) return mode == 'quiz' ? 'Try this next' : null;
    final hasSpelling = set.words.any(
      (word) =>
          !word.isMultiWord &&
          !getWordProgress(progress, word.id).spellingCompleted,
    );
    if (hasSpelling) return mode == 'spell' ? 'Try this next' : null;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final profile = controller.activeProfile;
    final set = controller.selectedSet;
    final stats = controller.getSelectedSetStats();

    if (set == null || profile == null || stats == null) {
      return AppScaffold(
        title: appDisplayName,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        body: const Center(child: Text('No word set selected.')),
      );
    }

    return AppScaffold(
      title: set.title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: const [ProfileAppBarActions()],
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vocabulary: ${stats.masteredCount} / ${stats.totalWords}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ProgressBarWidget(value: stats.completionPercent),
                  const SizedBox(height: 12),
                  Text('Reviewed: ${stats.reviewedCount} / ${stats.totalWords}'),
                  Text('Quiz: ${stats.quizCount} / ${stats.totalWords}'),
                  Text(
                    'Spelling: ${stats.spellingCount} / ${stats.spellableCount}',
                  ),
                  Text('Typed: ${stats.typedCount} / ${stats.totalWords}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Vocabulary', style: Theme.of(context).textTheme.titleMedium),
          Text(
            'Hear the meaning. Reading the word is optional.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          PracticeModeButton(
            label: 'Learn Words',
            subtitle: 'Hear the word and its meaning',
            color: AppColors.learnBlue,
            hint: _hintFor(controller, 'learn'),
            onTap: () {
              controller.setLastMode(set.id, 'learn');
              Navigator.pushNamed(context, AppRoutes.learnWords);
            },
          ),
          const SizedBox(height: 10),
          PracticeModeButton(
            label: 'Quiz',
            subtitle: set.words.length < 2
                ? 'Needs at least two words'
                : 'Hear the meaning, pick the word',
            color: AppColors.quizGreen,
            hint: _hintFor(controller, 'quiz'),
            onTap: () {
              if (set.words.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quiz needs at least two words.'),
                  ),
                );
                return;
              }
              controller.setLastMode(set.id, 'quiz');
              Navigator.pushNamed(context, AppRoutes.quiz);
            },
          ),
          const SizedBox(height: 16),
          Text('Spelling', style: Theme.of(context).textTheme.titleMedium),
          Text(
            'Hear the word, then spell it.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          PracticeModeButton(
            label: 'Spell It',
            subtitle: 'Letter tiles',
            color: AppColors.spellPurple,
            hint: _hintFor(controller, 'spell'),
            onTap: () {
              controller.setLastMode(set.id, 'spell');
              Navigator.pushNamed(context, AppRoutes.spellIt);
            },
          ),
          const SizedBox(height: 10),
          PracticeModeButton(
            label: 'Type It',
            subtitle: 'Type the word you hear',
            color: AppColors.typeOrange,
            onTap: () {
              controller.setLastMode(set.id, 'type');
              Navigator.pushNamed(context, AppRoutes.typeIt);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.wordList),
                  child: const Text('Word List'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.progress),
                  child: const Text('Progress'),
                ),
              ),
            ],
          ),
          if (set.isDevice) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete this list?'),
                    content: const Text(
                      'This removes the list from this device. Progress for it is kept until you reset the profile.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !context.mounted) return;
                await controller.deleteDeviceSet(set.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Delete this list'),
            ),
          ],
        ],
      ),
    );
  }
}
