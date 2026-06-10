import 'package:flutter/material.dart';

import '../constants/app_links.dart';
import '../widgets/app_scaffold.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Credits',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: ListView(
        children: [
          const Card(
            child: ListTile(
              title: Text('Creator'),
              subtitle: Text('Van'),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              title: Text('Vocabulary Contributor'),
              subtitle: Text('Jinny'),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              title: Text('Testers'),
              subtitle: Text('Aria and Adrian'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('How to contribute vocabulary sets'),
              subtitle: const Text(
                'Teachers and parents can add custom word lists via GitHub.',
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchCustomVocabSetsWiki(context),
            ),
          ),
        ],
      ),
    );
  }
}
