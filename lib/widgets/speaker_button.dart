import 'package:flutter/material.dart';

class SpeakerButton extends StatelessWidget {
  const SpeakerButton({
    super.key,
    required this.onSpeak,
    this.size = 48,
  });

  final VoidCallback onSpeak;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSpeak,
      iconSize: size * 0.55,
      style: IconButton.styleFrom(
        minimumSize: Size(size, size),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade700,
      ),
      icon: const Icon(Icons.volume_up_rounded),
      tooltip: 'Read aloud',
    );
  }
}
