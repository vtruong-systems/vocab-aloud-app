import 'package:flutter/material.dart';

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({
    super.key,
    required this.value,
    this.label,
    this.height = 12,
  });

  final double value;
  final String? label;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: height,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }
}
