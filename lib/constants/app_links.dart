import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const customVocabSetsWikiUrl =
    'https://github.com/vtruong-systems/vocab-aloud-app/wiki/Custom-Vocab-Sets';

const githubRepoUrl = 'https://github.com/vtruong-systems/vocab-aloud-app';

Future<void> launchCustomVocabSetsWiki(BuildContext context) async {
  final uri = Uri.parse(customVocabSetsWikiUrl);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the contribution guide.')),
    );
  }
}

Future<void> launchGithubRepo(BuildContext context) async {
  final uri = Uri.parse(githubRepoUrl);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open GitHub.')),
    );
  }
}
