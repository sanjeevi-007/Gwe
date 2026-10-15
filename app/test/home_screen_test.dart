import 'dart:ffi' hide Size;
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

import 'package:gwen_app/data/database.dart';
import 'package:gwen_app/features/home/home_screen.dart';
import 'package:gwen_app/state/state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    open.overrideFor(OperatingSystem.windows, () {
      final possiblePaths = [
        'sqlite3.dll',
        'app/sqlite3.dll',
        r'C:\Users\rkrsa\AppData\Local\Programs\Python\Python311\DLLs\sqlite3.dll',
      ];
      for (final path in possiblePaths) {
        if (File(path).existsSync()) {
          return DynamicLibrary.open(path);
        }
      }
      return DynamicLibrary.open('sqlite3.dll');
    });
  }

  testWidgets('HomeScreen renders all 5 metric cards and debug modal', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify AppBar header
    expect(find.text('GWEN'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.byKey(const Key('debug_scenario_button')), findsOneWidget);

    // Verify all 5 cards by title
    expect(find.text('Pulse'), findsOneWidget);
    expect(find.text('Movement'), findsOneWidget);
    expect(find.text('GPS'), findsOneWidget);
    expect(find.text('On-Device AI'), findsOneWidget);
    expect(find.text('Device Status'), findsOneWidget);

    // Tap debug button to open bottom sheet
    await tester.tap(find.byKey(const Key('debug_scenario_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify bottom sheet title and scenarios
    expect(find.text('Simulation Scenarios'), findsOneWidget);
    expect(find.text('Normal Operating Mode'), findsOneWidget);
    expect(find.text('Poor Signal State'), findsOneWidget);
    expect(find.text('No Finger Detected'), findsOneWidget);
    expect(find.text('GPS Searching Mode', skipOffstage: false), findsOneWidget);
    expect(find.text('GPS Stale State', skipOffstage: false), findsOneWidget);
    expect(find.text('AI Uncertain State', skipOffstage: false), findsOneWidget);
    expect(find.text('Sensor Hardware Error', skipOffstage: false), findsOneWidget);
    expect(find.text('Disconnected Link', skipOffstage: false), findsOneWidget);

    // Select Normal Operating Mode
    await tester.tap(find.text('Normal Operating Mode'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Bottom sheet is dismissed
    expect(find.text('Simulation Scenarios'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });
}
