// Basic Flutter widget test for Football IQ app

import 'package:flutter_test/flutter_test.dart';

import 'package:football_iq/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FootballIQApp());

    // Verify that the app loads (splash screen shows app title)
    expect(find.text('Football IQ'), findsOneWidget);
  });
}
