import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gwen_app/main.dart';

void main() {
  testWidgets('GWEN Core Initialized smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GwenApp(),
      ),
    );

    expect(find.text('GWEN Core Initialized'), findsOneWidget);
  });
}
