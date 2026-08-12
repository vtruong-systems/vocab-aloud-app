import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vocab_aloud_app/app.dart';

void main() {
  testWidgets('App shows loading state while purchases initialize', (
    tester,
  ) async {
    await tester.pumpWidget(const VocabApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
