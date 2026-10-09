import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/grade_level.dart';
import '../navigation/routes.dart';
import '../state/app_controller.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/grade_level_picker.dart';
import '../widgets/profile_emoji_picker.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nameController = TextEditingController();
  String _selectedEmoji = presetEmojis.first;
  GradeLevel? _grade;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name.')));
      return;
    }

    final controller = context.read<AppController>();
    await controller.createProfile(
      displayName: name,
      avatarEmoji: _selectedEmoji,
      maxGradeLevel: _grade,
    );
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.setSelection);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create Profile',
      subtitle: 'Who is practicing?',
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      hintText: 'Alex',
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: 20),
                  Text('Grade', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Hides words above this grade in mixed lists. All keeps every word.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  GradeLevelPicker(
                    includeAll: true,
                    selected: _grade,
                    onSelected: (grade) => setState(() => _grade = grade),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pick an emoji',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ProfileEmojiPicker(
                    selectedEmoji: _selectedEmoji,
                    onEmojiSelected: (emoji) =>
                        setState(() => _selectedEmoji = emoji),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Start Practicing'),
          ),
        ],
      ),
    );
  }
}
