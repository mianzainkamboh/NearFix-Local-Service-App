// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:nearfix/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NearfixApp());

    // Verify that the app loads
    expect(find.byType(NearfixApp), findsOneWidget);
  });
}
