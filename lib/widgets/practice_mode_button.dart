import 'package:flutter/material.dart';

class PracticeModeButton extends StatelessWidget {
  const PracticeModeButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.hint,
  });

  final String label;
  final String? subtitle;
  final String? hint;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    if (hint != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        hint!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
