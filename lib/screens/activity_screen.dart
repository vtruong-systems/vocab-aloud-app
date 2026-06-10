import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../utils/activity_helpers.dart';
import '../widgets/app_scaffold.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final profile = controller.activeProfile;
    final entries = controller.activityLog;

    if (profile == null) {
      return AppScaffold(
        title: 'Activity',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        body: const Center(child: Text('No profile selected.')),
      );
    }

    final subtitle =
        '${profile.displayName} ${profile.avatarEmoji ?? presetEmojis.first}';

    return AppScaffold(
      title: 'Activity',
      subtitle: subtitle,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: entries.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No activity yet. Finish a practice session to see it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    title: Text(formatActivitySummary(entry)),
                    subtitle: Text(
                      formatLocalDateTime(entry.completedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
