import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const staticGamersAndroidUrl =
    'https://play.google.com/store/apps/details?id=com.staticgamers.daedatechnologies&utm_source=na_Med';
const staticGamersIosUrl =
    'https://apps.apple.com/us/app/staticgamers/id6670280812';

Uri staticGamersStoreUri(BuildContext context) {
  final platform = Theme.of(context).platform;
  if (platform == TargetPlatform.iOS) {
    return Uri.parse(staticGamersIosUrl);
  }
  return Uri.parse(staticGamersAndroidUrl);
}

Future<void> launchStaticGamersStore(BuildContext context) async {
  final uri = staticGamersStoreUri(context);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open StaticGamers store link.')),
    );
  }
}
