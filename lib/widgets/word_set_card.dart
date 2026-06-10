import 'package:flutter/material.dart';

import '../models/vocabulary_set.dart';
import '../models/vocabulary_word.dart';
import '../theme/app_theme.dart';
import '../utils/grade_filter.dart';
import '../utils/progress_helpers.dart';
import 'progress_bar_widget.dart';

class WordSetCard extends StatefulWidget {
  const WordSetCard({
    super.key,
    required this.set,
    required this.stats,
    required this.onStart,
  });

  final VocabularySet set;
  final SetStats stats;
  final VoidCallback onStart;

  @override
  State<WordSetCard> createState() => _WordSetCardState();
}

class _WordSetCardState extends State<WordSetCard> {
  bool _expanded = false;

  Widget _buildWordColumn(List<VocabularyWord> words) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: words
          .map(
            (word) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                word.word,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTwoColumnWordList() {
    final words = widget.set.words;
    final splitAt = (words.length + 1) ~/ 2;
    final leftWords = words.sublist(0, splitAt);
    final rightWords = words.sublist(splitAt);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildWordColumn(leftWords)),
            const SizedBox(width: 12),
            Expanded(child: _buildWordColumn(rightWords)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordLabel = widget.stats.totalWords == 1 ? 'word' : 'words';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.set.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  if (widget.set.teacher != null || widget.set.school != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (widget.set.teacher != null) widget.set.teacher,
                        if (widget.set.school != null) widget.set.school,
                      ].join(' · '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${widget.set.theme} · ${formatSetLevelLabel(widget.set)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.stats.totalWords} $wordLabel',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.stats.completedSteps} / ${widget.stats.totalSteps} complete',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  ProgressBarWidget(value: widget.stats.completionPercent),
                  const SizedBox(height: 8),
                  Text(
                    widget.stats.statusLabel,
                    style: TextStyle(
                      color: widget.stats.statusLabel == 'Complete'
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: ElevatedButton(
              onPressed: widget.onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.learnBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Start'),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Words in this set',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildTwoColumnWordList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
