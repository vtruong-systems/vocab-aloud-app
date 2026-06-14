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

  String? _nextModeHint(AppController controller) {
    final set = controller.selectedSet;
    if (set == null) return null;
    final progress = controller.getSelectedSetProgress();
    final hasUnreviewed = set.words.any(
      (word) => !getWordProgress(progress, word.id).reviewed,
    );
    if (hasUnreviewed) return 'Try this next';
    final hasQuiz = set.words.any(
      (word) => !getWordProgress(progress, word.id).quizCorrect,
    );
    if (hasQuiz) return 'Try this next';
    final hasSpelling = set.words.any(
      (word) =>
          !word.isMultiWord &&
          !getWordProgress(progress, word.id).spellingCompleted,
    );
    if (hasSpelling) return 'Try this next';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final profile = controller.activeProfile;
    final set = controller.selectedSet;
    final stats = controller.getSelectedSetStats();
    final hint = _nextModeHint(controller);

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.masteredCount} / ${stats.totalWords} words mastered',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ProgressBarWidget(value: stats.completionPercent),
                  const SizedBox(height: 12),
                  Text('Reviewed: ${stats.reviewedCount} / ${stats.totalWords}'),
                  Text('Quiz: ${stats.quizCount} / ${stats.totalWords}'),
                  Text('Spelling: ${stats.spellingCount} / ${stats.totalWords}'),
                  Text('Typed: ${stats.typedCount} / ${stats.totalWords}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PracticeModeButton(
            label: 'Learn Words',
            color: AppColors.learnBlue,
            hint: hint,
            onTap: () {
              controller.setLastMode(set.id, 'learn');
              Navigator.pushNamed(context, AppRoutes.learnWords);
            },
          ),
          const SizedBox(height: 10),
          PracticeModeButton(
            label: 'Quiz',
            subtitle: 'Multiple Choice',
            color: AppColors.quizGreen,
            onTap: () {
              controller.setLastMode(set.id, 'quiz');
              Navigator.pushNamed(context, AppRoutes.quiz);
            },
          ),
          const SizedBox(height: 10),
          PracticeModeButton(
            label: 'Spell It',
            subtitle: 'Drag & Drop',
            color: AppColors.spellPurple,
            onTap: () {
              controller.setLastMode(set.id, 'spell');
              Navigator.pushNamed(context, AppRoutes.spellIt);
            },
          ),
          const SizedBox(height: 10),
          PracticeModeButton(
            label: 'Type It',
            subtitle: 'Write Answer',
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
        ],
      ),
    );
  }
}
