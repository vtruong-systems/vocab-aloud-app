import 'package:flutter/material.dart';

import '../state/app_controller.dart';

class ProfileEmojiPicker extends StatelessWidget {
  const ProfileEmojiPicker({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  final String selectedEmoji;
  final ValueChanged<String> onEmojiSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: presetEmojis.map((emoji) {
        final selected = emoji == selectedEmoji;
        return ChoiceChip(
          label: Text(emoji, style: const TextStyle(fontSize: 28)),
          selected: selected,
          onSelected: (_) => onEmojiSelected(emoji),
        );
      }).toList(),
    );
  }
}
