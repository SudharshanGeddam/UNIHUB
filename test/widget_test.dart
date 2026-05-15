// Basic widget tests for UniHub application.
//
// Verify that the application UI boots up without crashing. 
// We test a simple UI screen to avoid Firebase initialization issues in CI.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unihub/features/reminders/screens/smart_reminders_screen.dart';

void main() {
  testWidgets('SmartRemindersScreen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: SmartRemindersScreen()));

    // Wait for animations to complete
    await tester.pumpAndSettle();

    // Verify that the screen builds without crashing and displays the header.
    expect(find.text('Smart Notifications'), findsOneWidget);
  });
}
