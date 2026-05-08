import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin_panel/main.dart';

void main() {
  testWidgets('Fast Delivery Admin app smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope (required for Riverpod)
    await tester.pumpWidget(
      const ProviderScope(
        child: AdminPanelApp(),
      ),
    );

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
