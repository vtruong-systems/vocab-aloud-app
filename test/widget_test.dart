import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/app.dart';

import 'package:vocab_aloud_app/constants/app_branding.dart';

void main() {
  testWidgets('App loads splash screen', (tester) async {
    await tester.pumpWidget(const VocabApp());
    expect(find.text(appDisplayName), findsOneWidget);
  });
}
