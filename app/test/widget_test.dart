import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gwen_app/main.dart';

void main() {
  testWidgets('GWEN Navigation Shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GwenApp(),
      ),
    );

    expect(find.text('GWEN Dashboard'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Home'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Insights'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Location'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'AI'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, 'Settings'), findsOneWidget);
  });
}
