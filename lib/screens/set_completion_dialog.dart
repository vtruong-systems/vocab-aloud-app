import 'package:flutter/material.dart';

Future<void> showSetCompletionDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('You completed this word set!'),
      content: const Text(
        'You practiced every word in different ways.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Awesome'),
        ),
      ],
    ),
  );
}
