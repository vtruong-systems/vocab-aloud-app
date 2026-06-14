import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/profile_emoji_picker.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  Future<void> _renameProfile(
    BuildContext context,
    AppController controller,
    String profileId,
    String currentName,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final textController = TextEditingController(text: currentName);
        return AlertDialog(
          title: const Text('Rename profile'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, textController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      await controller.renameProfile(profileId, result);
    }
  }

  Future<void> _changeIcon(
    BuildContext context,
    AppController controller,
    String profileId,
    String currentEmoji,
  ) async {
    var selectedEmoji = currentEmoji;
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Change icon'),
              content: ProfileEmojiPicker(
                selectedEmoji: selectedEmoji,
                onEmojiSelected: (emoji) {
                  setDialogState(() => selectedEmoji = emoji);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, selectedEmoji),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await controller.updateProfileEmoji(profileId, result);
    }
  }

  Future<void> _deleteProfile(
    BuildContext context,
    AppController controller,
    String profileId,
    String displayName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete $displayName's profile?"),
        content: Text(
          "This will erase $displayName's local progress on this device.",
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

    if (confirmed == true) {
      await controller.deleteProfile(profileId);
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return AppScaffold(
      title: 'Edit Profiles',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: ListView.separated(
        itemCount: controller.profiles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final profile = controller.profiles[index];
          return Card(
            child: ListTile(
              leading: Text(profile.avatarEmoji ?? presetEmojis.first,
                  style: const TextStyle(fontSize: 28)),
              title: Text(profile.displayName),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'rename') {
                    await _renameProfile(
                      context,
                      controller,
                      profile.id,
                      profile.displayName,
                    );
                  } else if (value == 'change_icon') {
                    await _changeIcon(
                      context,
                      controller,
                      profile.id,
                      profile.avatarEmoji ?? presetEmojis.first,
                    );
                  } else if (value == 'delete') {
                    await _deleteProfile(
                      context,
                      controller,
                      profile.id,
                      profile.displayName,
                    );
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'rename', child: Text('Rename')),
                  PopupMenuItem(value: 'change_icon', child: Text('Change icon')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
