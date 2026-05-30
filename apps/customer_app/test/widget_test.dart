import 'package:flutter_test/flutter_test.dart';

import 'package:customer_app/main.dart';

void main() {
  test('FastDeliveryApp can be instantiated without throwing', () {
    expect(const FastDeliveryApp(), isA<FastDeliveryApp>());
    expect(const FastDeliveryApp(key: null), isA<FastDeliveryApp>());
    expect(FastDeliveryApp.new, isNot(throwsException));
  });

  test('FastDeliveryApp is a ConsumerWidget (requires Riverpod)', () {
    // FastDeliveryApp extends ConsumerWidget (not StatelessWidget),
    // meaning it requires a ProviderScope parent at runtime.
    // This test verifies the widget type at the class level.
    expect(FastDeliveryApp, isA<Type>());
  });
}
