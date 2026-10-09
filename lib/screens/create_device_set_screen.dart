import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grade_level.dart';
import '../state/app_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/grade_level_picker.dart';

class _DraftWord {
  final word = TextEditingController();
  final definition = TextEditingController();
  final sentence = TextEditingController();

  void dispose() {
    word.dispose();
    definition.dispose();
    sentence.dispose();
  }
}

class CreateDeviceSetScreen extends StatefulWidget {
  const CreateDeviceSetScreen({super.key});

  @override
  State<CreateDeviceSetScreen> createState() => _CreateDeviceSetScreenState();
}

class _CreateDeviceSetScreenState extends State<CreateDeviceSetScreen> {
  final _titleController = TextEditingController();
  final _words = <_DraftWord>[_DraftWord(), _DraftWord()];
  GradeLevel _grade = GradeLevel.g1;

  @override
  void initState() {
    super.initState();
    final grade = context.read<AppController>().activeProfile?.maxGradeLevel;
    if (grade != null) _grade = grade;
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final word in _words) {
      word.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Give this list a name.')));
      return;
    }

    final entries = [
      for (final draft in _words)
        (
          word: draft.word.text,
          definition: draft.definition.text,
          exampleSentence: draft.sentence.text,
        ),
    ];
    final usable = entries
        .where(
          (entry) =>
              entry.word.trim().isNotEmpty &&
              entry.definition.trim().isNotEmpty,
        )
        .length;
    if (usable == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one word and its meaning.')),
      );
      return;
    }

    await context.read<AppController>().addDeviceSet(
      title: title,
      grade: _grade,
      words: entries,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Add a list',
      subtitle: 'Saved on this device',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'List name',
              hintText: 'Classroom 10 Week 1',
            ),
          ),
          const SizedBox(height: 16),
          Text('Grade', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          GradeLevelPicker(
            selected: _grade,
            onSelected: (grade) {
              if (grade == null) return;
              setState(() => _grade = grade);
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Quiz needs at least two words. Spelling says the word, then asks the child to spell it.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _words.length; i++) ...[
            Text(
              'Word ${i + 1}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _words[i].word,
              decoration: const InputDecoration(labelText: 'Word'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _words[i].definition,
              decoration: const InputDecoration(labelText: 'Meaning'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _words[i].sentence,
              decoration: const InputDecoration(labelText: 'Example sentence'),
            ),
            const SizedBox(height: 16),
          ],
          OutlinedButton(
            onPressed: () => setState(() => _words.add(_DraftWord())),
            child: const Text('Add another word'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _save, child: const Text('Save list')),
        ],
      ),
    );
  }
}
