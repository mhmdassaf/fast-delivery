import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:user_app/main.dart';

void main() {
  testWidgets('Fast Delivery app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FastDeliveryApp());

    // Verify that the app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}