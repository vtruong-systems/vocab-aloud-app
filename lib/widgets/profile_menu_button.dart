import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/routes.dart';
import '../state/app_controller.dart';

enum _ProfileMenuAction { settings, switchUser }

class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AppController>().activeProfile;
    if (profile == null) return const SizedBox.shrink();

    final emoji = profile.avatarEmoji ?? presetEmojis.first;

    return PopupMenuButton<_ProfileMenuAction>(
      offset: const Offset(0, 48),
      onSelected: (action) {
        switch (action) {
          case _ProfileMenuAction.settings:
            Navigator.pushNamed(context, AppRoutes.settings);
          case _ProfileMenuAction.switchUser:
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.profileSelection,
            );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ProfileMenuAction.settings,
          child: Text('Settings'),
        ),
        PopupMenuItem(
          value: _ProfileMenuAction.switchUser,
          child: Text('Switch user'),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 72),
              child: Text(
                profile.displayName,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
