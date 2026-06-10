import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/credits_footer_link.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
    final settings = controller.settings;

    return AppScaffold(
      title: 'Settings',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Speech speed'),
                  subtitle: DropdownButton<SpeechSpeed>(
                    isExpanded: true,
                    value: settings.speechSpeed,
                    items: SpeechSpeed.values
                        .map(
                          (speed) => DropdownMenuItem(
                            value: speed,
                            child: Text(speed.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      controller.updateSettings(
                        settings.copyWith(speechSpeed: value),
                      );
                    },
                  ),
                ),
                SwitchListTile(
                  title: const Text('Auto-read word on Learn screen'),
                  value: settings.autoReadLearnWord,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(autoReadLearnWord: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Auto-read definition in quiz'),
                  value: settings.autoReadQuizDefinition,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(autoReadQuizDefinition: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Require Type It for completion'),
                  value: settings.requireTypeItForCompletion,
                  onChanged: (value) => controller.updateSettings(
                    settings.copyWith(requireTypeItForCompletion: value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Manage Profiles'),
                  subtitle: Text(
                    controller.activeProfile?.displayName ?? 'No active profile',
                  ),
                ),
                ListTile(
                  title: const Text('Switch profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.profileSelection,
                    );
                  },
                ),
                ListTile(
                  title: const Text('Add profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.createProfile);
                  },
                ),
                ListTile(
                  title: const Text('Edit profiles'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.editProfile);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _resetAll(context),
            child: const Text('Reset all progress for active profile'),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              title: Text('About'),
              subtitle: Text('Vocabulary Practice v1.0\nLocal-only kids vocab app.'),
            ),
          ),
          const CreditsFooterLink(),
        ],
      ),
    );
  }
}
