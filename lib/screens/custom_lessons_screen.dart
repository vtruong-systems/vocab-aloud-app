import 'package:flutter/material.dart';

import '../constants/app_branding.dart';
import '../constants/app_links.dart';
import '../widgets/app_scaffold.dart';

class CustomLessonsScreen extends StatelessWidget {
  const CustomLessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Custom Lessons',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          Text(
            'Teachers and parents can add their own word lists to '
            '$appDisplayName. You can also help improve the app on '
            'GitHub—no special permissions required.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('Create a custom vocabulary set'),
                  subtitle: Text(
                    'Submit a simple spreadsheet with your words, definitions, '
                    'and grade levels. After review, your set is included in a '
                    'future app release. Students can then find it using the '
                    'search bar—try a teacher name, school, or set title.',
                  ),
                ),
                ListTile(
                  title: const Text('Read the step-by-step guide'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchCustomVocabSetsWiki(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('Contribute to the app'),
                  subtitle: Text(
                    '$appDisplayName is open source on GitHub. Fork the '
                    'repository, make your changes, and open a pull request. '
                    'Maintainers review contributions before they are '
                    'merged—the same review process used for custom word sets.',
                  ),
                ),
                ListTile(
                  title: const Text('View the project on GitHub'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => launchGithubRepo(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
