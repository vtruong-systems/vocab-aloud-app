import 'package:flutter/material.dart';

import '../models/grade_level.dart';

class GradeLevelPicker extends StatelessWidget {
  const GradeLevelPicker({
    super.key,
    required this.selected,
    required this.onSelected,
    this.includeAll = false,
  });

  final GradeLevel? selected;
  final ValueChanged<GradeLevel?> onSelected;
  final bool includeAll;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (includeAll)
          FilterChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
        for (final level in GradeLevel.values)
          FilterChip(
            label: Text(level.shortLabel),
            selected: selected == level,
            onSelected: (_) => onSelected(level),
          ),
      ],
    );
  }
}
