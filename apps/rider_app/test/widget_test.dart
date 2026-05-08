import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rider_app/main.dart';

void main() {
  testWidgets('Fast Delivery Rider app smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope (required for Riverpod)
    await tester.pumpWidget(
      const ProviderScope(
        child: RiderApp(),
      ),
    );

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
