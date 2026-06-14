import 'package:flutter/material.dart';

import '../data/profile_icon_catalog.dart';
import '../models/local_profile.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.profile,
    this.size = 28,
  });

  final LocalProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final premiumId = profile.avatarPremiumId;
    if (premiumId != null) {
      final entry = ProfileIconCatalog.findById(premiumId);
      if (entry?.assetPath != null) {
        return Image.asset(
          entry!.assetPath!,
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
      }
    }

    final emoji = profile.avatarEmoji ?? presetEmojis.first;
    return Text(emoji, style: TextStyle(fontSize: size));
  }
}

/// Renders a catalog entry (used in the icon store).
class ProfileIconPreview extends StatelessWidget {
  const ProfileIconPreview({
    super.key,
    required this.entry,
    this.size = 28,
    this.dimmed = false,
  });

  final ProfileIconEntry entry;
  final double size;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (entry.kind == ProfileIconKind.premium && entry.assetPath != null) {
      child = Image.asset(
        entry.assetPath!,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    } else {
      child = Text(
        entry.emoji ?? '',
        style: TextStyle(fontSize: size),
      );
    }

    if (!dimmed) return child;

    return Opacity(opacity: 0.45, child: child);
  }
}
