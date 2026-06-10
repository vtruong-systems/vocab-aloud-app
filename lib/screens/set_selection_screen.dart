import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/vocabulary_sets.dart';
import '../models/grade_level.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../utils/grade_filter.dart';
import '../utils/progress_helpers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/home_icon_button.dart';
import '../widgets/profile_menu_button.dart';
import '../widgets/word_set_card.dart';

class SetSelectionScreen extends StatefulWidget {
  const SetSelectionScreen({super.key});

  @override
  State<SetSelectionScreen> createState() => _SetSelectionScreenState();
}

class _SetSelectionScreenState extends State<SetSelectionScreen> {
  GradeLevel? _levelFilter;
  SetLevelSort _sort = SetLevelSort.setNumber;

  Future<void> _openSet(BuildContext context, String setId) async {
    final controller = context.read<AppController>();
    await controller.selectSet(setId);
    if (!context.mounted) return;
    Navigator.pushNamed(context, AppRoutes.setDashboard);
  }

  Future<void> _continueRecent(BuildContext context) async {
    final controller = context.read<AppController>();
    final set = controller.selectedSet;
    if (set == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a word set first.')),
      );
      return;
    }
    if (!context.mounted) return;
    Navigator.pushNamed(context, AppRoutes.setDashboard);
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Set number'),
                trailing: _sort == SetLevelSort.setNumber
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() => _sort = SetLevelSort.setNumber);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Level (low to high)'),
                trailing: _sort == SetLevelSort.levelAsc
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() => _sort = SetLevelSort.levelAsc);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Level (high to low)'),
                trailing: _sort == SetLevelSort.levelDesc
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() => _sort = SetLevelSort.levelDesc);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final profileId = controller.state.activeProfileId;
    final profileProgress =
        profileId == null ? null : controller.state.profileProgress[profileId];
    final visibleSets = filterAndSortSets(
      vocabularySets,
      selectedLevel: _levelFilter,
      sort: _sort,
    );

    return AppScaffold(
      leading: const HomeIconButton(),
      actions: const [ProfileMenuButton()],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: visibleSets.isEmpty ? null : () => _continueRecent(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.learnBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
            ),
            child: const Text('Continue'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Level',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _showSortMenu(context),
                icon: const Icon(Icons.sort, size: 18),
                label: const Text('Sort'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: GradeLevel.values.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FilterChip(
                    label: const Text('All'),
                    selected: _levelFilter == null,
                    onSelected: (_) => setState(() => _levelFilter = null),
                  );
                }
                final level = GradeLevel.values[index - 1];
                return FilterChip(
                  label: Text(level.label),
                  selected: _levelFilter == level,
                  onSelected: (_) => setState(() => _levelFilter = level),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: visibleSets.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _levelFilter == null
                            ? 'No word sets available.'
                            : 'No word sets include ${ _levelFilter!.label}.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: visibleSets.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final set = visibleSets[index];
                      final setProgress =
                          profileProgress?.sets[set.id]?.wordProgress ?? {};
                      final stats = computeSetStats(
                        set,
                        setProgress,
                        requireTyped:
                            controller.settings.requireTypeItForCompletion,
                      );
                      return WordSetCard(
                        set: set,
                        stats: stats,
                        onStart: () => _openSet(context, set.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
