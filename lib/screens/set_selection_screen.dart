import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/vocabulary_sets.dart';
import '../models/grade_level.dart';
import '../models/profile_progress.dart';
import '../models/vocabulary_set.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../utils/grade_filter.dart';
import '../utils/progress_helpers.dart';
import '../utils/set_search.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/credits_footer_link.dart';
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
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  List<VocabularySet> _visibleSets() {
    final filtered = filterAndSortSets(
      vocabularySets,
      selectedLevel: _levelFilter,
      sort: _sort,
    );
    return filterSetsByQuery(filtered, _searchQuery);
  }

  Widget _buildSetCard(
    BuildContext context,
    AppController controller,
    ProfileProgress? profileProgress,
    VocabularySet set,
  ) {
    final setProgress =
        profileProgress?.sets[set.id]?.wordProgress ?? {};
    final stats = computeSetStats(
      set,
      setProgress,
      requireTyped: controller.settings.requireTypeItForCompletion,
    );
    return WordSetCard(
      set: set,
      stats: stats,
      onStart: () => _openSet(context, set.id),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.black54,
            ),
      ),
    );
  }

  Widget _buildSetList(
    BuildContext context,
    AppController controller,
    ProfileProgress? profileProgress,
    List<VocabularySet> visibleSets,
  ) {
    if (visibleSets.isEmpty) {
      final hasSearch = _searchQuery.trim().isNotEmpty;
      final message = hasSearch
          ? 'No word sets match your search.'
          : _levelFilter == null
              ? 'No word sets available.'
              : 'No word sets include ${_levelFilter!.label}.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final showSections = _searchQuery.trim().isEmpty &&
        hasCommunitySets(visibleSets);

    if (!showSections) {
      return ListView.separated(
        itemCount: visibleSets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _buildSetCard(
            context,
            controller,
            profileProgress,
            visibleSets[index],
          );
        },
      );
    }

    final defaults = defaultSets(visibleSets);
    final community = communitySets(visibleSets);

    return ListView(
      children: [
        if (defaults.isNotEmpty) ...[
          _buildSectionHeader(context, 'Default Sets'),
          const SizedBox(height: 8),
          for (var i = 0; i < defaults.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildSetCard(context, controller, profileProgress, defaults[i]),
          ],
          const SizedBox(height: 16),
        ],
        if (community.isNotEmpty) ...[
          _buildSectionHeader(context, 'Teacher Sets'),
          const SizedBox(height: 8),
          for (var i = 0; i < community.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildSetCard(context, controller, profileProgress, community[i]),
          ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final profileId = controller.state.activeProfileId;
    final profileProgress =
        profileId == null ? null : controller.state.profileProgress[profileId];
    final visibleSets = _visibleSets();

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
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search sets, teachers, schools...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              isDense: true,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
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
            child: _buildSetList(
              context,
              controller,
              profileProgress,
              visibleSets,
            ),
          ),
          const CreditsFooterLink(),
        ],
      ),
    );
  }
}
