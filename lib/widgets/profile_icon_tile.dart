import 'package:flutter/material.dart';

import '../data/profile_icon_catalog.dart';
import 'profile_avatar.dart';

class ProfileIconTile extends StatelessWidget {
  const ProfileIconTile({
    super.key,
    required this.entry,
    required this.isOwned,
    required this.isEquipped,
    required this.onTap,
    this.size = 56,
  });

  final ProfileIconEntry entry;
  final bool isOwned;
  final bool isEquipped;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewSize = size * 0.55;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEquipped
                  ? theme.colorScheme.primary
                  : Colors.black12,
              width: isEquipped ? 2.5 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ProfileIconPreview(
                entry: entry,
                size: previewSize,
                dimmed: !isOwned,
              ),
              if (!isOwned)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Icon(
                    Icons.lock,
                    size: size * 0.22,
                    color: Colors.black54,
                  ),
                ),
              if (isEquipped)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Icon(
                    Icons.check_circle,
                    size: size * 0.22,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
